//
//  ConvolutionHelper.m
//  TestDetector
//
//  Created by Josep Marc Mingot Hidalgo on 07/02/13.
//  Copyright (c) 2013 Dolores. All rights reserved.
//
#import "ConvolutionHelper.h"
#import "UIImage+HOG.h"
#import "BoundingBox.h"


@implementation ConvolutionHelper


+ (void) convolution:(double *)result matrixA:(double *)matrixA :(int *)sizeA matrixB:(double *)matrixB :(int *)sizeB
{
    int convolutionSize[2];
    convolutionSize[0] = sizeA[0] - sizeB[0] + 1; 
    convolutionSize[1] = sizeA[1] - sizeB[1] + 1;
    
    for (int x = 0; x < convolutionSize[1]; x++) {
        for (int y = 0; y < convolutionSize[0]; y++)
        {
            double val = 0;
            
            for(int xp=0;xp<sizeB[1];xp++){ //Assuming column-major representation
                double *A_off = matrixA + (x+xp)*sizeA[0] + y;
                double *B_off = matrixB + xp*sizeB[0];
                switch(sizeB[0]) { //depending on the template size sizeB[0]. Use this hack to avoid an additional loop in common cases.
                    case 20: val += A_off[19] * B_off[19];
                    case 19: val += A_off[18] * B_off[18];
                    case 18: val += A_off[17] * B_off[17];
                    case 17: val += A_off[16] * B_off[16];
                    case 16: val += A_off[15] * B_off[15];
                    case 15: val += A_off[14] * B_off[14];
                    case 14: val += A_off[13] * B_off[13];
                    case 13: val += A_off[12] * B_off[12];
                    case 12: val += A_off[11] * B_off[11];
                    case 11: val += A_off[10] * B_off[10];
                    case 10: val += A_off[9]  * B_off[9];
                    case 9:  val += A_off[8]  * B_off[8];
                    case 8:  val += A_off[7]  * B_off[7];
                    case 7:  val += A_off[6]  * B_off[6];
                    case 6:  val += A_off[5]  * B_off[5];
                    case 5:  val += A_off[4]  * B_off[4];
                    case 4:  val += A_off[3]  * B_off[3];
                    case 3:  val += A_off[2]  * B_off[2];
                    case 2:  val += A_off[1]  * B_off[1];
                    case 1:  val += A_off[0]  * B_off[0];
                        break;
                    default:
                        for (int yp = 0; yp < sizeB[0]; yp++) {
                            val += *(A_off++) * *(B_off++);
                        }
                }
            }
            *(result++) += val;
            
        }
    }
}


+ (NSArray *) nms:(NSArray *)boundingBoxesCandidates
   maxOverlapArea:(double)overlap
minScoreThreshold:(double)scoreThreshold
{

    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    // select only those bounding boxes with score above the threshold and non overlapping areas
    for (int i = 0; i<boundingBoxesCandidates.count; i++){
        BOOL selected = YES;
        BoundingBox *point = [boundingBoxesCandidates objectAtIndex:i];
    
        if (point.score < scoreThreshold)
            break;
        
        for (int j = 0; j<result.count; j++)
            if ([[result objectAtIndex:j] fractionOfAreaOverlappingWith:point] > overlap){
                selected = NO;
                break;
            }
        
        if (selected) [result addObject:point];
    }
    
    return result;
}


@end
