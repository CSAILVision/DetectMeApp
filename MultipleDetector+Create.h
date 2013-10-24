//
//  MultipleDetector+Create.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 23/10/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "MultipleDetector.h"

@interface MultipleDetector (Create)

+ (MultipleDetector *) multipleDetectorWithName:(NSString *) name
                                   forDetectors:(NSArray *) detectors
                         inManagedObjectContext:(NSManagedObjectContext *) context;

@end
