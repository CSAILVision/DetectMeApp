//
//  UserProfileViewController.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 07/10/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "UserProfileViewController.h"
#import "AuthHelper.h"

@interface UserProfileViewController ()

@end

@implementation UserProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
