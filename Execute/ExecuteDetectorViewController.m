//
//  ExecuteDetectorViewController.m
//  LabelMe
//
//  Created by Josep Marc Mingot Hidalgo on 22/03/13.
//  Copyright (c) 2013 CSAIL. All rights reserved.
//

#import "ExecuteDetectorViewController.h"
#import "BoundingBox.h"
#import "ConvolutionHelper.h"
#import "BoxSender.h"
#import "UIImage+HOG.h"
#import "UIImage+Resize.h"
#import "UIViewController+ShowAlert.h"
#import "Reachability+DetectMe.h"

@interface ExecuteDetectorViewController()
{
    float _fpsToShow;
    int _num;
    int _numMax;    
    int _numPyramids;
    double _maxDetectionScore;
    
    //states to show
    BOOL _score;
    BOOL _fps;
    BOOL _scale;
    int _level;
    BOOL _hog;
    
    BOOL _sendBoxesToServer;
    
    const NSArray *_settingsStrings;
    BoxSender *_boxSender;
    
    NSMutableArray *_detectorWrappers;
    
    TestHelper *_testHelper;
    
}

@property (strong, nonatomic) Pyramid *hogPyramid;
@property (strong, nonatomic) NSMutableArray *initialDetectionThresholds; //initial threshold for mutliclass threshold sweeping

// Responsible of disabling de |settingsTableView| when a touch outside it is done
- (void)settingsViewCancelled:(UIGestureRecognizer *)gestureRecognizer;

@end


@implementation ExecuteDetectorViewController


#pragma mark -
#pragma mark Getters and Setters


- (NSMutableArray *) initialDetectionThresholds
{
    if(!_initialDetectionThresholds){
        _initialDetectionThresholds = [[NSMutableArray alloc] initWithCapacity:_detectorWrappers.count];
        for(DetectorWrapper *detectorWrapper in _detectorWrappers)
            [_initialDetectionThresholds addObject:detectorWrapper.detectionThreshold];
    }
    return _initialDetectionThresholds;
}



#pragma mark -
#pragma mark Initialization and View Lifcycle

- (void) initializeConstants
{
    _settingsStrings = [[NSArray alloc] initWithObjects:@"FPS",@"HOG", nil]; //@"Scale",@"Score", 
    
    _fpsToShow = 0.0;
    _num = 0;
    _numMax = 1;
    _numPyramids = 15;
    _maxDetectionScore = -0.9;
}


- (BOOL) shouldAutorotate
{
    return NO;
}

- (void)initializeSettingsTableView
{
    self.settingsTableView.hidden = YES;
    self.settingsTableView.layer.cornerRadius = 10;
    self.settingsTableView.backgroundColor = [UIColor clearColor];
}

- (void)initializeButtons
{
    [self.cancelButton transformButtonForCamera];
    [self.settingsButton transformButtonForCamera];
    [self.settingsButton setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.8] forState:UIControlStateSelected];
    
    [self.switchButton transformButtonForCamera];
    [self.switchButton setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.8] forState:UIControlStateSelected];
    self.switchButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.switchButton.contentEdgeInsets = UIEdgeInsetsMake(2, 10, 2, 10);
    [self.switchButton setImage:[UIImage imageNamed:@"switchCamera"] forState:UIControlStateNormal];
}

- (void)initializeSlider
{
    [self.detectionThresholdSliderButton addTarget:self action:@selector(sliderChangeAction:) forControlEvents:UIControlEventValueChanged];
    if(self.detectors.count == 1){
        Detector *detector = [self.detectors firstObject];
        self.detectionThresholdSliderButton.value = detector.detectionThreshold.floatValue;
    }else{
        // Slide initially set at the middle point
        // At the update, all the detectors are moved the same amount
        self.detectionThresholdSliderButton.value = 0.5;
    }
}

