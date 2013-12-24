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

- (void) initializeBackgroundImage
{
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:self.view.frame];
    BOOL isIPhone4 = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
    BOOL isIPhone5 = isIPhone4 && ([[UIScreen mainScreen] bounds].size.height > 480.0);
    if (isIPhone5) {
        [backgroundImage setImage:[UIImage imageNamed:@"launch-i5.png"]];
    } else if (isIPhone4) {
        [backgroundImage setImage:[UIImage imageNamed:@"launch-iphone-hd.png"]];
    }else{ // ipad
        [backgroundImage setImage:[UIImage imageNamed:@"launch-ipad.png"]];
    }
    
    [backgroundImage setContentMode:UIViewContentModeScaleAspectFill];
    [self.view insertSubview:backgroundImage atIndex:0];
    
    self.view.tintColor = [UIColor whiteColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textField.delegate = self;
    [self initializeBackgroundImage];
    
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
