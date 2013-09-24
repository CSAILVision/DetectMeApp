//
//  DetectorExecutor.m
//  DetectTube
//
//  Created by Josep Marc Mingot Hidalgo on 20/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "DetectorExecutor.h"
#import "DetectorWrapper.h"
#import "Pyramid.h"


#define SCALES_PER_OCTAVE 10

@interface DetectorExecutor()
{
    DetectorWrapper *_detectorWrapper;
}

@end

@implementation DetectorExecutor

- (id)initWithDetector:(Detector *)detector
{
    
    if (self = [super init]) {
        
    }
    return self;
}






@end
