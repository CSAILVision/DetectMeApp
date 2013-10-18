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

//+ (AnnotatedImage *) annotatedImageWithImage:(UIImage *)image
//                                      andBox:(Box *)box
//                                 forDetector:(Detector *)detector
//                      inManagedObjectContext:(NSManagedObjectContext *)context
//{
//    AnnotatedImage *annotatedImage = [NSEntityDescription insertNewObjectForEntityForName:@"AnnotatedImage" inManagedObjectContext:context];
//
//    User *currentUser = [User getCurrentUserInManagedObjectContext:context];
//    
//    annotatedImage.image = UIImageJPEGRepresentation(image, 0.5);
//    annotatedImage.imageHeight = @(image.size.height);
//    annotatedImage.imageWidth = @(image.size.width);
//    
//    CGRect boxRect = [box getRectangleForBox];
//    annotatedImage.boxHeight = @(boxRect.size.height);
//    annotatedImage.boxWidth = @(boxRect.size.width);
//    annotatedImage.boxX = @(boxRect.origin.x);
//    annotatedImage.boxY = @(boxRect.origin.y);
//    annotatedImage.user = currentUser;
//    annotatedImage.detector = detector;
//    
//    return annotatedImage;
//}

//+ (AnnotatedImage *) annotatedImageWithWrapper:(AnnotatedImageWrapper *) wrapper
//                                   forDetector:(Detector *)detector
//                        inManagedObjectContext:(NSManagedObjectContext *)context
//{
//    AnnotatedImage *annotatedImage = [NSEntityDescription insertNewObjectForEntityForName:@"AnnotatedImage" inManagedObjectContext:context];
//    
//    UIImage *image = wrapper.image;
//    Box *box = wrapper.box;
//    
//    User *currentUser = [User getCurrentUserInManagedObjectContext:context];
//    
//    annotatedImage.image = UIImageJPEGRepresentation(image, 0.5);
//    annotatedImage.imageHeight = @(image.size.height);
//    annotatedImage.imageWidth = @(image.size.width);
//    
//    CGRect boxRect = [box getRectangleForBox];
//    annotatedImage.boxHeight = @(boxRect.size.height);
//    annotatedImage.boxWidth = @(boxRect.size.width);
//    annotatedImage.boxX = @(boxRect.origin.x);
//    annotatedImage.boxY = @(boxRect.origin.y);
//    annotatedImage.user = currentUser;
//    annotatedImage.detector = detector;
//    
//    return annotatedImage;
//}

+ (AnnotatedImage *) annotatedImageWithImage:(UIImage *)image
                                         box:(Box *)box
                                 forLocation:(CLLocation *) location
                      inManagedObjectContext:(NSManagedObjectContext *)context
{
    AnnotatedImage *annotatedImage = [NSEntityDescription insertNewObjectForEntityForName:@"AnnotatedImage" inManagedObjectContext:context];
    
    User *currentUser = [User getCurrentUserInManagedObjectContext:context];
    
    annotatedImage.image = UIImageJPEGRepresentation(image, 0.5);
    annotatedImage.imageHeight = @(image.size.height);
    annotatedImage.imageWidth = @(image.size.width);
    
//    CGRect boxRect = [box getRectangleForBox];
//    annotatedImage.boxHeight = @(boxRect.size.height);
//    annotatedImage.boxWidth = @(boxRect.size.width);
//    annotatedImage.boxX = @(boxRect.origin.x);
//    annotatedImage.boxY = @(boxRect.origin.y);
    [annotatedImage setBox:box];
    
    annotatedImage.user = currentUser;
    
    annotatedImage.locLatitude = @(location.coordinate.latitude);
    annotatedImage.locLongitude = @(location.coordinate.longitude);
    
    return annotatedImage;
}

- (void) setBox:(Box *) box
{
    CGRect boxRect = [box getRectangleForBox];
    self.boxHeight = @(boxRect.size.height);
    self.boxWidth = @(boxRect.size.width);
    self.boxX = @(boxRect.origin.x);
    self.boxY = @(boxRect.origin.y);
}

- (Box *) boxForAnnotatedImage
{
    CGPoint upperLeft = CGPointMake(self.boxX.floatValue, self.boxY.floatValue);
    CGPoint lowerRight = CGPointMake(self.boxX.floatValue + self.boxWidth.floatValue,
                                     self.boxY.floatValue + self.boxHeight.floatValue);
    
    return [[Box alloc] initWithUpperLeft:upperLeft lowerRight:lowerRight];
}

@end
