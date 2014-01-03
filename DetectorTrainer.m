//
//  DetectorTrainer.m
//  DetectTube
//
//  Created by Josep Marc Mingot Hidalgo on 20/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "DetectorTrainer.h"
#import "DetectorWrapper.h"
#import "TrainingSet.h"
#import "DetectorWrapper.h"
#import "UIImage+ImageAveraging.h"
#import "AnnotatedImage+Create.h"


#include <stdlib.h> // for random subsampling of trianing set THESIS!!

//training results
#define SUCCESS 1
#define INTERRUPTED 2 //and not trained
#define FAIL 0

@interface DetectorTrainer()
{
    NSMutableArray *_images;
    NSMutableArray *_boxes;
}

@property (strong, nonatomic) DetectorWrapper *detectorWrapper;

@end

@implementation DetectorTrainer
- (void) trainDetector
{
    //train in a different queue
    dispatch_queue_t training_queue = dispatch_queue_create("training_queue", 0);
    dispatch_async(training_queue, ^{
        
        //subselect ranom
//        int num = 16;
//        NSMutableIndexSet *mutableIndexSet = [[NSMutableIndexSet alloc] init];
//
//        while(mutableIndexSet.count < num)
//            [mutableIndexSet addIndex: arc4random() % _boxes.count];
//
//        NSLog(@"mutable index set:%@", mutableIndexSet);
//        
//        _boxes = [NSMutableArray arrayWithArray:[_boxes objectsAtIndexes:[[NSIndexSet alloc] initWithIndexSet:mutableIndexSet]]];
//        _images = [NSMutableArray arrayWithArray:[_images objectsAtIndexes:[[NSIndexSet alloc] initWithIndexSet:mutableIndexSet]]];
        
        TrainingSet *trainingSet = [[TrainingSet alloc] initWithBoxes:_boxes forImages:_images];
        
        //obtain the image average of the groundtruth images
        NSArray *listOfImages = [trainingSet getImagesOfBoundingBoxes];
        self.averageImage = [UIImage imageAverageFromImages:listOfImages];

        // check if training from a previous one
        if(self.previousDetector){
            self.detectorWrapper = [[DetectorWrapper alloc] initWithDetector:self.previousDetector];
        }else
            self.detectorWrapper = [[DetectorWrapper alloc] init];
        
        
        self.detectorWrapper.delegate = self;
        
        NSDate * start = [NSDate date];
        int trainingState = [self.detectorWrapper trainOnSet:trainingSet];
        NSLog(@"TIME TRAINING: %f", -[start timeIntervalSinceNow]);
        
        
        if (trainingState == SUCCESS) {
            TrainingSet *testSet = [[TrainingSet alloc] initWithBoxes:_boxes forImages:_images];

            [self.detectorWrapper testOnSet:testSet atThresHold:0.0];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            if(trainingState == SUCCESS){
                NSLog(@"train succeed");
                [self trainingDidEnd];
                
                
            }else if(trainingState == FAIL){
                NSLog(@"train failed");
                [self.delegate trainFailed];
                
            }else if(trainingState == INTERRUPTED){
                NSLog(@"train interrupted");
            }
            
        });
    });

}


- (void) trainingDidEnd
{    
    [self.delegate trainDidEndWithDetector:self.detectorWrapper];
}

#pragma mark -
#pragma mark Getters and setters

- (void) setAnnotatedImages:(NSArray *)annotatedImages
{
    if(!_annotatedImages){
        _annotatedImages = annotatedImages;
        _images = [[NSMutableArray alloc] initWithCapacity:annotatedImages.count];
        _boxes = [[NSMutableArray alloc] initWithCapacity:annotatedImages.count];
        
        for(AnnotatedImage *aImage in annotatedImages){
            [_images addObject:[UIImage imageWithData:aImage.image]];
            [_boxes addObject:[aImage boxForAnnotatedImage]];
        }
    }
}

#pragma mark -
#pragma mark DetectorWrapperDelegate

- (void) sendMessage:(NSString *) message
{
    NSLog(@"%@", message);
    
    if(!self.trainingLog) self.trainingLog = @"";
    self.trainingLog = [self.trainingLog stringByAppendingString:[NSString stringWithFormat:@"%@\n",message]];
    [self.delegate updateMessage:message];
}

- (void) updateProgress:(float) prog
{
    [self.delegate updateProgess:prog];
}



@end
