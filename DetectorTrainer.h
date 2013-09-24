//
//  DetectorTrainer.h
//  DetectTube
//
//  Created by Josep Marc Mingot Hidalgo on 20/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Detector.h"
#import "DetectorWrapper.h"

/*
 
 Class  Responsibilities:
 
 - Aggregate information about the detector (images, boxes, name,...)
 - Train the detector
 - Get the average image
 
 */

@protocol DetectorTrainerDelegate <NSObject>

- (void) trainDidEndWithDetector:(DetectorWrapper *)detector;

@end

@interface DetectorTrainer : NSObject <DetectorWrapperDelegate>

// Information recolected to train the detector
@property (strong, nonatomic) NSArray *images;
@property (strong, nonatomic) NSArray *boxes;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *targetClass;
@property (strong, nonatomic) UIImage *averageImage;
@property BOOL isPublic;

@property (strong, nonatomic) id<DetectorTrainerDelegate> delegate;

- (void) trainDetector;

@end
