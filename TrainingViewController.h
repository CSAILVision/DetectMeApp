//
//  TrainingViewController.h
//  DetectTube
//
//  Created by Josep Marc Mingot Hidalgo on 20/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetectorTrainer.h"

@interface TrainingViewController : UIViewController<DetectorTrainerDelegate>


@property (strong, nonatomic) UIManagedDocument *detectorDatabase;
@property (strong, nonatomic) DetectorTrainer *detectorTrainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
