//
//  DetectorDownloader.h
//  LabelMe
//
//  Created by Josep Marc Mingot Hidalgo on 16/09/13.
//  Copyright (c) 2013 CSAIL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Detector.h"



@protocol DetectorFetcherDelegate <NSObject>

- (void) obtainedDetectors:(NSArray *)detectorsJSON;
- (void) downloadError:(NSString *)error;

@end

@interface DetectorFetcher : NSObject <NSURLConnectionDataDelegate>

// SYNC (needs to go inside a queue)
+ (NSArray *) fetchDetectorsSync;
+ (NSArray *) fetchAnnotatedImagesSyncForDetector:(Detector *)detector;

// ASYNC
- (void) fetchDetectorsASync;
@property (strong, nonatomic) id<DetectorFetcherDelegate> delegate;

@end
