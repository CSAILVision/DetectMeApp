//
//  AnnotatedImage+Create.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 11/10/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "AnnotatedImage+Create.h"
#import "User+Create.h"
#import "ConstantsServer.h"

@implementation AnnotatedImage (Create)

+ (AnnotatedImage *) annotatedImageWithImage:(UIImage *)image
                                         box:(Box *)box
                                 forLocation:(CLLocation *) location
                                   forMotion:(CMDeviceMotion *) motion
                      inManagedObjectContext:(NSManagedObjectContext *)context
{
    AnnotatedImage *annotatedImage = [NSEntityDescription insertNewObjectForEntityForName:@"AnnotatedImage" inManagedObjectContext:context];
    

    
    annotatedImage.image = UIImageJPEGRepresentation(image, 0.5);
    annotatedImage.imageHeight = @(image.size.height);
    annotatedImage.imageWidth = @(image.size.width);
    
    [annotatedImage setBox:box];
    
    User *currentUser = [User getCurrentUserInManagedObjectContext:context];
    annotatedImage.user = currentUser;
    
    annotatedImage.locationLatitude = @(location.coordinate.latitude);
    annotatedImage.locationLongitude = @(location.coordinate.longitude);
    
    annotatedImage.motionQuaternionW = @(motion.attitude.quaternion.w);
    annotatedImage.motionQuaternionX = @(motion.attitude.quaternion.x);
    annotatedImage.motionQuaternionY = @(motion.attitude.quaternion.y);
    annotatedImage.motionQuaternionZ = @(motion.attitude.quaternion.z);
    
    return annotatedImage;
}


+ (AnnotatedImage *) annotatedImageWithDictionaryInfo:(NSDictionary *)annotatedImageInfo
                               inManagedObjectContext:(NSManagedObjectContext *)context
                                          forDetector:(Detector *)detector
{
    AnnotatedImage *annotatedImage = [NSEntityDescription insertNewObjectForEntityForName:@"AnnotatedImage" inManagedObjectContext:context];
    
    User *currentUser = [User getCurrentUserInManagedObjectContext:context];
    annotatedImage.user = currentUser;
    
    annotatedImage.detector = detector;
    annotatedImage.boxX = [annotatedImageInfo objectForKey:SERVER_AIMAGE_BOX_X];
    annotatedImage.boxY = [annotatedImageInfo objectForKey:SERVER_AIMAGE_BOX_Y];
    annotatedImage.boxWidth = [annotatedImageInfo objectForKey:SERVER_AIMAGE_BOX_WIDTH];
    annotatedImage.boxHeight = [annotatedImageInfo objectForKey:SERVER_AIMAGE_BOX_HEIGHT];
    annotatedImage.locationLatitude = [annotatedImageInfo objectForKey:SERVER_AIMAGE_LOC_LATITUDE];
    annotatedImage.locationLongitude = [annotatedImageInfo objectForKey:SERVER_AIMAGE_LOC_LONGITUDE];
    annotatedImage.motionQuaternionX = [annotatedImageInfo objectForKey:SERVER_AIMAGE_MOT_QUATX];
    annotatedImage.motionQuaternionY = [annotatedImageInfo objectForKey:SERVER_AIMAGE_MOT_QUATY];
    annotatedImage.motionQuaternionZ = [annotatedImageInfo objectForKey:SERVER_AIMAGE_MOT_QUATZ];
    annotatedImage.motionQuaternionW = [annotatedImageInfo objectForKey:SERVER_AIMAGE_MOT_QUATW];
    
    NSURL *imageURL =[NSURL URLWithString:[NSString stringWithFormat:@"%@media/%@",SERVER_ADDRESS,[annotatedImageInfo       objectForKey:SERVER_AIMAGE_IMAGE]]];
    annotatedImage.image = [NSData dataWithContentsOfURL:imageURL];
    
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
