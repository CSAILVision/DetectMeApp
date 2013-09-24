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
#import "Author+Create.h"
#import "UIImage+ImageAveraging.h"


@interface TrainingViewController()
{
    DetectorTrainer *_detectorTrainer;
}

@end


@implementation TrainingViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.activityIndicator startAnimating];
    [_detectorTrainer trainDetector];
    _detectorTrainer.delegate = self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!self.detectorDatabase){
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Default Detector Database"];
        self.detectorDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
            [self.detectorDatabase openWithCompletionHandler:^(BOOL success) {
                if (success) [self documentIsReady];
                if (!success) NSLog(@"couldn't open document at %@", url);
            }];
        } else {
            [self.detectorDatabase saveToURL:url forSaveOperation:UIDocumentSaveForCreating
              completionHandler:^(BOOL success) {
                  if (success) [self documentIsReady];
                  if (!success) NSLog(@"couldn't create document at %@", url);
              }]; }
    }
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
    Detector *detector = [NSEntityDescription insertNewObjectForEntityForName:@"Detector" inManagedObjectContext:context];
    
    detector.name = _detectorTrainer.name;
    detector.targetClass = _detectorTrainer.targetClass;
    detector.author = [Author authorWithName:@"Ramon" inManagedObjectContext:context];
    detector.isPublic = [NSNumber numberWithBool:_detectorTrainer.isPublic];
    detector.image = UIImageJPEGRepresentation(_detectorTrainer.averageImage, 0.5);
    detector.createdAt = [NSDate date];;
    detector.updatedAt = [NSDate date];;
    detector.weights = [NSKeyedArchiver archivedDataWithRootObject:detectorWrapper.weights];
    detector.sizes = [NSKeyedArchiver archivedDataWithRootObject:detectorWrapper.sizes];
    NSLog(@"sizes:%@", detectorWrapper.sizes);
    
    self.imageView.image = _detectorTrainer.averageImage;
    
    [self.activityIndicator stopAnimating];
    
    NSLog(@"detector weights: %@", detectorWrapper.weights);
}

@end
