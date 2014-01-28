//
//  UIImage+HOG.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 26/02/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <UIKit/UIKit.h>


static const int pixelsPerHogCell = 6; //hog cell: ~ x ~ pixels


@interface HogFeature : NSObject

@property int numBlocksX;
@property int numBlocksY;
@property int numFeaturesPerBlock;
@property int totalNumberOfFeatures;
@property double *features;
@property int *dimensionOfHogFeatures;

- (void) printFeaturesOnScreen;

@end


@interface UIImage (HOG)

- (HogFeature *) obtainHogFeatures;
- (int *) obtainDimensionsOfHogFeatures;
- (UIImage *) convertToHogImage;

+ (UIImage *) hogImageFromFeatures:(double *)hogFeatures withSize:(int *)blocks;
+ (UIImage *) hogImageFromFeature:(HogFeature *)hogFeature;

+ (void)blockPicture:(double *)features // compute the block picture for a block of HOG
                    :(UInt8 *)im //Image where to store the results
                    :(int)bs //pixels per block
                    :(int)x //x position of the block
                    :(int)y //y position of the block
                    :(int)blockw // block sizes width and height
                    :(int)blockh;

//FDOW implementation for hog scaling
+ (HogFeature *) scaleHog:(HogFeature *)originalHog to:(int) scale for:(int)numScalesPerOctave;

@end
