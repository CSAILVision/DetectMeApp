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
    UIImagePickerController *_imagePicker;
}

@end

@implementation UserProfileViewController

- (void) initializeImagePicker
{
//    dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
//    dispatch_async(queue, ^{
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        _imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        _imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        _imagePicker.navigationBarHidden = YES;
        _imagePicker.delegate = self;
//    });
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeImagePicker];
    
    [self outputValuesForCurrentUser];
}


- (void) outputValuesForCurrentUser
{
    self.usernameLabel.text = self.currentUser.username;
    self.imageView.image = [UIImage imageWithData:self.currentUser.image];
    if(!self.imageView.image) self.imageView.image = [UIImage imageNamed:@"no_image.jpg"];
    [self.wifiOnlyButton setOn:self.currentUser.isWifiOnly.boolValue];
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

- (IBAction)wifiOnlyAction:(UISwitch *)sender
{
    self.currentUser.isWifiOnly = @(sender.on);
}


#pragma mark -
#pragma mark ImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.imageView.image = image;
    self.currentUser.image = UIImageJPEGRepresentation(image, 0.5);
    [_imagePicker dismissViewControllerAnimated:YES completion:nil];
    
    ShareDetector *sh = [[ShareDetector alloc] init];
    [sh shareProfilePicture:image forUsername:self.currentUser.username];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [_imagePicker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark TableViewDataSource and Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}



@end
