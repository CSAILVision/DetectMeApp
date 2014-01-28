//
//  DetectView.h
//  ImageG
//
//  Created by Dolores Blanco Almazán on 12/06/12.
//  Updated by Josep Marc Mingot.
//  Copyright (c) 2012 CSAIL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

/*
 
 Class  Responsibilities:
 
 - Draw the boxes output of the detection
 - Match the coordinate system with the one in the prevLayer
 - Assign colors to each detector
 
 */


@interface DetectView : UIView

// To transform a point from the device reference to prevLayer reference
- (void) initializeInTheLayer:(AVCaptureVideoPreviewLayer *)prevLayer forObjectLabels:(NSArray *)labels;

- (void) drawBoxes:(NSArray *)boxes;
- (void) switchCameras;

@end

