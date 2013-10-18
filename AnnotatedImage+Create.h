//
//  AnnotatedImage+Create.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 11/10/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "AnnotatedImage.h"
#import "Detector.h"
#import "Box.h"
#import "AnnotatedImageWrapper.h"

@interface AnnotatedImage (Create)

//+ (AnnotatedImage *) annotatedImageWithImage:(UIImage *)image
//                                      andBox:(Box *)box
//                                  forDetector:(Detector *)detector
//                       inManagedObjectContext:(NSManagedObjectContext *)context;

//+ (AnnotatedImage *) annotatedImageWithWrapper:(AnnotatedImageWrapper *) wrapper
//                                   forDetector:(Detector *)detector
//                        inManagedObjectContext:(NSManagedObjectContext *)context;

+ (AnnotatedImage *) annotatedImageWithImage:(UIImage *)image
                                         box:(Box *)box
                                 forLocation:(CLLocation *) location
                      inManagedObjectContext:(NSManagedObjectContext *)context;

- (Box *) boxForAnnotatedImage;
- (void) setBox:(Box *) box;

@end
