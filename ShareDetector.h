//
//  ShareDetector.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 12/09/13.
//  Copyright (c) 2013 CSAIL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Detector.h"


@protocol ShareDectorDelegate <NSObject>

@optional
- (void) detectorDeleted;
- (void) detectorDidSent;
- (void) annotatedImageDidSent;
- (void) requestFailedWithErrorTitle:(NSString *)title errorMessage:(NSString *) message;

@end


@interface ShareDetector : NSObject <NSURLConnectionDataDelegate>

// the share to the server can be for updating (PUT) or creating new one (POST)
- (void) shareDetector:(Detector *) detector toUpdate:(BOOL)isToUpdate;
- (void) deleteDetector:(Detector *) detector;
- (void) shareAnnotatedImage:(AnnotatedImage *) annotatedImage;
- (void) shareRating:(Rating *) rating;
- (void) shareProfilePicture:(UIImage *) profilePicture forUsername:(NSString *)username;

@property (strong, nonatomic) id<ShareDectorDelegate> delegate;


@end
