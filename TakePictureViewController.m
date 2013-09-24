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


@interface TakePictureViewController()
{
    BOOL _takePicture;
    NSMutableArray *_images;
    NSMutableArray *_boxes;
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

- (void) initializeAnnotations
{
    _images = [[NSMutableArray alloc] init];
    _boxes = [[NSMutableArray alloc] init];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Detector";
    
    [self initializeButtons];
    [self initializeAnnotations];
    
    _images = [[NSMutableArray alloc] init];

    // Add subviews in front of  the prevLayer
    [self.view.layer insertSublayer:_prevLayer atIndex:0];
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.detectorTrainer = [[DetectorTrainer alloc] init];
    
//    //set the frame here after all the navigation tabs have been uploaded and we have the definite frame size
//    _prevLayer.frame = self.detectView.frame;

    
    //Fix Orientation
    [self adaptToPhoneOrientation:[[UIDevice currentDevice] orientation]];
}




#pragma mark -
#pragma mark Taking picture


//override from parent
- (void) processImage:(CGImageRef) imageRef
{
    if(_takePicture){
        _takePicture = NO;
        
        //construct the image depending on the orientation
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        UIImage *image;
        if(UIDeviceOrientationIsLandscape(orientation)){
            image = [UIImage imageWithCGImage:imageRef];
        }else image = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationRight];
        
        [self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];

        [_images addObject:image];
        [_boxes addObject:self.tagView.box];
    
    }
    //DETECTION
//    NSArray *detectedBoxes = [self detectedBoxesForImage:image withOrientation:orientation];
}


#pragma mark -
#pragma mark IBActions

- (IBAction)switchCameras:(id)sender
{
    [super switchCameras:sender];
}

- (IBAction)takePictureAction:(id)sender
{
    _takePicture = YES;
}


#pragma mark -
#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showInputDetails"]) {

        InputDetailsViewController *destinationVC = (InputDetailsViewController *)segue.destinationViewController;
        self.detectorTrainer.images = [NSArray arrayWithArray:_images];
        self.detectorTrainer.boxes = [NSArray arrayWithArray:_boxes];
        destinationVC.detectorTrainer = self.detectorTrainer;
    }
}

#pragma mark -
#pragma mark Rotation

- (void)willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self adaptToPhoneOrientation:toInterfaceOrientation];
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void) adaptToPhoneOrientation:(UIDeviceOrientation) orientation
{
    if(orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationLandscapeLeft){
        [CATransaction begin];
        _prevLayer.orientation = orientation;
        _prevLayer.frame = self.view.frame;
        [CATransaction commit];
    }
}





@end

