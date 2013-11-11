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
#import "AnnotatedImage.h"
#import "Box.h"
#import "User.h"
#import "ShareDetector.h"
#import "Rating+Create.h"
#import "ManagedDocumentHelper.h"

@interface DetailViewController ()
{
    BOOL _isOwner;
    BOOL _detectorHasChanged;
    ShareDetector *_shareDetector;
    UIManagedDocument *_detectorDatabase;
    Rating *_rating;
    
    NSArray *_detectorKeys;
    NSArray *_detectorValues;
}

@end

@implementation DetailViewController


- (void) setDetectorProperties
{
    
    NSString *averageRating = _detector.averageRating ? [NSString stringWithFormat:@"%@", _detector.averageRating]:@"null";
    NSString *numberOfImages = [NSString stringWithFormat:@"%d", _detector.annotatedImages.count];
    NSString *createdAt = @"Null";
    NSString *updatedAt = @"Null";
    
    _detectorValues = [NSArray arrayWithObjects:
                                            averageRating,
                                            numberOfImages,
                                            createdAt,
                                            updatedAt,nil];
    
    _detectorKeys = [NSArray arrayWithObjects:
                                            @"Average Rating",
                                            @"Number of images",
                                            @"Created at",
                                            @"Updated at",nil];
}

- (void) loadDetectorDetails
{
    self.nameLabel.text = [NSString stringWithFormat:@"%@ - %@",self.detector.name, self.detector.serverDatabaseID];
    self.authorLabel.text = [NSString stringWithFormat:@"by %@", self.detector.user.username];
    
    self.imageView.image =[UIImage imageWithData:self.detector.image];
    self.isPublicControl.selectedSegmentIndex = self.detector.isPublic.boolValue ? 0:1;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadDetectorDetails];
    
    _isOwner = [self.detector.user.username isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:USER_DEFAULTS_USERNAME]];
    if(!_isOwner){
        self.deleteButton.hidden = YES;
        self.isPublicControl.hidden = YES;
    }
    
    _shareDetector = [[ShareDetector alloc] init];

    if(!_detectorDatabase)
        _detectorDatabase = [ManagedDocumentHelper sharedDatabaseUsingBlock:^(UIManagedDocument *document){}];
    
    
    _rating = [Rating ratingforDetector:self.detector inManagedObjectContext:_detectorDatabase.managedObjectContext];
    if(_rating.rating.integerValue != 0)
        self.ratingControl.selectedSegmentIndex = _rating.rating.integerValue - 1;
    
    [self setDetectorProperties];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows;
    switch (section) {
        case 0:
            rows = 1;
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
            cell = [tableView dequeueReusableCellWithIdentifier:@"DetectorAction" forIndexPath:indexPath];
            break;
            
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DetectorDetail" forIndexPath:indexPath];
            
            cell.textLabel.text = [_detectorKeys objectAtIndex:indexPath.row];
            cell.textLabel.font = [UIFont systemFontOfSize:12];
            cell.detailTextLabel.text = [_detectorValues objectAtIndex:indexPath.row];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
            
            break;
            
    }

    
    return cell;
}


#pragma mark -
#pragma mark IBActions

- (IBAction)deleteAction:(id)sender
{
    [_shareDetector deleteDetector:self.detector];
    [self.delegate deleteDetector:self.detector];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)isPublicAction:(UISegmentedControl *) isPublicControl;
{
    BOOL isPublic = isPublicControl.selectedSegmentIndex == 0 ? YES:NO;
    self.detector.isPublic = @(isPublic);
    _detectorHasChanged = YES;
    
}

- (IBAction)ratingAction:(UISegmentedControl *)ratingControl
{
    _rating.rating = @(ratingControl.selectedSegmentIndex + 1);
    [_shareDetector shareRating:_rating];
}




@end
