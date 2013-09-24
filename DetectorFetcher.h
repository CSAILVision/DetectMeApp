//
//  DetectorDownloader.h
//  LabelMe
//
//  Created by Josep Marc Mingot Hidalgo on 16/09/13.
//  Copyright (c) 2013 CSAIL. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SERVER_ADDRESS @"http://128.30.99.160:8000"
#define SERVER_DETECTOR_ID @"id"
#define SERVER_DETECTOR_NAME @"name"
#define SERVER_DETECTOR_CLASS @"object_class"
#define SERVER_DETECTOR_PUBLIC @"public"
#define SERVER_DETECTOR_IMAGE @"average_image"
#define SERVER_DETECTOR_HASH @"hash_value"

@protocol DetectorFetcherDelegate <NSObject>

- (void) obtainedDetectors:(NSArray *)detectorsJSON;
- (void) downloadError:(NSString *)error;

@end

@interface DetectorFetcher : NSObject <NSURLConnectionDataDelegate>

// SYNC (needs to go inside a queue)
+ (NSArray *) fetchDetectorsSync;

// ASYNC
- (void) fetchDetectorsASync;
@property (strong, nonatomic) id<DetectorFetcherDelegate> delegate;

@end
