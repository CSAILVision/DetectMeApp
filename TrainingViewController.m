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
#import "Author+Create.h"
#import "UIImage+ImageAveraging.h"
#import "ManagedDocumentHelper.h"
#import "ShareDetector.h"



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
    [self.activityIndicator startAnimating];
    [self.progressView setProgress:0];
    [_detectorTrainer trainDetector];
    _detectorTrainer.delegate = self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!self.detectorDatabase)
        self.detectorDatabase = [ManagedDocumentHelper sharedDatabaseUsingBlock:nil];
}

- (void) documentIsReady
{
}

#pragma mark -
#pragma mark DetectorTrainnerDelegate


- (void) trainDidEndWithDetector:(DetectorWrapper *)detectorWrapper
{
    NSLog(@"finished training with detector:%@",_detectorTrainer.name);
    
    // Create entity
    NSManagedObjectContext *context = self.detectorDatabase.managedObjectContext;
    
    // Detector
    Detector *detector;
    if (!detector) {
        detector = [NSEntityDescription insertNewObjectForEntityForName:@"Detector" inManagedObjectContext:context];
    }
    detector.name = _detectorTrainer.name;
    detector.targetClass = _detectorTrainer.targetClass;
    detector.author = [Author authorWithName:@"Ramon" inManagedObjectContext:context];
    detector.isPublic = [NSNumber numberWithBool:_detectorTrainer.isPublic];
    detector.image = UIImageJPEGRepresentation(_detectorTrainer.averageImage, 0.5);
    detector.createdAt = [NSDate date];;
    detector.updatedAt = [NSDate date];;
    detector.weights = [NSKeyedArchiver archivedDataWithRootObject:detectorWrapper.weights];
    detector.sizes = [NSKeyedArchiver archivedDataWithRootObject:detectorWrapper.sizes];
    detector.scaleFactor = detectorWrapper.scaleFactor;
    
    
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
        annotatedImage.author = [Author authorWithName:@"Ramon" inManagedObjectContext:context];
        annotatedImage.detector = detector;
        
    }
    
    // send detector
    _shareDetector = [[ShareDetector alloc] init];
    [_shareDetector shareDetector:detector];
    
    self.imageView.image = _detectorTrainer.averageImage;
    
    [self.activityIndicator stopAnimating];
}

- (void) updateProgess:(float) progress
{
    [self.progressView setProgress:progress];
}


@end
