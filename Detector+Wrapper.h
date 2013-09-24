//
//  Detector+Wrapper.h
//  DetectTube
//
//  Created by Josep Marc Mingot Hidalgo on 23/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "Detector.h"
#import "DetectorWrapper.h"

@interface Detector (Wrapper)

- (DetectorWrapper *) toDetectorWrapper;
+ (Detector *) fromDetectorWrapper:(DetectorWrapper *)detectorWrapper;

@end
