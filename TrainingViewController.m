//
//  TrainingViewController.m
//  DetectTube
//
//  Created by Josep Marc Mingot Hidalgo on 20/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "TrainingViewController.h"
#import "ExecuteDetectorViewController.h"
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
    NSString *_logBuffer;
}

@end


@implementation TrainingViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.doneButton.hidden = YES;
    [self.activityIndicator startAnimating];
    [self.progressView setProgress:0];
    _logBuffer = @"";
    
    self.imageView.image = [UIImage imageNamed:@"appIcon.png"];
    
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
    
    [self displayForFinishTraining];
}

- (void) trainFailed
{
    [self showAlertWithTitle:@"Trainning Failed" andDescription:@"Try adding more pictures to the training set."];
    [self doneAction:self];
}

- (void) updateProgess:(float) progress
{
    [self.progressView setProgress:progress];
}

- (void) updateMessage:(NSString *)message
{

    _logBuffer = [_logBuffer stringByAppendingString:[NSString stringWithFormat:@"%@\n", message]];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.textView.text = _logBuffer;
        
        //scroll to the bottom
        if(self.textView.text.length > 0 ) {
            NSRange bottom = NSMakeRange(self.textView.text.length - 1, 1);
            [self.textView scrollRangeToVisible:bottom];
        }
    });
}


#pragma mark -
#pragma mark IBActions

- (IBAction)doneAction:(id)sender
{
    // Pop controllers to the gallery
    NSArray *array = [self.navigationController viewControllers];
    [self.navigationController popToViewController:[array objectAtIndex:1] animated:YES];
}

#pragma mark -
#pragma mark ShareDetectorDelegate

- (void) detectorDidSent
{
    _annotatedImagesSent = 0;
    for(AnnotatedImage *annotatedImage in _detector.annotatedImages){
        _annotatedImagesSent++;
        _shareDetector = [[ShareDetector alloc] init]; //distinct memory spaces
        _shareDetector.delegate = self;
        [_shareDetector shareAnnotatedImage:annotatedImage];
    }
}

- (void) annotatedImageDidSent
{
    _annotatedImagesSent--;
    if(_annotatedImagesSent==0)
        // Forcing save to avoid losing the detector and annotated images if closed before auto-saving
        [self.detectorDatabase saveToURL:self.detectorDatabase.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {}];
}


- (void) requestFailedWithErrorTitle:(NSString *)title errorMessage:(NSString *) message;
{
    //[self showAlertWithTitle:title andDescription:message];
}

#pragma mark -
#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if ([[segue identifier] isEqualToString:@"ExecuteDetector"]) {
        NSArray *detectors = [NSArray arrayWithObject:_detector];
        [(ExecuteDetectorViewController *)segue.destinationViewController setDetectors:detectors];
    }
}

#pragma mark -
#pragma mark Private Methods

- (void) displayForFinishTraining
{
    self.imageView.image = self.detectorTrainer.averageImage;
    
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
    
    self.label.text = @"Finished!";
    self.doneButton.hidden = NO;
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
}

@end
