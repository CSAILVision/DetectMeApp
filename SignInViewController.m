//
//  SignInViewController.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 04/10/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "SignInViewController.h"

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

- (void) signInCompletedWithToken:(NSString *)token
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:TRUE forKey:@"isUserStored"];
    [defaults setObject:token forKey:@"token"];
    [defaults setObject:_username forKey:@"username"];
    [defaults setObject:_password forKey:@"password"];
    [defaults synchronize];
    
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
    
    NSLog(@"Token received:%@", token);
    
    [self performSegueWithIdentifier: @"SignInComplete" sender: self];
}

- (void) signInFailedWithErrorMessage:(NSString *)errorMessage
{
    NSLog(@"Error: %@", errorMessage);
}

#pragma mark -
#pragma mark Private Methods

- (void) signIn
{
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    [_authHelper singInUsername:_username forPassword:_password];
}


@end
