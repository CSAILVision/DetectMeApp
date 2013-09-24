//
//  TrainingSet.h
//  LabelMe
//
//  Created by Josep Marc Mingot Hidalgo on 05/04/13.
//  Copyright (c) 2013 CSAIL. All rights reserved.
//

#import <Foundation/Foundation.h>



@class DetectorResourceHandler;

@interface TrainingSet : NSObject

@property (strong, nonatomic) NSMutableArray *images; //UIImage
@property (strong, nonatomic) NSMutableArray *groundTruthBoundingBoxes; //BoundingBox
@property (strong, nonatomic) NSMutableArray *boundingBoxes; //BoundingBox
@property (strong, nonatomic) NSMutableArray *imagesNames;

@property CGSize templateSize;
//ratio between the average area of the bounding boxes inside the images
@property float areaRatio;


//modify the actual ground truth bounding boxes to handle a special confilictive case in learning. That case was when images with rectangular ground truth bb combined horizontal anv vertical rectangles. This methods transforms all those rectangles in the circumscrite square containing them
- (void) unifyGroundTruthBoundingBoxes;


//// Given some images names, constructs the training set extracting the target
//// classes from it.
//- (id) initForTargetClasses:(NSArray *)targetClasses
//             forImagesNames:(NSArray *)imagesNames
//            withFileHandler:(DetectorResourceHandler *)detectorResourceHandler;

- (id) initWithBoxes:(NSArray *)boxes forImages:(NSArray *)images;



// Get the images result of cropping with the bounding boxes
// Needed by when making the average image for the detector
- (NSArray *) getImagesOfBoundingBoxes;

@end


