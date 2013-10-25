//
//  InputDetailsViewController.h
//  DetectTube
//
//  Created by Josep Marc Mingot Hidalgo on 20/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetectorTrainer.h"

@interface InputDetailsViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) DetectorTrainer *detectorTrainer;
@property (weak, nonatomic) IBOutlet UITextField *objectTextField;

- (IBAction)isPublicAction:(UISegmentedControl *)sender;


@end
