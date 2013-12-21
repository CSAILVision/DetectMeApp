//
//  SignInViewController.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 04/10/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "SignInViewController.h"
#import "ManagedDocumentHelper.h"
#import "UIViewController+ShowAlert.h"

@interface SignInViewController ()
{
    NSString *_username;
    NSString *_password;
    AuthHelper *_authHelper;
}

@end

@implementation SignInViewController

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

    _authHelper = [[AuthHelper alloc] init];
    _authHelper.delegate = self;
    
    self.activityIndicator.hidden = YES;
    [self initializeBackgroundImage];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Avoid asking the server if I had store the previous session
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isUserStored"]){
        _username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
        _password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
        
        [self stopAnimation];
        [self performSegueWithIdentifier: @"SignInComplete" sender:self];
    }
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.userNameTextField.text = @"";
    self.passwordTextField.text = @"";
}

#pragma mark -
#pragma mark IBActions

- (IBAction)signInAction:(id)sender
{
    [self.view endEditing:YES];
    _username = self.userNameTextField.text;
    _password = self.passwordTextField.text;
    [self signIn];
}

#pragma mark -
#pragma mark AuthHelperDelegate

- (void) signInCompleted
{
    // Once the login is accepted, get and update user information from the server
    UserFetcher *uf = [[UserFetcher alloc] init];
    uf.delegate = self;
    [uf fetchAndStoreUserWithUsername:_username];
}


- (void) requestFailedWithErrorTitle:(NSString *)title errorMessage:(NSString *)message;
{
    [self stopAnimation];
    [self showAlertWithTitle:title andDescription:message];
}

#pragma mark -
#pragma mark UserFetcherDelegate

- (void) obtainedUser:(NSDictionary *)userJSON
{
    [self stopAnimation];
    [self performSegueWithIdentifier: @"SignInComplete" sender:self];
}

- (void) downloadError:(NSString *)error
{
    [self showAlertWithTitle:@"Error" andDescription:error];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([textField.placeholder isEqualToString:@"username"])
        [self.passwordTextField becomeFirstResponder];
    
    else if([textField.placeholder isEqualToString:@"password"])
        [self signInAction:self];
    
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

- (void) signIn
{
    [self startAnimation];
    [_authHelper signInUsername:_username forPassword:_password];
}

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
