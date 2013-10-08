//
//  UserProfileViewController.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 07/10/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "UserProfileViewController.h"
#import "AuthHelper.h"
#import "ManagedDocumentHelper.h"
#import "User+Create.h"

@interface UserProfileViewController ()
{
    User *_currentUser;
    UIManagedDocument *_detectorDatabase;
}

@end

@implementation UserProfileViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _detectorDatabase = [ManagedDocumentHelper sharedDatabaseUsingBlock:^(UIManagedDocument *document){}];
    [self outputValuesForCurrentUser];
}

- (void) outputValuesForCurrentUser
{
    _currentUser = [User getCurrentUserInManagedObjectContext:_detectorDatabase.managedObjectContext];
    self.usernameLabel.text = _currentUser.username;
    self.emailLabel.text = _currentUser.email;
}



#pragma mark -
#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"LogOut"]) {
        [AuthHelper signOut];
    }

}


- (IBAction)logOutAction:(id)sender
{
    [AuthHelper signOut];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
