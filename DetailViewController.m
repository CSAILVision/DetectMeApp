//
//  DetailViewController.m
//  DetectTube
//
//  Created by Josep Marc Mingot Hidalgo on 25/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "DetailViewController.h"
#import "ExecuteDetectorViewController.h"
#import "TrainingImagesCollectionViewController.h"
#import "ConstantsServer.h"
#import "Box.h"
#import "User.h"
#import "Rating+Create.h"
#import "ManagedDocumentHelper.h"
#import "UIViewController+ShowAlert.h"
#import "AnnotatedImage.h"


@interface DetailViewController ()
{
    BOOL _isOwner;
    BOOL _detectorHasChanged;
    ShareDetector *_shareDetector;
    UIManagedDocument *_detectorDatabase;
    Rating *_rating;
    
    NSArray *_detectorKeys;
    NSArray *_detectorValues;
    
    NSMutableArray *_detectorConfigurationControl;
    NSMutableArray *_detectorConfigurationDescription;
    
    BOOL _successDelete;
    
    int _numRatings;
    float _averageRating;
}

@end

@implementation DetailViewController


- (void) setDetectorProperties
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy 'at' HH:mm"];
    
    
    NSString *averageRating = _detector.averageRating ? [NSString stringWithFormat:@"%@ (%@)", _detector.averageRating, _detector.numberRatings]:@"no ratings yet";
    NSString *numberOfImages = [NSString stringWithFormat:@"%d", _detector.annotatedImages.count];
    NSString *createdAt = [formatter stringFromDate:_detector.createdAt];
    NSString *updatedAt = _detector.updatedAt ? [formatter stringFromDate:_detector.updatedAt] : createdAt;
    NSString *serverNumber = [NSString stringWithFormat:@"%@",_detector.serverDatabaseID];
    
    _detectorValues = [NSArray arrayWithObjects:
                                            averageRating,
                                            numberOfImages,
                                            serverNumber,
                                            createdAt,
                                            updatedAt,nil];
    
    _detectorKeys = [NSArray arrayWithObjects:
                                            @"Average Rating (Number ratings)",
                                            @"Number of own images",
                                            @"Server ID number",
                                            @"Created at",
                                            @"Updated at",nil];
}

- (void) setDetectorConfiguration
{
    _detectorConfigurationControl = [[NSMutableArray alloc] init];
    _detectorConfigurationDescription = [[NSMutableArray alloc] init];
    
    // sharing switch
    if(_isOwner){
        UISegmentedControl *shareSC = [[UISegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        [shareSC addTarget:self action:@selector(isPublicAction:) forControlEvents:UIControlEventValueChanged];
        [shareSC insertSegmentWithTitle:@"Public" atIndex:0 animated:YES];
        [shareSC insertSegmentWithTitle:@"Private" atIndex:1 animated:YES];
        shareSC.selectedSegmentIndex = self.detector.isPublic.boolValue ? 0:1;
        
        [_detectorConfigurationDescription addObject:@"Share:"];
        [_detectorConfigurationControl addObject:shareSC];
    }
    
    // rate switch
    UISegmentedControl *ratingSC = [[UISegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 140, 30)];
    [ratingSC addTarget:self action:@selector(ratingAction:) forControlEvents:UIControlEventValueChanged];
    [ratingSC insertSegmentWithTitle:@"1" atIndex:0 animated:YES];
    [ratingSC insertSegmentWithTitle:@"2" atIndex:1 animated:YES];
    [ratingSC insertSegmentWithTitle:@"3" atIndex:2 animated:YES];
    [ratingSC insertSegmentWithTitle:@"4" atIndex:3 animated:YES];
    [ratingSC insertSegmentWithTitle:@"5" atIndex:4 animated:YES];
    _rating = [Rating ratingforDetector:self.detector inManagedObjectContext:_detectorDatabase.managedObjectContext];
    if(_rating.rating.integerValue != 0)
        ratingSC.selectedSegmentIndex = _rating.rating.integerValue - 1;
    
    [_detectorConfigurationDescription addObject:@"Rate:"];
    [_detectorConfigurationControl addObject:ratingSC];
}

- (void) loadDetectorDetails
{
    self.nameLabel.text = [NSString stringWithFormat:@"%@",self.detector.name];
    [self.nameLabel sizeToFit];
    self.authorLabel.text = [NSString stringWithFormat:@"by %@", self.detector.user.username];
    self.imageView.image =[UIImage imageWithData:self.detector.image];
    _numRatings = self.detector.numberRatings.integerValue;
    _averageRating = self.detector.numberRatings.integerValue;
}

- (void) initializeForOwner
{
    _isOwner = [self.detector.user.username isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:USER_DEFAULTS_USERNAME]];
    if(!_isOwner){
        self.deleteButton.hidden = YES;
    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadDetectorDetails];
    [self initializeForOwner];
    
    _shareDetector = [[ShareDetector alloc] init];
    _shareDetector.delegate = self;

    if(!_detectorDatabase)
        _detectorDatabase = [ManagedDocumentHelper sharedDatabaseUsingBlock:^(UIManagedDocument *document){}];
    
    self.activityIndicator.hidden = YES;
    
    [self setDetectorProperties];
    [self setDetectorConfiguration];
}


- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if(_detectorHasChanged){
        NSLog(@"Updating detector to the server...");
        [_shareDetector shareDetector:self.detector toUpdate:YES];
    }
    
}


