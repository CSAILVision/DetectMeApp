//
//  Detector.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 04/10/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AnnotatedImage, User;

@interface Detector : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * detectionThreshold;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSNumber * isPublic;
@property (nonatomic, retain) NSNumber * isSent;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * precisionRecall;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSNumber * serverDatabaseID;
@property (nonatomic, retain) NSString * sizes;
@property (nonatomic, retain) id targetClass;
@property (nonatomic, retain) NSNumber * timeLearning;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * weights;
@property (nonatomic, retain) NSSet *annotatedImages;
@property (nonatomic, retain) User *user;
@end

@interface Detector (CoreDataGeneratedAccessors)

- (void)addAnnotatedImagesObject:(AnnotatedImage *)value;
- (void)removeAnnotatedImagesObject:(AnnotatedImage *)value;
- (void)addAnnotatedImages:(NSSet *)values;
- (void)removeAnnotatedImages:(NSSet *)values;

@end
