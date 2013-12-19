//
//  ForgetPasswordViewController.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 19/12/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AuthHelper.h"

@interface ForgetPasswordViewController : UIViewController <UITextFieldDelegate, AuthHelperDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;

@end
