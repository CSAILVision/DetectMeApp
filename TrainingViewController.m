//
//  TrainingViewController.m
//  DetectTube
//
//  Created by Josep Marc Mingot Hidalgo on 20/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "TrainingViewController.h"
#import "Box.h"
#import "DetectorWrapper.h"
#import "Detector.h"
#import "AnnotatedImage.h"
#import "User+Create.h"
#import "UIImage+ImageAveraging.h"
#import "ManagedDocumentHelper.h"
#import "ShareDetector.h"
#import "NSArray+JSONHelper.h"
#import "SupportVector.h"
#import "TakePictureViewController.h"

@interface TrainingViewController()
{
    DetectorTrainer *_detectorTrainer;
    ShareDetector *_shareDetector;
}

@end


@implementation TrainingViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.finishButton.hidden = YES;
    [self.activityIndicator startAnimating];
    [self.progressView setProgress:0];
    
    _detectorTrainer.detector = self.detector; //in case previous detector
    [_detectorTrainer trainDetector];
    _detectorTrainer.delegate = self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!self.detectorDatabase){
        self.detectorDatabase = [ManagedDocumentHelper sharedDatabaseUsingBlock:^(UIManagedDocument *document){
            [self useDocument:document];
        }];
    }
}

- (void) useDocument:(UIManagedDocument *)document
{
}




- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.detector = nil;
}



#pragma mark -
#pragma mark DetectorTrainnerDelegate


- (void) trainDidEndWithDetector:(DetectorWrapper *)detectorWrapper
{
    NSLog(@"finished training with detector:%@",_detectorTrainer.name);
    
    // Create entity
    NSManagedObjectContext *context = self.detectorDatabase.managedObjectContext;

    // 3 possibilities:
    // (1) Create a new detector. POST.
    // (2) Update a detector for which the current user is the owner. PUT.
    // (3) Update the detector of other user. Creates a brand new detector. POST.
    User *currentUser = [User getCurrentUserInManagedObjectContext:context];
    BOOL isToUpdate = (self.detector.user == currentUser && self.detector.serverDatabaseID>0); // PUT (case(2))
    
    Detector *detector = self.detector;
    for(AnnotatedImage *annotatedImage in self.detector.annotatedImages)
        [context deleteObject:annotatedImage];
    
    if(!isToUpdate){ // case (1) and (3)
        detector = [NSEntityDescription insertNewObjectForEntityForName:@"Detector" inManagedObjectContext:context];
    }
    
    detector.name = _detectorTrainer.name;
    detector.targetClass = _detectorTrainer.targetClass;
    detector.user = currentUser;
    detector.parentID = isToUpdate? detector.parentID : self.detector.serverDatabaseID;
    detector.isPublic = [NSNumber numberWithBool:_detectorTrainer.isPublic];
    detector.image = UIImageJPEGRepresentation(_detectorTrainer.averageImage, 0.5);
    detector.createdAt = [NSDate date];
    detector.updatedAt = [NSDate date];
    detector.weights = [detectorWrapper.weights convertToJSON];
    detector.sizes = [detectorWrapper.sizes convertToJSON];
    detector.supportVectors = [SupportVector JSONFromSupportVectors:detectorWrapper.supportVectors];
    
    
    // AnnotatedImages
    NSArray *images = self.detectorTrainer.images;
    NSArray *boxes = self.detectorTrainer.boxes;
    
    for(int i=0; i<images.count; i++){
        AnnotatedImage *annotatedImage = [NSEntityDescription insertNewObjectForEntityForName:@"AnnotatedImage" inManagedObjectContext:context];
        
        UIImage *image = [images objectAtIndex:i];
        Box *box = [boxes objectAtIndex:i];

        annotatedImage.image = UIImageJPEGRepresentation(image, 0.5);
        annotatedImage.imageHeight = @(image.size.height);
        annotatedImage.imageWidth = @(image.size.width);
        
        CGRect boxRect = [box getRectangleForBox];
        annotatedImage.boxHeight = @(boxRect.size.height);
        annotatedImage.boxWidth = @(boxRect.size.width);
        annotatedImage.boxX = @(boxRect.origin.x);
        annotatedImage.boxY = @(boxRect.origin.y);
        annotatedImage.user = currentUser;
        annotatedImage.detector = detector;

    }
    
    // send detector
    _shareDetector = [[ShareDetector alloc] init];
    [_shareDetector shareDetector:detector toUpdate:isToUpdate];
    
    self.imageView.image = _detectorTrainer.averageImage;
    
    [self.activityIndicator stopAnimating];
    self.finishButton.hidden = NO;
}

- (void) updateProgess:(float) progress
{
    [self.progressView setProgress:progress];
}

#pragma mark -
#pragma mark IBActions

- (IBAction)finishAction:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.tabBarController setSelectedIndex:0];
}

@end
