//
//  ForgetPasswordViewController.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 19/12/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AuthHelper.h"
#import "ForgotPasswordHandler.h"

@interface ForgetPasswordViewController : UIViewController <UITextFieldDelegate, ForgotPasswordHandlerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;

- (IBAction)resetPasswordAction:(id)sender;
@end
