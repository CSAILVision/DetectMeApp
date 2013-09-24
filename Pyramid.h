//
//  Pyramid.h
//  LabelMe
//
//  Created by Josep Marc Mingot Hidalgo on 20/05/13.
//  Copyright (c) 2013 CSAIL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImage+HOG.h"

/*
 
 Class  Responsibilities:
 
 - Constructs a pyramid of HogG Features for a given image
 
 
 */
@interface Pyramid : NSObject

//indexes of the pyramids to calculate according to each detector. If a detector detects the object in a specified pyramid level, on the next iteration it will only be computing some levels up and down. Avoid having to calculate all the levels if not necessary.
@property (nonatomic, strong) NSMutableSet *levelsToCalculate;

//hog feature for each level
@property (atomic, strong) NSMutableArray *hogFeatures;

@property int numPyramids;


- (id) initWithDetectors:(NSArray *) detectors forNumPyramids:(int) numPyramids;

- (void) constructPyramidForImage:(UIImage *)image withOrientation:(int)orientation;


@end
