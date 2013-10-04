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
    
    // Detector
    Detector *detector = self.detector;
    if (!self.detector) { //if it is not an update
        detector = [NSEntityDescription insertNewObjectForEntityForName:@"Detector" inManagedObjectContext:context];
    }else{
        // delete previously annotated images
        for(AnnotatedImage *annotatedImage in self.detector.annotatedImages)
            [context deleteObject:annotatedImage];
    }
    
    detector.name = _detectorTrainer.name;
    detector.targetClass = _detectorTrainer.targetClass;
    detector.user = [User userWithName:@"Ramon" inManagedObjectContext:context];
    detector.isPublic = [NSNumber numberWithBool:_detectorTrainer.isPublic];
    detector.image = UIImageJPEGRepresentation(_detectorTrainer.averageImage, 0.5);
    detector.createdAt = [NSDate date];;
    detector.updatedAt = [NSDate date];;
    detector.weights = [detectorWrapper.weights convertToJSON];//[NSKeyedArchiver archivedDataWithRootObject:detectorWrapper.weights];
    detector.sizes = [detectorWrapper.sizes convertToJSON];//[NSKeyedArchiver archivedDataWithRootObject:detectorWrapper.sizes];
    
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
        annotatedImage.user = [User userWithName:@"Ramon" inManagedObjectContext:context];
        annotatedImage.detector = detector;

    }
    
    // send detector
    _shareDetector = [[ShareDetector alloc] init];
    [_shareDetector shareDetector:detector];
    
    self.imageView.image = _detectorTrainer.averageImage;
    
    [self.activityIndicator stopAnimating];
    self.finishButton.hidden = NO;
}

- (void) updateProgess:(float) progress
{
    [self.progressView setProgress:progress];
}


@end
