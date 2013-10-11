//
//  AnnotatedImage.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 11/10/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Detector, User;

@interface AnnotatedImage : NSManagedObject

@property (nonatomic, retain) NSNumber * boxHeight;
@property (nonatomic, retain) NSNumber * boxWidth;
@property (nonatomic, retain) NSNumber * boxX;
@property (nonatomic, retain) NSNumber * boxY;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSNumber * imageHeight;
@property (nonatomic, retain) NSNumber * imageWidth;
@property (nonatomic, retain) NSNumber * isSent;
@property (nonatomic, retain) Detector *detector;
@property (nonatomic, retain) User *user;

@end
