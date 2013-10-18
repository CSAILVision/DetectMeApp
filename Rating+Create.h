//
//  Rating+Create.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 17/10/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "Rating.h"
#import "Detector.h"

/*
 
 Class  Responsibilities:
 
 - Get or Create Rating for the given detector and current user
 
 
 */

@interface Rating (Create)

+ (Rating *) ratingforDetector:(Detector *)detector
        inManagedObjectContext:(NSManagedObjectContext *)context;

@end
