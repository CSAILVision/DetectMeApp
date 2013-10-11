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

- (void) endDetectorUploading:(NSDictionary *)detectorJSON;
- (void) endAnnotatedImageUploading:(NSDictionary *)annotatedImageJSON;

-(void) errorReceive:(NSString *) error;

@end


@interface ShareDetector : NSObject <NSURLConnectionDataDelegate>

// the share to the server can be for updating (PUT) or creating new one (POST)
- (void) shareDetector:(Detector *) detector toUpdate:(BOOL)isToUpdate;
- (void) shareAnnotatedImage:(AnnotatedImage *) annotatedImage;
- (void) deleteDetector:(Detector *) detector;


@property (strong, nonatomic) id<ShareDectorDelegate> delegate;


@end
