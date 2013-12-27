//
//  InputDetailsMultipleViewController.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 26/12/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultipleDetector+Create.h"

@interface InputDetailsMultipleViewController : UIViewController <UITextFieldDelegate>

//model
@property (strong, nonatomic) NSArray *detectors;
@property (strong, nonatomic) UIManagedDocument *detectorDatabase;

//views
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView3;
@property (weak, nonatomic) IBOutlet UIImageView *imageView4;
@property (weak, nonatomic) IBOutlet UIView *captureView;

@end
