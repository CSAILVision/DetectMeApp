//
//  SignUpViewController.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 07/10/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "SignUpViewController.h"
#import "UIViewController+ShowAlert.h"

@interface SignUpViewController ()
{
    AuthHelper *_authHelper;
}
@end

@implementation SignUpViewController


- (void) initializeBackgroundImage
{
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:self.view.frame];
    [backgroundImage setImage:[UIImage imageNamed:@"launch-i5.png"]];
    [backgroundImage setContentMode:UIViewContentModeScaleAspectFill];
    [self.view insertSubview:backgroundImage atIndex:0];
    
    self.view.tintColor = [UIColor whiteColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.activityIndicator.hidden = YES;
    [self initializeBackgroundImage];
    
    _authHelper = [[AuthHelper alloc] init];
    _authHelper.delegate = self;
}


- (IBAction)signUpAction:(id)sender
{
    [self startAnimation];
    
    NSString *username = self.usernameTextField.text;
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    
    if ([email length]==0)
        [self showAlertWithTitle:@"Error" andDescription:@"e-mail can not be blank"];
    
    else [_authHelper signUpUsername:username forEmail:email forPassword:password];
    
}

#pragma mark -
#pragma mark AuthHelperDelegate

- (void) signUpCompleted
{
    [self stopAnimation];
    [self performSegueWithIdentifier:@"SignUpComplete" sender:nil];
}

- (void) requestFailedWithErrorTitle:(NSString *)title errorMessage:(NSString *) message;
{
    [self stopAnimation];
    [self showAlertWithTitle:title andDescription:message];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([textField.placeholder isEqualToString:@"username"])
        [self.emailTextField becomeFirstResponder];
    
    else if([textField.placeholder isEqualToString:@"e-mail"])
        [self.passwordTextField becomeFirstResponder];
    
    else if([textField.placeholder isEqualToString:@"password"])
        [self signUpAction:self];
    
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Disable keyboard when the background is touched
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
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
