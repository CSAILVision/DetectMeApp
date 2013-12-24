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

static inline int max(int x, int y) { return (x <= y ? y : x); }

@interface UserProfileViewController ()
{
    UIImagePickerController *_imagePicker;
    
    NSArray *_userValues;
    NSArray *_userKeys;
    
    NSArray *_userConfigurationControl;
    NSArray *_userConfigurationDescription;
}

@end

@implementation UserProfileViewController

- (void) initializeUserProperties
{

    NSString *numberOfDetectors = [NSString stringWithFormat:@"%d",[self.currentUser.detectors count]];
    int num = max(self.currentUser.numberServerImages.integerValue, self.currentUser.annotatedImages.count);
    NSString *numberOfAnnotatedImages = [NSString stringWithFormat:@"%d",num];
    
    
    _userValues = [NSArray arrayWithObjects:
                       numberOfDetectors, numberOfAnnotatedImages, nil];
    
    _userKeys = [NSArray arrayWithObjects:
                     @"Number of detectors",@"Number of annotated images", nil];
}


- (void) initializeUserConfiguration
{
    
    UISwitch *wifiSwitch = [[UISwitch alloc] init];
    [wifiSwitch setOn:self.currentUser.isWifiOnly.boolValue];
    [wifiSwitch targetForAction:@selector(wifiOnlyAction:) withSender:self];
    
    _userConfigurationControl = [NSArray arrayWithObjects:
                   wifiSwitch, nil];
    
    _userConfigurationDescription = [NSArray arrayWithObjects:
                 @"Wifi Only:", nil];
}


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
    [self initializeUserProperties];
    [self initializeUserConfiguration];
    [self outputValuesForCurrentUser];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // slower method
    [self initializeImagePicker];
}

- (void) outputValuesForCurrentUser
{
    self.usernameLabel.text = self.currentUser.username;
    if(self.currentUser.image)
        self.imageView.image = [UIImage imageWithData:self.currentUser.image];
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
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return @"Configuration";
        
    }else if(section == 1){
        return @"Details";
        
    }else return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows;
    switch (section) {
        case 0:
            rows = _userConfigurationControl.count;
            break;
            
        case 1:
            rows = _userKeys.count;
            break;
            
    }
    return rows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"UserConfiguration" forIndexPath:indexPath];
            cell.textLabel.text = [_userConfigurationDescription objectAtIndex:indexPath.row];
            cell.textLabel.font = [UIFont systemFontOfSize:12];
            cell.textLabel.textColor = [UIColor colorWithWhite:0.67 alpha:1];
            cell.accessoryView = [_userConfigurationControl objectAtIndex:indexPath.row];
            
            break;
            
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetail" forIndexPath:indexPath];
            cell.textLabel.text = [_userKeys objectAtIndex:indexPath.row];
            cell.textLabel.font = [UIFont systemFontOfSize:12];
            cell.textLabel.textColor = [UIColor colorWithWhite:0.67 alpha:1];
            cell.detailTextLabel.text = [_userValues objectAtIndex:indexPath.row];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
            
            break;
    }
    
    
    
    
    return cell;
}




@end