#pragma mark -
#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ExecuteDetector"]) {
        NSArray *detectors = [NSArray arrayWithObject:self.detector];
        [(ExecuteDetectorViewController *)segue.destinationViewController setDetectors:detectors];
        
    }else if([[segue identifier] isEqualToString:@"TestDetector"]){
        NSArray *detectors = [NSArray arrayWithObject:self.detector];
        ExecuteDetectorViewController *executeDetectorVC = (ExecuteDetectorViewController *) segue.destinationViewController;
        executeDetectorVC.detectors = detectors;
        executeDetectorVC.isTest = YES;
        
        
    }else if([[segue identifier] isEqualToString:@"Retrain"]){
        TrainingImagesCollectionViewController *vc = (TrainingImagesCollectionViewController *)segue.destinationViewController;
        vc.detector = self.detector;
    }
}

#pragma mark -
#pragma mark UITableViewDelegate

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
            rows = _detectorConfigurationControl.count;
            break;
            
        case 1:
            rows = _detectorKeys.count;
            break;
            
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DetectorProperties" forIndexPath:indexPath];
            cell.textLabel.text = [_detectorConfigurationDescription objectAtIndex:indexPath.row];
            cell.textLabel.font = [UIFont systemFontOfSize:12];
            cell.textLabel.textColor = [UIColor colorWithWhite:0.67 alpha:1];
            cell.accessoryView = [_detectorConfigurationControl objectAtIndex:indexPath.row];
            break;
            
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DetectorDetail" forIndexPath:indexPath];
            
            cell.textLabel.text = [_detectorKeys objectAtIndex:indexPath.row];
            cell.textLabel.font = [UIFont systemFontOfSize:12];
            cell.textLabel.textColor = [UIColor colorWithWhite:0.67 alpha:1];
            cell.detailTextLabel.text = [_detectorValues objectAtIndex:indexPath.row];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
            
            break;
            
    }

    
    return cell;
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [self deleteDetector];
    }
}


#pragma mark -
#pragma mark IBActions


- (IBAction)deleteAction:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:@"Delete"
                                              otherButtonTitles:nil];
    
    [sheet showInView:self.view];
}

- (IBAction)isPublicAction:(UISegmentedControl *) isPublicControl;
{
    BOOL isPublic = isPublicControl.selectedSegmentIndex == 0 ? YES:NO;
    self.detector.isPublic = @(isPublic);
    _detectorHasChanged = YES;
    
}

- (IBAction)ratingAction:(UISegmentedControl *)ratingControl
{
    // send the rating
    _rating.rating = @(ratingControl.selectedSegmentIndex + 1);
    [_shareDetector shareRating:_rating];
    
    // update the rating
    self.detector.numberRatings = [NSNumber numberWithInt:_numRatings+1];
    self.detector.averageRating = @((_averageRating*_numRatings + _rating.rating.integerValue)/(_numRatings + 1));
    [self setDetectorProperties];
    [self.tableview reloadData];
}


#pragma mark -
#pragma mark Share detector delegate

- (void) detectorDeleted
{
    [_detectorDatabase.managedObjectContext deleteObject:self.detector];
    [self stopActivityIndicator];
    
    _successDelete = YES;
    
    //show alert
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                    message:@"The detector has been deleted."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void) requestFailedWithErrorTitle:(NSString *)title errorMessage:(NSString *) message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void) networkNotReachable
{
    [self showAlertWithTitle:@"Network not reachable" andDescription:@"The detector could not be deleted from the server"];
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(_successDelete)
        [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Private Methods

- (void) deleteDetector
{
    [_shareDetector deleteDetector:self.detector];
    [self startActivityIndicator];

}

- (void) startActivityIndicator
{
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
}

- (void) stopActivityIndicator
{
    self.activityIndicator.hidden = YES;
    [self.activityIndicator stopAnimating];
}



@end
