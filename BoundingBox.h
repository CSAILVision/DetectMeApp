//
//  BoundingBox.h
//  LabelMe
//
//  Created by Josep Marc Mingot Hidalgo on 06/08/13.
//  Copyright (c) 2013 CSAIL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BoundingBox : NSObject

@property double score;
@property double xmin;
@property double xmax;
@property double ymin;
@property double ymax;
@property CGRect rectangle;

@property int label; //1 or -1
@property int imageIndex;
@property int pyramidLevel;
@property CGPoint locationOnImageHog;
@property (strong, nonatomic) NSString *targetClass; //target class of the bb.

//index in for the detector array of hog features of the pyramids
@property int imageHogIndex;

//initialization
- (id) initWithRect:(CGRect)initialRect label:(int)label imageIndex:(int)imageIndex;
- (id) initWithBoundingBox:(BoundingBox *)box;

- (CGRect) rectangleForImage:(UIImage *)image;
- (double) fractionOfAreaOverlappingWith:(BoundingBox *) cp;

//increase the box size for visualization purposes. factor between 0 and 1.
- (BoundingBox *) increaseSizeByFactor:(float)factor;

@end
