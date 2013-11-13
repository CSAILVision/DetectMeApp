//
//  User.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 13/11/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AnnotatedImage, Detector, MultipleDetector, Rating;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSNumber * isWifiOnly;
@property (nonatomic, retain) NSSet *annotatedImages;
@property (nonatomic, retain) NSSet *detectors;
@property (nonatomic, retain) NSSet *multipleDetectors;
@property (nonatomic, retain) NSSet *ratings;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addAnnotatedImagesObject:(AnnotatedImage *)value;
- (void)removeAnnotatedImagesObject:(AnnotatedImage *)value;
- (void)addAnnotatedImages:(NSSet *)values;
- (void)removeAnnotatedImages:(NSSet *)values;

- (void)addDetectorsObject:(Detector *)value;
- (void)removeDetectorsObject:(Detector *)value;
- (void)addDetectors:(NSSet *)values;
- (void)removeDetectors:(NSSet *)values;

- (void)addMultipleDetectorsObject:(MultipleDetector *)value;
- (void)removeMultipleDetectorsObject:(MultipleDetector *)value;
- (void)addMultipleDetectors:(NSSet *)values;
- (void)removeMultipleDetectors:(NSSet *)values;

- (void)addRatingsObject:(Rating *)value;
- (void)removeRatingsObject:(Rating *)value;
- (void)addRatings:(NSSet *)values;
- (void)removeRatings:(NSSet *)values;

@end
