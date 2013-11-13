//
//  User.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 13/11/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "User.h"
#import "AnnotatedImage.h"
#import "Detector.h"
#import "MultipleDetector.h"
#import "Rating.h"


@implementation User

@dynamic email;
@dynamic image;
@dynamic username;
@dynamic isWifiOnly;
@dynamic annotatedImages;
@dynamic detectors;
@dynamic multipleDetectors;
@dynamic ratings;

@end
