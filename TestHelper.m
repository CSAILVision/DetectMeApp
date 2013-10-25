//
//  TestHelper.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 24/10/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "TestHelper.h"

@interface TestHelper()
{
    int _frames;
    int _truePositives;
    int _falseNegatives;
    BOOL _isTesting;
    
    NSTimer *_timer;
    int _timerCount;
}

@end

@implementation TestHelper


#pragma mark -
#pragma mark Pubic Methods

- (void) startTest
{
    _frames = 0;
    _truePositives = 0;
    _falseNegatives = 0;
    _timerCount = 0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1
                                              target:self
                                            selector:@selector(increaseTimerCount)
                                            userInfo:nil
                                             repeats:YES];
    _isTesting = YES;
}

- (void) receivedDetections:(NSArray *)detectionBoundingBoxes onRealBox:(Box *)realBox;
{
    if(_isTesting){
        
        _frames++;
        
        if(detectionBoundingBoxes.count>0){
            BoundingBox *detectionBoundingBox = [[detectionBoundingBoxes firstObject] firstObject];
            BoundingBox *realBoundingBox = [[BoundingBox alloc] initWithBox:realBox];
            double overlapArea = [detectionBoundingBox fractionOfAreaOverlappingWith:realBoundingBox];
            NSLog(@"overlap area: %f", overlapArea);
            if(overlapArea > 0.5 && overlapArea<1){
                _truePositives++;
                
            }else{
                _falseNegatives++;
            }
        }
    }
}

- (void) increaseTimerCount
{
    _timerCount++;
    NSLog(@"Count: %d", _timerCount);
    if(_timerCount==30){
        _isTesting = NO;
        [_timer invalidate];
        
        NSLog(@"%d frames: %d TP, %d FN", _frames, _truePositives, _falseNegatives);
    }
    
}

@end
