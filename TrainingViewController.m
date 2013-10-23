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
#import "Detector+Server.h"
#import "AnnotatedImage+Create.h"
#import "ConstantsServer.h"
#import "UIViewController+ShowAlert.h"

@interface TrainingViewController()
{
    ShareDetector *_shareDetector;
    Detector *_detector;
    NSUInteger _annotatedImagesSent;
}

@end


@implementation TrainingViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.finishButton.hidden = YES;
    [self.activityIndicator startAnimating];
    [self.progressView setProgress:0];
    
    [self.detectorTrainer trainDetector];
    self.detectorTrainer.delegate = self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!self.detectorDatabase){
        self.detectorDatabase = [ManagedDocumentHelper sharedDatabaseUsingBlock:^(UIManagedDocument *document){}];
    }
}



#pragma mark -
#pragma mark DetectorTrainnerDelegate


- (void) trainDidEndWithDetector:(DetectorWrapper *)detectorWrapper
{
    NSLog(@"finished training with detector:%@",self.detectorTrainer.name);
    
    // Create entity
    NSManagedObjectContext *context = self.detectorDatabase.managedObjectContext;

    self.detectorTrainer.weights = detectorWrapper.weights;
    self.detectorTrainer.sizes = detectorWrapper.sizes;
    self.detectorTrainer.supportVectors = detectorWrapper.supportVectors;
    
    // 3 possibilities:
    // (1) Create a new detector. POST.
    // (2) Update a detector for which the current user is the owner. PUT.
    // (3) Update the detector of other user. Creates a brand new detector. POST.
    User *currentUser = [User getCurrentUserInManagedObjectContext:context];
    BOOL isToUpdate = (self.detectorTrainer.previousDetector.user == currentUser && self.detectorTrainer.previousDetector.serverDatabaseID>0); // PUT (case(2))
    
    _detector = [Detector detectorWithDetectorTrainer:self.detectorTrainer
                                             toUpdate:isToUpdate
                               inManagedObjectContext:context];
        
    
    // set to the current detector
    for(AnnotatedImage *aImage in self.detectorTrainer.annotatedImages)
        aImage.detector = _detector;
    
    // send detector
    _shareDetector = [[ShareDetector alloc] init];
    _shareDetector.delegate = self;
    [_shareDetector shareDetector:_detector toUpdate:isToUpdate];
    
    self.imageView.image = self.detectorTrainer.averageImage;
    
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

#pragma mark -
#pragma mark ShareDetectorDelegate

- (void) detectorDidSent
{
    _annotatedImagesSent = 0;
    for(AnnotatedImage *annotatedImage in _detector.annotatedImages){
        if(!annotatedImage.isSent.boolValue){
            _annotatedImagesSent++;
            _shareDetector = [[ShareDetector alloc] init]; //distinct memory spaces
            _shareDetector.delegate = self;
            [_shareDetector shareAnnotatedImage:annotatedImage];
        }
    }
}

- (void) annotatedImageDidSent
{
    _annotatedImagesSent--;
    if(_annotatedImagesSent==0)
        // Forcing save to avoid losing the detector and annotated images if closed before auto-saving
        [self.detectorDatabase saveToURL:self.detectorDatabase.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {}];
}

//- (void) endDetectorUploading:(NSDictionary *)detectorJSON
//{
//    _detector.serverDatabaseID = [detectorJSON objectForKey:SERVER_DETECTOR_ID];
//    _detector.isSent = @(TRUE);
//    
//    NSLog(@"detector %@ sent", _detector.name);
//    
//    // send images
//    _annotatedImagesSent = 0;
//    for(AnnotatedImage *annotatedImage in _detector.annotatedImages){
//        _shareDetector = [[ShareDetector alloc] init]; //distinct memory spaces
//        _shareDetector.delegate = self;
//        [_shareDetector shareAnnotatedImage:annotatedImage];
//    }
//}
//
//- (void) endAnnotatedImageUploading:(NSDictionary *)annotatedImageJSON
//{
//    _annotatedImagesSent++;
//    NSLog(@"%d images sent", _annotatedImagesSent);
//    
//    if(_annotatedImagesSent == _detector.annotatedImages.count){ // all the images sent
//        for(AnnotatedImage *annotatedImage in _detector.annotatedImages)
//            annotatedImage.isSent = @(TRUE);
//        
//        // Forcing save to avoid losing the detector and annotated images if closed before auto-saving
//        [self.detectorDatabase saveToURL:self.detectorDatabase.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {}];
//    }
//    
//    
//    // Forcing save to avoid losing the detector and annotated images if closed before auto-saving
//    [self.detectorDatabase saveToURL:self.detectorDatabase.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {}];
//}

- (void) requestFailedWithErrorTitle:(NSString *)title errorMessage:(NSString *) message;
{
    [self showAlertWithTitle:title andDescription:message];
}


@end