- (void)initializeDetectView
{
    NSMutableArray *labels = [[NSMutableArray alloc] initWithCapacity:_detectorWrappers.count];
    for(DetectorWrapper *detectorWrapper in _detectorWrappers)
        [labels addObject:[detectorWrapper.targetClasses componentsJoinedByString:@"+"]];
    
    [self.detectView initializeInTheLayer:_prevLayer forObjectLabels:labels];
}

- (void) initializeTestViews
{
    [self.tagView addBoxInView];
    self.tagView.hidden = !self.isTest;
    self.startTestButton.hidden = !self.isTest;
    self.connectButton.hidden = self.isTest;
    self.countDownProgressView.hidden = YES;
    [self.countDownProgressView setProgress:0.0];
}

- (void) initializeDetectorWrappers
{
    _detectorWrappers = [[NSMutableArray alloc] initWithCapacity:self.detectors.count];
    for(Detector *detector in self.detectors)
        [_detectorWrappers addObject:[[DetectorWrapper alloc] initWithDetector:detector]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _boxSender = [[BoxSender alloc] init];
    
    [self initializeDetectorWrappers];
    
    [self initializeConstants];
    [self initializeSlider];
    [self initializeSettingsTableView];
    [self initializeButtons];
    [self initializeDetectView];
    [self initializeTestViews];
    
    self.infoLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.infoLabel.numberOfLines = 0;
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(settingsViewCancelled:)];
    [self.view addGestureRecognizer:tgr];
    
    // Add subviews in front of  the prevLayer
    [self.view.layer insertSublayer:_prevLayer atIndex:0];
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //reset the pyramid with the new detectors
    self.hogPyramid = [[Pyramid alloc] initWithDetectors:_detectorWrappers forNumPyramids:_numPyramids];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //update detection threshold it it is the only one
    if(_detectorWrappers.count == 1)
        [self.delegate updateDetector:(DetectorWrapper *)[_detectorWrappers objectAtIndex:0]];
}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.detectView drawBoxes:nil]; //reset view
}


#pragma mark -
#pragma mark Object Detection

- (NSArray *) detectedBoxesForImage:(UIImage *)image
{
    NSMutableArray *nmsArray = [[NSMutableArray alloc] init];
    
     //single class detection
    if(_detectorWrappers.count == 1){
        DetectorWrapper *detectorWrapper = [_detectorWrappers objectAtIndex:0];
        float detectionThreshold = -1 + 2*detectorWrapper.detectionThreshold.floatValue; //in [-1,1]

        NSArray *boxes = [detectorWrapper detect:image
                                minimumThreshold:detectionThreshold
                                        pyramids:_numPyramids
                                        usingNms:YES
                              learningImageIndex:0];
        
        [self adaptOrientationForBoxes:boxes];
        [nmsArray addObject:boxes];
         
         
    //Multiclass detection
    }else{
        
        [self.hogPyramid constructPyramidForImage:image withOrientation:[[UIDevice currentDevice] orientation]];
        
        //each detector run in parallel
        __block NSArray *candidatesForDetector;
        dispatch_queue_t detectorQueue = dispatch_queue_create("detectorQueue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_apply(_detectorWrappers.count, detectorQueue, ^(size_t i) {
            DetectorWrapper *detectorWrapper = [_detectorWrappers objectAtIndex:i];
            float detectionThreshold = -1 + 2*detectorWrapper.detectionThreshold.floatValue;
            candidatesForDetector = [detectorWrapper detect:self.hogPyramid
                                           minimumThreshold:detectionThreshold
                                                   usingNms:YES];
            [self adaptOrientationForBoxes:candidatesForDetector];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [nmsArray addObject:candidatesForDetector];
            });
        });
    }
    return [NSArray arrayWithArray:nmsArray];
}

