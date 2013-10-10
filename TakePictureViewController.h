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



@protocol TakePictureViewControllerDelegate <NSObject>

- (void) takenImages:(NSArray *) images withBoxes:(NSArray *)boxes;
@end

@interface TakePictureViewController : CameraVideoViewController

@property (strong, nonatomic) id<TakePictureViewControllerDelegate> delegate;
@property (strong, nonatomic) DetectorTrainer *detectorTrainer;


//views
@property (weak, nonatomic) IBOutlet TagView *tagView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet AYUIButton *switchButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

// trick to hide next button when accessing from retrain
@property BOOL hideNextButton;

- (IBAction)switchCameras:(id)sender;
- (IBAction)takePictureAction:(id)sender;

@end