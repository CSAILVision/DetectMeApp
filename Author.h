//
//  Author.h
//  DetectTube
//
//  Created by Josep Marc Mingot Hidalgo on 23/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AnnotatedImage, Detector;

@interface Author : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSSet *annotatedImages;
@property (nonatomic, retain) NSSet *detectors;
@end

@interface Author (CoreDataGeneratedAccessors)

- (void)addAnnotatedImagesObject:(AnnotatedImage *)value;
- (void)removeAnnotatedImagesObject:(AnnotatedImage *)value;
- (void)addAnnotatedImages:(NSSet *)values;
- (void)removeAnnotatedImages:(NSSet *)values;

- (void)addDetectorsObject:(Detector *)value;
- (void)removeDetectorsObject:(Detector *)value;
- (void)addDetectors:(NSSet *)values;
- (void)removeDetectors:(NSSet *)values;

@end
