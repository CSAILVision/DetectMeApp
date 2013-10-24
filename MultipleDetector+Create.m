//
//  MultipleDetector+Create.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 23/10/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "MultipleDetector+Create.h"
#import "User+Create.h"

@implementation MultipleDetector (Create)


+ (MultipleDetector *) multipleDetectorWithName:(NSString *) name
                                   forDetectors:(NSArray *) detectors
                         inManagedObjectContext:(NSManagedObjectContext *)context
{
    MultipleDetector *multipleDetector = [NSEntityDescription insertNewObjectForEntityForName:@"MultipleDetector"inManagedObjectContext:context];
    
    multipleDetector.name = name;
    multipleDetector.detectors = [[NSSet alloc] initWithArray:detectors];
    multipleDetector.author = [User getCurrentUserInManagedObjectContext:context];
    
    return multipleDetector;
}



@end
