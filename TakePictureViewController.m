//
//  TakePictureViewController.m
//  LabelMe
//
//  Created by Josep Marc Mingot Hidalgo on 22/03/13.
//  Copyright (c) 2013 CSAIL. All rights reserved.
//

#import "TakePictureViewController.h"
#import "InputDetailsViewController.h"
#import "UIImage+HOG.h"
#import "UIImage+Resize.h"
#import "AnnotatedImage+Create.h"
#import "ManagedDocumentHelper.h"
#import "UIImage+Rotation.h"

@interface TakePictureViewController()
{
    BOOL _takePicture;
    NSMutableArray *_annotatedImages;
    UIManagedDocument *_detectorDatabase;
    CLLocationManager *_locationManager;
    CMMotionManager *_motionManager;
    CLLocation *_currentLocation;
}

@end


@implementation TakePictureViewController


#pragma mark -
#pragma mark Initialization and View Lifcycle


- (BOOL) shouldAutorotate
{
    return NO;
}


- (void)initializeButtons
{
    [self.switchButton transformButtonForCamera];
    [self.switchButton setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.8] forState:UIControlStateSelected];
    self.switchButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.switchButton.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
    [self.switchButton setImage:[UIImage imageNamed:@"switchCamera"] forState:UIControlStateNormal];
}


- (void) initializeManagers
{
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager startUpdatingLocation];
    
    _motionManager = [[CMMotionManager alloc] init];
    [_motionManager startDeviceMotionUpdates];
    
}

- (void) initializeTagView
{
    [self.tagView addBoxInView];
    self.tagView.translucentBackground = YES;
}

- (void) initializeNextButton
{
    // disabled until
    self.nextButton.enabled = NO;
}

- (void) stopManagers
{
    [_locationManager stopUpdatingLocation];
    [_motionManager stopDeviceMotionUpdates];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initializeButtons];
    [self initializeTagView];
    [self initializeNextButton];
    
    _annotatedImages = [[NSMutableArray alloc] init];
    
    // Add subviews in front of  the prevLayer
    [self.view.layer insertSublayer:_prevLayer atIndex:0];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initializeManagers];
    
    self.detectorTrainer = [[DetectorTrainer alloc] init];
    self.title = [NSString stringWithFormat:@"%lu images", (unsigned long)_annotatedImages.count];
    
    if(!_detectorDatabase)
        _detectorDatabase = [ManagedDocumentHelper sharedDatabaseUsingBlock:^(UIManagedDocument *document){}];
}


- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.imageView.image = nil;
    self.title = @"Add";
    
    [self stopManagers];
}


#pragma mark -
#pragma mark Taking picture


//override from parent
- (void) processImage:(CGImageRef) imageRef
{
    if(_takePicture){
        _takePicture = NO;
        
        // Correct image orientation from the camera
        UIImage *image = [self adaptOrientationForImageRef:imageRef];
        
        [self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
        
        AnnotatedImage *annotatedImage = [AnnotatedImage annotatedImageWithImage:image
                                                                             box:[self convertBoxForView:self.tagView.box onOrientation:[[UIDevice currentDevice] orientation]]
                                                                     forLocation:_currentLocation
                                                                       forMotion:_motionManager.deviceMotion
                                                          inManagedObjectContext:_detectorDatabase.managedObjectContext];
        
        [_annotatedImages addObject:annotatedImage];
        
        NSString *title = [NSString stringWithFormat:@"%lu images", (unsigned long)_annotatedImages.count];
        [self performSelectorOnMainThread:@selector(setTitle:) withObject:title waitUntilDone:NO];
    }
}


- (Box *) convertBoxForView:(Box *) box onOrientation:(UIDeviceOrientation) orientation
{
    // The image show in the camera is an "aspect fit" of the actual image taken
    // To solve it, we need to convert the box to the "camera" reference system

    CGPoint upperLeft = [_prevLayer captureDevicePointOfInterestForPoint:CGPointMake(box.upperLeft.x*self.tagView.frame.size.width,
                                                                                     box.upperLeft.y*self.tagView.frame.size.height)];
    CGPoint lowerRight = [_prevLayer captureDevicePointOfInterestForPoint:CGPointMake(box.lowerRight.x*self.tagView.frame.size.width,
                                                                                      box.lowerRight.y*self.tagView.frame.size.height)];
    
    
    // We have to rotate the image acording to orientation
    CGPoint upperLeftRotated = CGPointZero;
    CGPoint lowerRightRotated = CGPointZero;
    
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            upperLeftRotated.x = 1 - upperLeft.y;
            upperLeftRotated.y = upperLeft.x;
            lowerRightRotated.x = 1 - lowerRight.y;
            lowerRightRotated.y = lowerRight.x;
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            upperLeftRotated.x = upperLeft.x;
            upperLeftRotated.y = upperLeft.y;
            lowerRightRotated.x = lowerRight.x;
            lowerRightRotated.y = lowerRight.y;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            upperLeftRotated.x = 1 - upperLeft.x;
            upperLeftRotated.y = 1 - upperLeft.y;
            lowerRightRotated.x = 1 - lowerRight.x;
            lowerRightRotated.y = 1 - lowerRight.y;
            break;
            
            
        default:
            break;
    }
    
    
    Box *newBox = [[Box alloc] initWithUpperLeft:upperLeftRotated lowerRight:lowerRightRotated];
    
    return newBox;
}

#pragma mark -
#pragma mark IBActions

- (IBAction)switchCameras:(id)sender
{
    [super switchCameras:sender];
}

- (IBAction)takePictureAction:(id)sender
{
    //animation
    [UIView animateWithDuration:0.2f animations:^{[self.view setAlpha:0.5f];}
                                    completion:^(BOOL finished){[self.view setAlpha:1];}
     ];
    
    //enable next button
    self.nextButton.enabled = YES;
    
    _takePicture = YES;
}

- (IBAction)nextAction:(id)sender
{
    if(self.isRetraining){
        [self.delegate takenAnnotatedImages:_annotatedImages];
        [self.navigationController popViewControllerAnimated:YES];
        
    }else{
        [self performSegueWithIdentifier:@"showInputDetails" sender:self];
    }
}


#pragma mark -
#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:@"Failed to Get Your Location"
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    _currentLocation = newLocation;

}

#pragma mark -
#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showInputDetails"]) {
        
        InputDetailsViewController *destinationVC = (InputDetailsViewController *)segue.destinationViewController;
        self.detectorTrainer.annotatedImages = [NSArray arrayWithArray:_annotatedImages];
        destinationVC.detectorTrainer = self.detectorTrainer;
    }
}

@end

