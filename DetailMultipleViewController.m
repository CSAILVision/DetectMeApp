//
//  DetailMultipleViewController.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 23/10/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "DetailMultipleViewController.h"
#import "Detector.h"
#import "ManagedDocumentHelper.h"
#import "User.h"
#import "DetailViewController.h"

@interface DetailMultipleViewController ()
{
    UIManagedDocument *_detectorDatabase;
    NSArray *_singleDetectors;
}
@end

@implementation DetailMultipleViewController


- (void) loadMultiplePictures
{
    NSArray *imageViews = [NSArray arrayWithObjects:self.imageView1, self.imageView2, self.imageView3, self.imageView4, nil];
    for(int i=0; i<4; i++)
        if(i<_singleDetectors.count){
            UIImageView *imageView = [imageViews objectAtIndex:i];
            imageView.image = [UIImage imageWithData:[(Detector *)[_singleDetectors objectAtIndex:i] image]];
        }
    
    self.multipleDetector.image = UIImageJPEGRepresentation([self captureImageFromView:self.captureView], 0.5);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.nameLabel.text = [NSString stringWithFormat:@"%@ - %@", self.multipleDetector.name, self.multipleDetector.objectID];
    
    if(!_detectorDatabase)
        _detectorDatabase = [ManagedDocumentHelper sharedDatabaseUsingBlock:^(UIManagedDocument *document) {}];
    
    NSString *text = @"Detectors:";
    for(Detector *detector in self.multipleDetector.detectors)
        text = [text stringByAppendingString:[NSString stringWithFormat:@" - %@", detector.name]];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _singleDetectors = [self.multipleDetector.detectors allObjects];
    
    [self loadMultiplePictures];
}

#pragma mark -
#pragma mark IActions

- (IBAction)deleteAction:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:@"Delete"
                                              otherButtonTitles:nil];
    
    [sheet showInView:self.view];
}


#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [self deleteDetector];
    }
}

#pragma mark -
#pragma mark UITableViewDataSource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows;
    switch (section) {
        case 0:
            rows = 1;
            break;
            
        case 1:
            rows = _singleDetectors.count;
            break;
            
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"MultipleDetectorAction" forIndexPath:indexPath];
            break;
            
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:@"MultipleDetectorDetail" forIndexPath:indexPath];
            
            Detector *detector = [_singleDetectors objectAtIndex:indexPath.row];
            
            cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", detector.name, detector.serverDatabaseID];
            cell.textLabel.font = [UIFont systemFontOfSize:17];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@", detector.user.username];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
            
            break;
            
    }
    
    
    return cell;
}

#pragma mark -
#pragma mark Segue


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ExecuteDetectorMultiple"]) {
        NSArray *detectors = [self.multipleDetector.detectors allObjects];
        [(ExecuteDetectorViewController *)segue.destinationViewController setDetectors:detectors];
        
    }else if([[segue identifier] isEqualToString:@"SingleDetectorDetail"]){
        DetailViewController *detailVC = (DetailViewController *) segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        detailVC.detector = [_singleDetectors objectAtIndex:indexPath.row];
    }
}


#pragma mark -
#pragma mark Private Methods

- (void) deleteDetector
{
    [_detectorDatabase.managedObjectContext deleteObject:self.multipleDetector];
    [self.navigationController popViewControllerAnimated:YES];
    
    
}

- (UIImage *) captureImageFromView:(UIView *) captureView
{
    CGRect rect = [captureView bounds];
    UIGraphicsBeginImageContextWithOptions(rect.size,YES,0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [captureView.layer renderInContext:context];
    UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return capturedImage;
}

 

@end
