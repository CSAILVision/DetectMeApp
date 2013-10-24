//
//  MultipleDetector.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 23/10/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Detector, User;

@interface MultipleDetector : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) User *author;
@property (nonatomic, retain) NSSet *detectors;
@end

@interface MultipleDetector (CoreDataGeneratedAccessors)

- (void)addDetectorsObject:(Detector *)value;
- (void)removeDetectorsObject:(Detector *)value;
- (void)addDetectors:(NSSet *)values;
- (void)removeDetectors:(NSSet *)values;

@end
