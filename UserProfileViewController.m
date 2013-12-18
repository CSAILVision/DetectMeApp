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
    
    NSArray *_userValues;
    NSArray *_userKeys;
    
}

@end

@implementation UserProfileViewController

- (void) initializeUserProperties
{

    NSString *numberOfDetectors = [NSString stringWithFormat:@"%d",[self.currentUser.detectors count]];
    NSString *numberOfAnnotatedImages = [NSString stringWithFormat:@"%d",[self.currentUser.annotatedImages count]];
    
    
    _userValues = [NSArray arrayWithObjects:
                       numberOfDetectors, numberOfAnnotatedImages, nil];
    
    _userKeys = [NSArray arrayWithObjects:
                     @"Number of detectors",@"Number of annotated images", nil];
}


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
    [self initializeUserProperties];
    [self outputValuesForCurrentUser];
}


- (void) outputValuesForCurrentUser
{
    self.usernameLabel.text = self.currentUser.username;
    if(self.currentUser.image)
        self.imageView.image = [UIImage imageWithData:self.currentUser.image];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_userKeys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
            
    cell.textLabel.text = [_userKeys objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.textLabel.textColor = [UIColor colorWithWhite:0.67 alpha:1];
    cell.detailTextLabel.text = [_userValues objectAtIndex:indexPath.row];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
    
    return cell;
}




@end
