//
//  SignUpViewController.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 07/10/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()
{
    AuthHelper *_authHelper;
}
@end

@implementation SignUpViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.activityIndicator.hidden = YES;
    
    _authHelper = [[AuthHelper alloc] init];
    _authHelper.delegate = self;
}


- (IBAction)signUpAction:(id)sender
{
    [self startAnimation];
    
    NSString *username = self.usernameTextField.text;
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    
    [_authHelper signUpUsername:username forEmail:email forPassword:password];
    
}

#pragma mark -
#pragma mark AuthHelperDelegate

- (void) signUpCompleted
{
    [self stopAnimation];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void) requestFailedWithErrorMessages:(NSDictionary *)errorMessages
{
    [self stopAnimation];
}

#pragma mark -
#pragma mark Private Methods

- (void) stopAnimation
{
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
}

- (void) startAnimation
{
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
}

@end
