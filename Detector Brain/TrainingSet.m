//
//  TrainingSet.m
//  LabelMe
//
//  Created by Josep Marc Mingot Hidalgo on 05/04/13.
//  Copyright (c) 2013 CSAIL. All rights reserved.
//

#import "TrainingSet.h"
#import "UIImage+HOG.h"
#import "UIImage+Resize.h"
#import "BoundingBox.h"
#import "Box.h"


#define MAX_NUMBER_EXAMPLES 20000
#define MAX_NUMBER_FEATURES 2000


@implementation TrainingSet


#pragma mark
#pragma mark - Initialization


- (id) initWithBoxes:(NSArray *)boxes forImages:(NSArray *)images
{
    if(self = [super init]){
        
        self.images = [[NSMutableArray alloc] init];
        self.groundTruthBoundingBoxes = [[NSMutableArray alloc] init];
        
        for(int i=0; i<boxes.count; i++){

            // add box
            Box *box = [boxes objectAtIndex:i];
            BoundingBox *cp = [[BoundingBox alloc] init];
            cp.xmin = box.upperLeft.x;
            cp.ymin = box.upperLeft.y;
            cp.xmax = box.lowerRight.x;
            cp.ymax = box.lowerRight.y;
        
            cp.imageIndex = self.images.count;
            cp.label = 1;
            [self.groundTruthBoundingBoxes addObject:cp];
            
            //add image
            UIImage *image = [images objectAtIndex:i];
            [self.images addObject:image];
        }
    }
    return self;
}


#pragma mark -
#pragma mark Public Methods

- (void) unifyGroundTruthBoundingBoxes
{
    //get max width and max height of the gt bb
    float minWidth=10, minHeight=0;
    for(BoundingBox *groundTruthBB in self.groundTruthBoundingBoxes){
        float width = groundTruthBB.xmax - groundTruthBB.xmin;
        if(width<0) width = - width;
        
        float height = groundTruthBB.ymax - groundTruthBB.ymin;
        if(height < 0) height = - height;
        
        minWidth = minWidth < width ? minWidth : width;
        minHeight = minHeight < height ? minHeight : height;
    }
        
    //modify the actual bb
    for(BoundingBox *groundTruthBB in self.groundTruthBoundingBoxes){
        float xMidPoint = (groundTruthBB.xmax + groundTruthBB.xmin)/2;
        float yMidPoint = (groundTruthBB.ymax + groundTruthBB.ymin)/2;
        groundTruthBB.xmin = xMidPoint - minWidth/2;
        groundTruthBB.xmax = xMidPoint + minWidth/2;
        groundTruthBB.ymin = yMidPoint - minHeight/2;
        groundTruthBB.ymax = yMidPoint + minHeight/2;
    }
}

- (float) getAverageGroundTruthAspectRatio
{
    CGSize averageSize;
    averageSize.height = 0;
    averageSize.width = 0;
    
    for(BoundingBox* groundTruthBB in self.groundTruthBoundingBoxes){
        averageSize.height += groundTruthBB.ymax - groundTruthBB.ymin;
        averageSize.width += groundTruthBB.xmax - groundTruthBB.xmin;
    }
    return averageSize.width/averageSize.height;
}


- (NSArray *) getImagesOfBoundingBoxes
{
    NSMutableArray *listOfImages = [[NSMutableArray alloc] initWithCapacity:self.groundTruthBoundingBoxes.count];
    for(BoundingBox *cp in self.groundTruthBoundingBoxes){
        UIImage *wholeImage = [self.images objectAtIndex:cp.imageIndex];
        UIImage *croppedImage = [wholeImage croppedImage:[[cp increaseSizeByFactor:0.2] rectangleForImage:wholeImage]];
        [listOfImages addObject:croppedImage];
    }
    
    return [NSArray arrayWithArray:listOfImages];
}


@end
