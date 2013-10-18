//
//  Rating.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 17/10/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Detector, User;

@interface Rating : NSManagedObject

@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) Detector *detector;

@end
