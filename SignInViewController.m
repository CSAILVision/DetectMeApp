//
//  SignInViewController.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 04/10/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "SignInViewController.h"
#import "ManagedDocumentHelper.h"

@interface SignInViewController ()
{
    NSString *_username;
    NSString *_password;
    AuthHelper *_authHelper;
}

@end

@implementation SignInViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    _authHelper = [[AuthHelper alloc] init];
    _authHelper.delegate = self;
    
    self.activityIndicator.hidden = YES;
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isUserStored"]){
        _username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
        _password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
        [self signIn];
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
    _username = self.userNameTextField.text;
    _password = self.passwordTextField.text;
    [self signIn];
}

#pragma mark -
#pragma mark AuthHelperDelegate

- (void) signInCompleted
{
    [self stopAnimation];
    [self performSegueWithIdentifier: @"SignInComplete" sender: self];
}

- (void) requestFailedWithErrorMessages: (NSDictionary *)errorMessages;
{
    [self stopAnimation];
    NSLog(@"Error: %@", errorMessages);
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
