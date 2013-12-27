//
//  InputDetailsMultipleViewController.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 26/12/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "InputDetailsMultipleViewController.h"
#import "Detector.h"
#import "GalleryViewController.h"
#import "UIViewController+ShowAlert.h"

@interface InputDetailsMultipleViewController ()
{
    NSString *_name;
    UIImage *_image;
}

@end

@implementation InputDetailsMultipleViewController


- (void) loadMultiplePictures
{
    NSArray *imageViews = [NSArray arrayWithObjects:self.imageView1, self.imageView2, self.imageView3, self.imageView4, nil];
    for(int i=0; i<4; i++)
        if(i<self.detectors.count){
            UIImageView *imageView = [imageViews objectAtIndex:i];
            imageView.image = [UIImage imageWithData:[(Detector *)[self.detectors objectAtIndex:i] image]];
        }
    
    _image = [self captureImageFromView:self.captureView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadMultiplePictures];
}


#pragma mark -
#pragma mark UITextFieldDelegate


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    _name = textField.text;
    if(_name.length==0)
        [self showAlertWithTitle:@"Empty name" andDescription:@"Introduce a name for the detector."];
    else
        [self createMultipleDetector];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // limit the number of characters
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 25) ? NO : YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Disable keyboard when the background is touched
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

#pragma mark -
#pragma mark Private Methods

- (UIImage *) captureImageFromView:(UIView *) captureView
{
    CGRect rect = [captureView bounds];
    UIGraphicsBeginImageContextWithOptions(rect.size,YES,0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [captureView.layer renderInContext:context];
    UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return capturedImage;
}

- (void) createMultipleDetector
{
    int controllerNum = self.navigationController.viewControllers.count;
    GalleryViewController *galleryVC = [self.navigationController.viewControllers objectAtIndex:controllerNum-2];
    galleryVC.filter = FILTER_MULTIPLE;
    
    MultipleDetector *md = [MultipleDetector multipleDetectorWithName:_name
                                                         forDetectors:self.detectors
                                               inManagedObjectContext:self.detectorDatabase.managedObjectContext];
    
    md.image = UIImageJPEGRepresentation(_image, 0.5);
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
