//
//  TrainingSet.h
//  LabelMe
//
//  Created by Josep Marc Mingot Hidalgo on 05/04/13.
//  Copyright (c) 2013 CSAIL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BoundingBox.h"


@class DetectorResourceHandler;

@interface TrainingSet : NSObject

@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) NSMutableArray *groundTruthBoundingBoxes;

//@property CGSize templateSize;
//ratio between the average area of the bounding boxes inside the images
//@property float areaRatio;


//modify the actual ground truth bounding boxes to handle a special confilictive case in learning. That case was when images with rectangular ground truth bb combined horizontal anv vertical rectangles. This methods transforms all those rectangles in the circumscrite square containing them
- (void) unifyGroundTruthBoundingBoxes;


- (id) initWithBoxes:(NSArray *)boxes forImages:(NSArray *)images;


// Get the images result of cropping with the bounding boxes
// Needed by when making the average image for the detector
- (NSArray *) getImagesOfBoundingBoxes;

// Returns the average aspect ratio (h/w) of the ground truth bounding boxes
// Used to compute the sizes of the template
- (float) getAverageGroundTruthAspectRatio;

@end


