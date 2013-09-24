//
//  ConvolutionHelper.h
//  TestDetector
//
//  Created by Josep Marc Mingot Hidalgo on 07/02/13.
//  Copyright (c) 2013 Dolores. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface ConvolutionHelper : NSObject

+ (void) convolution:(double *)result matrixA:(double *)matrixA :(int *)sizeA matrixB:(double *)matrixB :(int *)sizeB;

+ (NSArray *)nms:(NSArray *)boundingBoxesCandidates maxOverlapArea:(double)overlap minScoreThreshold:(double)scoreThreshold;

@end