//override from parent
- (void) processImage:(CGImageRef) imageRef
{
    //start recording FPS
    NSDate * start = [NSDate date];
    
    //construct the image depending on the orientation
    UIImage *image = [self adaptOrientationForImageRef:imageRef];
    
    //DETECTION
    NSArray *detectedBoxes = [self detectedBoxesForImage:image];
    
    //TEST
    [_testHelper receivedDetections:detectedBoxes onRealBox:self.tagView.box];
    
    //DISPLAY BOXES
    [self.detectView drawBoxes:detectedBoxes];
    
    //SEND TO THE SEVER
    if(_sendBoxesToServer){
        [_boxSender sendBoxes:detectedBoxes];
        [_boxSender sendImage:image];
        [_boxSender sendBoxes:detectedBoxes forImage:image];
    }
    
    
    //Put the HOG picture on screen
    if (_hog){
        UIImage *imageHOG = [[image scaleImageTo:230/480.0] convertToHogImage];
        [self.HOGimageView performSelectorOnMainThread:@selector(setImage:) withObject:imageHOG waitUntilDone:YES];
    }
    
    // Update the navigation controller title with some information about the detection
    _level = -1;
    float scoreFloat = -1;

    //update label with the current FPS
    _fpsToShow = (_fpsToShow*_num + -1.0/[start timeIntervalSinceNow])/(_num+1);
    _num++;
    NSMutableString *screenLabelText = [[NSMutableString alloc] initWithString:@""];
    if(_score) [screenLabelText appendString:[NSString stringWithFormat:@"score:%.2f\n", scoreFloat]];
    if(_fps) [screenLabelText appendString: [NSString stringWithFormat:@"FPS: %.1f\n",-1.0/[start timeIntervalSinceNow]]];
    if(_scale) [screenLabelText appendString: [NSString stringWithFormat:@"scale: %d\n",_level]];
    [self.infoLabel performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithString:screenLabelText] waitUntilDone:YES];
    
    //NSLog(@"%f", -1.0/[start timeIntervalSinceNow]);
}

#pragma mark -
#pragma mark Settings delegate


-(void) setNumMaximums:(BOOL) value
{
    _numMax = value ? 10 : 1;
}

- (void) setNumPyramidsFromDelegate: (double) value
{
    _numPyramids = (int) value;
}



#pragma mark -
#pragma mark TestHelperDelegate

- (void) updateProgress:(float) progress
{
    [self.countDownProgressView setProgress:progress animated:YES];
}

- (void) testDidFinishWithMessage:(NSString *)message
{
    [self showAlertWithTitle:@"Finish Test" andDescription:message];
    [self.startTestButton setTitle:@"Start" forState:UIControlStateNormal];
    self.countDownProgressView.hidden = YES;
}

#pragma mark -
#pragma mark IBActions

- (IBAction)switchCameras:(id)sender
{
    [self.detectView switchCameras];
    [super switchCameras:sender];
}

- (IBAction)showSettingsAction:(id)sender
{
    self.settingsTableView.hidden = !self.settingsTableView.hidden;
}

- (IBAction)sliderChangeAction:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    
    //if only one detector executing, update the detection threshold property
    if(self.detectors.count == 1){
        
        Detector *detector = [self.detectors firstObject];
        detector.detectionThreshold = @(slider.value);
        
        DetectorWrapper *detectorWrapper = [_detectorWrappers firstObject];
        detectorWrapper.detectionThreshold = @(slider.value);
        
    //if more than one, joinly increase/decrease detection threshold
    }else{
        if(((int)slider.value*100)%4==0){
            for(int i=0; i<_detectorWrappers.count; i++){
                DetectorWrapper *detectorWrapper = [_detectorWrappers objectAtIndex:i];
                NSNumber *initialThreshold = [self.initialDetectionThresholds objectAtIndex:i];
                float newThreshold = initialThreshold.floatValue + (slider.value - 0.5);
                newThreshold = newThreshold >= 0 ? newThreshold : 0;
                newThreshold = newThreshold <= 1 ? newThreshold : 1;
                detectorWrapper.detectionThreshold = @(newThreshold);
            }
        }
        
    }
}


