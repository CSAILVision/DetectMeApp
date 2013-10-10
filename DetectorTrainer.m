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

//training results
#define SUCCESS 1
#define INTERRUPTED 2 //and not trained
#define FAIL 0

@interface DetectorTrainer()

@property (strong, nonatomic) DetectorWrapper *detectorWrapper;

@end

@implementation DetectorTrainer

- (void) trainDetector
{
    //train in a different queue
    dispatch_queue_t training_queue = dispatch_queue_create("training_queue", 0);
    dispatch_async(training_queue, ^{
        
        TrainingSet *trainingSet = [[TrainingSet alloc] initWithBoxes:self.boxes forImages:self.images];
        
        //obtain the image average of the groundtruth images
        NSArray *listOfImages = [trainingSet getImagesOfBoundingBoxes];
        self.averageImage = [UIImage imageAverageFromImages:listOfImages];

        // check if training from a previous one
        if(self.detector){
            self.detectorWrapper = [[DetectorWrapper alloc] initWithDetector:self.detector];
        }else
            self.detectorWrapper = [[DetectorWrapper alloc] init];
        
        self.detectorWrapper.delegate = self;
        int trainingState = [self.detectorWrapper trainOnSet:trainingSet];

        
        if (trainingState == SUCCESS) {
            TrainingSet *testSet = [[TrainingSet alloc] initWithBoxes:self.boxes forImages:self.images];

            [self.detectorWrapper testOnSet:testSet atThresHold:0.0];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            if(trainingState == SUCCESS){
                [self trainingDidEnd];
                
                
            }else if(trainingState == FAIL){
                NSLog(@"train failed");
                
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
#pragma mark DetectorWrapperDelegate

- (void) sendMessage:(NSString *) message
{
    NSLog(@"%@", message);
}

- (void) updateProgress:(float) prog
{
    [self.delegate updateProgess:prog];
}



@end
