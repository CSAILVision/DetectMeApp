//
//  BoundingBox.m
//  LabelMe
//
//  Created by Josep Marc Mingot Hidalgo on 06/08/13.
//  Copyright (c) 2013 CSAIL. All rights reserved.
//

#import "BoundingBox.h"


static inline double min(double x, double y) { return (x <= y ? x : y); }
static inline double max(double x, double y) { return (x <= y ? y : x); }
static inline int min_int(int x, int y) { return (x <= y ? x : y); }
static inline int max_int(int x, int y) { return (x <= y ? y : x); }


@implementation BoundingBox

@synthesize rectangle = _rectangle;

#pragma mark -
#pragma mark Initialization

-(id) initWithRect:(CGRect)initialRect label:(int)label imageIndex:(int)imageIndex;
{
    if(self = [self init])
    {
        //        self.label = label;
        self.imageIndex = imageIndex;
        self.xmin = initialRect.origin.x;
        self.xmax = initialRect.origin.x + initialRect.size.width;
        self.ymin = initialRect.origin.y;
        self.ymax = initialRect.origin.y + initialRect.size.height;
    }
    return self;
}

-(id) initWithBoundingBox:(BoundingBox *)box
{
    if(self = [self init]){
        self.score = box.score;
        self.xmin = box.xmin;
        self.xmax = box.xmax;
        self.ymin = box.ymin;
        self.ymax = box.ymax;
        self.label = box.label;
        self.imageIndex = box.imageIndex;
        self.pyramidLevel = box.pyramidLevel;
        self.rectangle = box.rectangle;
        self.locationOnImageHog = box.locationOnImageHog;
        self.targetClass = box.targetClass;
        self.imageIndex = box.imageHogIndex;
    }
    return self;
}

- (id) initWithBox:(Box *)box;
{
    if(self = [self init]){
        self.xmin = box.upperLeft.x;
        self.xmax = box.lowerRight.x;
        self.ymin = box.upperLeft.y;
        self.ymax = box.lowerRight.y;
    }
    
    return self;
}

#pragma mark -
#pragma mark Getters and Setters

- (CGRect) rectangle
{
    return CGRectMake(self.xmin, self.ymin, self.xmax - self.xmin, self.ymax - self.ymin);
}

- (CGRect) rectangleForImage:(UIImage *)image
{
    return CGRectMake(self.xmin*image.size.width, self.ymin*image.size.height, (self.xmax - self.xmin)*image.size.width, (self.ymax - self.ymin)*image.size.height);
}

- (void) setRectangle:(CGRect)rectangle
{
    _rectangle = rectangle;
}

#pragma mark -
#pragma mark Public Methods

- (double) fractionOfAreaOverlappingWith:(BoundingBox *) cp
{
    double area1, area2, unionArea, intersectionArea, a, b;
    
    area1 = (self.xmax - self.xmin)*(self.ymax - self.ymin);
    area2 = (cp.xmax - cp.xmin)*(cp.ymax - cp.ymin);
    
    a = (min(self.xmax, cp.xmax) - max(self.xmin, cp.xmin));
    b = (min(self.ymax, cp.ymax) - max(self.ymin, cp.ymin));
    intersectionArea = (a>0 && b>0) ? a*b : 0;
    unionArea = area1 + area2 - intersectionArea;
    //    if (intersectionArea == area1 || intersectionArea == area2) //one bb contain the other
    //        intersectionArea = unionArea;
    
    return intersectionArea/unionArea>0 ? intersectionArea/unionArea : 0;
}


- (BoundingBox *)increaseSizeByFactor:(float)factor
{
    BoundingBox *newBox = [[BoundingBox alloc] initWithBoundingBox:self];
    CGFloat newWidth = (newBox.xmax - newBox.xmin)*(1 + factor);
    CGFloat newHeight = (newBox.ymax - newBox.ymin)*(1 + factor);
    CGFloat midX = (newBox.xmin + newBox.xmax)/2.0;
    CGFloat midY = (newBox.ymin + newBox.ymax)/2.0;
    
    newBox.xmax = min(midX + newWidth/2, 1);
    newBox.ymax = min(midY + newHeight/2, 1);
    newBox.xmin = max(midX - newWidth/2, 0);
    newBox.ymin = max(midY - newHeight/2, 0);
    return newBox;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"upperLeft = (%.2f,%.2f), lowerRight = (%.2f,%.2f)",self.xmin, self.ymin, self.xmax, self.ymax];
}

@end


