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
}

@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.detector.name;
    self.imageView.image =[UIImage imageWithData:self.detector.image];
    self.authorLabel.text = [NSString stringWithFormat:@"Author: %@", self.detector.user.username];
    self.publicLabel.text = self.detector.isPublic.boolValue ? @"Public" : @"Private";
    self.ratingLabel.text = [NSString stringWithFormat:@"%@", self.detector.averageRating];
    
    _isOwner = [self.detector.user.username isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:USER_DEFAULTS_USERNAME]];
    if(!_isOwner){
        self.deleteButton.hidden = YES;
//        self.shareButton.hidden = YES;
    }
    
    _shareDetector = [[ShareDetector alloc] init];

    if(!_detectorDatabase)
        _detectorDatabase = [ManagedDocumentHelper sharedDatabaseUsingBlock:^(UIManagedDocument *document){}];
    
    
    _rating = [Rating ratingforDetector:self.detector inManagedObjectContext:_detectorDatabase.managedObjectContext];
    if(_rating.rating.integerValue != 0)
        self.ratingControl.selectedSegmentIndex = _rating.rating.integerValue - 1;
    
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
        [(ExecuteDetectorViewController *)segue.destinationViewController setDetector:self.detector];
        
    }else if([[segue identifier] isEqualToString:@"Retrain"]){
        TrainingImagesCollectionViewController *vc = (TrainingImagesCollectionViewController *)segue.destinationViewController;
        vc.detector = self.detector;
    }
}

#pragma mark -
#pragma mark IBActions

- (IBAction)deleteAction:(id)sender
{
    [_shareDetector deleteDetector:self.detector];
    [self.delegate deleteDetector:self.detector];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)isPublicAction:(id)sender
{

}

- (IBAction)ratingAction:(UISegmentedControl *)ratingControl
{
    _rating.rating = @(ratingControl.selectedSegmentIndex + 1);
    [_shareDetector shareRating:_rating];
}


@end
