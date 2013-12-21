//
//  ForgetPasswordViewController.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 19/12/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "ForgetPasswordViewController.h"
#import "UIViewController+ShowAlert.h"

@interface ForgetPasswordViewController ()
{
     ForgotPasswordHandler *_forgotPasswordHandler;
}
@end

@implementation ForgetPasswordViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textField.delegate = self;
    
    _forgotPasswordHandler = [[ForgotPasswordHandler alloc] init];
    _forgotPasswordHandler.delegate = self;
}


    
#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendEmail];
    return YES;
}

- (void) sendEmail
{
    NSString *email = self.textField.text;
    [_forgotPasswordHandler resetPasswordForEmail:email];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Disable keyboard when the background is touched
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

#pragma mark -
#pragma mark AuthHelperDelegate

- (void) requestFailedWithErrorTitle:(NSString *)title errorMessage:(NSString *) message
{
    [self showAlertWithTitle:title andDescription:message];
}


@end
