//
//  AnnotatedImage+Create.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 11/10/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "AnnotatedImage+Create.h"
#import "User+Create.h"

@implementation AnnotatedImage (Create)

+ (AnnotatedImage *) annotatedImageWithImage:(UIImage *)image
                                      andBox:(Box *)box
                                 forDetector:(Detector *)detector
                      inManagedObjectContext:(NSManagedObjectContext *)context
{
    AnnotatedImage *annotatedImage = [NSEntityDescription insertNewObjectForEntityForName:@"AnnotatedImage" inManagedObjectContext:context];

    User *currentUser = [User getCurrentUserInManagedObjectContext:context];
    
    annotatedImage.image = UIImageJPEGRepresentation(image, 0.5);
    annotatedImage.imageHeight = @(image.size.height);
    annotatedImage.imageWidth = @(image.size.width);
    
    CGRect boxRect = [box getRectangleForBox];
    annotatedImage.boxHeight = @(boxRect.size.height);
    annotatedImage.boxWidth = @(boxRect.size.width);
    annotatedImage.boxX = @(boxRect.origin.x);
    annotatedImage.boxY = @(boxRect.origin.y);
    annotatedImage.user = currentUser;
    annotatedImage.detector = detector;
    
    return annotatedImage;
}


@end
