//
//  UserProfileViewController.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 07/10/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface UserProfileViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) User *currentUser;


- (IBAction)logOutAction:(id)sender;
- (IBAction)takePictureAction:(id)sender;


@end
