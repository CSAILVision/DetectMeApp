//
//  AnnotatedImage+Create.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 11/10/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "AnnotatedImage.h"
#import "Detector.h"
#import "Box.h"

@interface AnnotatedImage (Create)

+ (AnnotatedImage *) annotatedImageWithImage:(UIImage *)image
                                      andBox:(Box *)box
                                  forDetector:(Detector *)detector
                       inManagedObjectContext:(NSManagedObjectContext *)context;

@end
