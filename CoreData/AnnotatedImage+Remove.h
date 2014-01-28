//
//  AnnotatedImage+Remove.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 12/12/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "AnnotatedImage.h"


/*
 
 Class  Responsibilities:
 
 - Remove the annotated images without link
 
 
 */

@interface AnnotatedImage (Remove)

- (void) removeUnlinkedImagesInManagedObjectContext:(NSManagedObjectContext *)context;

@end
