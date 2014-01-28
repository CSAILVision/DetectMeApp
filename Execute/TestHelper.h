//
//  TestHelper.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 24/10/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BoundingBox.h"
#import "Box.h"

@protocol TestHelperDelegate <NSObject>

- (void) updateProgress:(float) progress;
- (void) testDidFinishWithMessage:(NSString *)message;

@end

@interface TestHelper : NSObject 

@property (strong, nonatomic) id<TestHelperDelegate> delegate;

- (void) startTest;
- (void) receivedDetections:(NSArray *)detectionBoundingBoxes onRealBox:(Box *)realBox;
- (void) cancelTest;

@end
