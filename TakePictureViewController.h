//
//  TakePictureViewController.h
//  LabelMe
//
//  Created by Josep Marc Mingot Hidalgo on 22/03/13.
//  Copyright (c) 2013 CSAIL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CameraVideoViewController.h"
#import "DetectorTrainer.h"
#import "TagView.h"
#import "AYUIButton.h"




@interface TakePictureViewController : CameraVideoViewController

@property (strong, nonatomic) DetectorTrainer *detectorTrainer;
@property (weak, nonatomic) IBOutlet TagView *tagView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet AYUIButton *switchButton;
- (IBAction)switchCameras:(id)sender;
- (IBAction)takePictureAction:(id)sender;

@end