//
//  AnnotatedImage.h
//  DetectTube
//
//  Created by Josep Marc Mingot Hidalgo on 23/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Author, Detector;

@interface AnnotatedImage : NSManagedObject

@property (nonatomic, retain) NSNumber * boxHeight;
@property (nonatomic, retain) NSNumber * boxWidth;
@property (nonatomic, retain) NSNumber * boxX;
@property (nonatomic, retain) NSNumber * boxY;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSNumber * imageHeight;
@property (nonatomic, retain) NSNumber * imageWidth;
@property (nonatomic, retain) Author *author;
@property (nonatomic, retain) Detector *detector;

@end
