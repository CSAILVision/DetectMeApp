//
//  TrainingViewController.h
//  DetectTube
//
//  Created by Josep Marc Mingot Hidalgo on 20/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetectorTrainer.h"
#import "ShareDetector.h"

@interface TrainingViewController : UIViewController<DetectorTrainerDelegate, ShareDectorDelegate>

//model
@property (strong, nonatomic) UIManagedDocument *detectorDatabase;
@property (strong, nonatomic) DetectorTrainer *detectorTrainer;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

// buttons
@property (weak, nonatomic) IBOutlet UIButton *executeButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
- (IBAction)doneAction:(id)sender;

@end
