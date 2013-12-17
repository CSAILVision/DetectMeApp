//
//  CameraVideoViewController.h
//  LabelMe
//
//  Created by Josep Marc Mingot Hidalgo on 07/08/13.
//  Copyright (c) 2013 CSAIL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface CameraVideoViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate>

{
    @protected
      AVCaptureVideoPreviewLayer *_prevLayer;
}

- (IBAction)switchCameras:(id)sender;
- (void) processImage:(CGImageRef) imageRef;

// Adapts prev layer to the current orientation
// Used when the device rotates
- (void) adaptOrientationForPrevLayer;

// Adapts the image taken to the current orientation
- (UIImage *) adaptOrientationForImageRef:(CGImageRef)imageRef;

@end
