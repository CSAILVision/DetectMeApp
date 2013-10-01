//
//  ShareDetector.h
//  LabelMe
//
//  Created by Josep Marc Mingot Hidalgo on 12/09/13.
//  Copyright (c) 2013 CSAIL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Detector.h"


@protocol ShareDectorDelegate <NSObject>

-(void) finishedUploadingDetecor:(NSDictionary *)detectorJSON;
-(void) errorReceive:(NSString *) error;

@end


@interface ShareDetector : NSObject <NSURLConnectionDataDelegate>

- (void) shareDetector:(Detector *) detector;
- (void) shareAnnotatedImage:(AnnotatedImage *) annotatedImage;

@property (strong, nonatomic) id<ShareDectorDelegate> delegate;


@end