- (IBAction)cancelAction:(id)sender
{
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)switchValueDidChange:(UISwitch *)sw
{
    NSString *label = [_settingsStrings objectAtIndex:sw.tag];
    if([label isEqualToString:@"HOG"]){
        _hog = sw.on;
        if(!_hog) {self.HOGimageView.image = nil; self.HOGimageView.hidden = YES;}
        else self.HOGimageView.hidden = NO;}
    else if([label isEqualToString:@"FPS"]){ _fps = sw.on;}
    else if([label isEqualToString:@"Scale"]){ _scale = sw.on;}
    else if([label isEqualToString:@"Score"]){ _score = sw.on;}
}

- (IBAction)sendBoxesToServer:(UIButton *)senderButton
{
    // Check reachability
    if(![Reachability isNetworkReachable]){
        [self showAlertWithTitle:@"Error" andDescription:@"Connection not available."];
        return;
    }
    
    if(!_sendBoxesToServer){
        _sendBoxesToServer = YES;
        [_boxSender openConnection];
        [senderButton setTitle:@"Stop" forState:UIControlStateNormal];
        
    }else{
        _sendBoxesToServer = NO;
        [_boxSender closeConnection];
        [senderButton setTitle:@"Send" forState:UIControlStateNormal];
    }
}


- (IBAction)startTestAction:(UIButton *) startTestButton;
{
    if([startTestButton.titleLabel.text isEqualToString:@"Start"]){
        _testHelper = [[TestHelper alloc] init];
        _testHelper.delegate = self;
        [_testHelper startTest];
        self.countDownProgressView.hidden = NO;
        [startTestButton setTitle:@"Cancel" forState:UIControlStateNormal];
        
        
    }else if([startTestButton.titleLabel.text isEqualToString:@"Cancel"]){
        self.countDownProgressView.hidden = YES;
        [_testHelper cancelTest];
        [startTestButton setTitle:@"Start" forState:UIControlStateNormal];
        
    }
}



#pragma mark -
#pragma mark Table View Data Source and Delegate

- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section
{
    return _settingsStrings.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.opaque = NO;
    
    NSString *label = [_settingsStrings objectAtIndex:indexPath.row];
    cell.textLabel.text = label;

    //switch
    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectZero];
    [sw setOnTintColor:[UIColor colorWithRed:(180.0/255.0) green:(28.0/255.0) blue:(36.0/255.0) alpha:1.0]];
    [sw setOn:NO  animated:NO];
    sw.tag = indexPath.row;
    [sw addTarget:self action:@selector(switchValueDidChange:) forControlEvents:UIControlEventValueChanged];
    cell.accessoryView = sw;
    
    return cell;
}

#pragma mark -
#pragma mark Private methods

- (void)settingsViewCancelled:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint coords = [gestureRecognizer locationInView:gestureRecognizer.view];
    if (!CGRectContainsPoint(self.settingsTableView.bounds, coords) && self.settingsButton.selected) {
        //enable the effect of the button when tapped outside the |settingsTableView| and selected
        self.settingsButton.selected = !self.settingsButton.selected;
        [self showSettingsAction:nil];
    }
}


- (void) adaptOrientationForBoxes:(NSArray *)boxes
{
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    
    if(orientation == UIDeviceOrientationLandscapeRight){
        for(BoundingBox *boundingBox in boxes){
            double auxXmin, auxXmax;
            auxXmin = boundingBox.xmin;
            auxXmax = boundingBox.xmax;
            boundingBox.xmin = boundingBox.ymin;
            boundingBox.xmax = boundingBox.ymax;
            boundingBox.ymin = 1 - auxXmin;
            boundingBox.ymax = 1 - auxXmax;
        }
        
    }else if(orientation == UIDeviceOrientationLandscapeLeft){
        for(BoundingBox *boundingBox in boxes){
            double auxXmin, auxXmax;
            auxXmin = boundingBox.xmin;
            auxXmax = boundingBox.xmax;
            boundingBox.xmin = (1 - boundingBox.ymin);
            boundingBox.xmax = (1 - boundingBox.ymax);
            boundingBox.ymin = auxXmin;
            boundingBox.ymax = auxXmax;
        }
        
    }
}




@end

