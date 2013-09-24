//
//  DetectorExecutor.h
//  DetectTube
//
//  Created by Josep Marc Mingot Hidalgo on 20/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Detector.h"

@interface DetectorExecutor : NSObject

@property (strong, nonatomic) NSNumber *scaleFactor; 

- (id)initWithDetector:(Detector *)detector;


@end
