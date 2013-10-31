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
#import "ShareDetector.h"

@interface UserProfileViewController ()
{
    User *_currentUser;
    UIManagedDocument *_detectorDatabase;
    UIImagePickerController *_imagePicker;
}

@end

@implementation UserProfileViewController

- (void) initializeImagePicker
{
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    _imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    _imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    _imagePicker.navigationBarHidden = YES;
    _imagePicker.delegate = self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeImagePicker];
    
    _detectorDatabase = [ManagedDocumentHelper sharedDatabaseUsingBlock:^(UIManagedDocument *document){}];
    [self outputValuesForCurrentUser];
}

- (void) outputValuesForCurrentUser
{
    _currentUser = [User getCurrentUserInManagedObjectContext:_detectorDatabase.managedObjectContext];
    self.usernameLabel.text = _currentUser.username;
    self.emailLabel.text = _currentUser.email;
    self.imageView.image = [UIImage imageWithData:_currentUser.image];
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

- (IBAction)takePictureAction:(id)sender
{
    [_imagePicker takePicture];
    [self presentViewController:_imagePicker animated:YES completion:nil];
}


#pragma mark -
#pragma mark ImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.imageView.image = image;
    _currentUser.image = UIImageJPEGRepresentation(image, 0.5);
    [_imagePicker dismissViewControllerAnimated:YES completion:nil];
    
    ShareDetector *sh = [[ShareDetector alloc] init];
    [sh shareProfilePicture:image forUsername:_currentUser.username];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [_imagePicker dismissViewControllerAnimated:YES completion:nil];
}

@end
