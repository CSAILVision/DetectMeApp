//
//  Pyramid.m
//  LabelMe
//
//  Created by Josep Marc Mingot Hidalgo on 20/05/13.
//  Copyright (c) 2013 CSAIL. All rights reserved.
//

#import "Pyramid.h"
#import "UIImage+Resize.h"
#import "DetectorWrapper.h"


#define SCALES_PER_OCTAVE 10


@interface Pyramid()

//send the average of all the detectors
@property (nonatomic, strong) NSNumber *scaleFactor;

@end



@implementation Pyramid

@synthesize hogFeatures = _hogFeatures;



#pragma mark -
#pragma mark Initialization


- (id) initWithDetectors:(NSArray *)detectors forNumPyramids:(int)numPyramids
{
    self = [super init];
    if(self){
        self.numPyramids = numPyramids;
        
        //compute average scale factor
        float average = 0;
        for(DetectorWrapper *detector in detectors)
            average = average + detector.scaleFactor.floatValue;
        average = average/detectors.count;
        self.scaleFactor = [NSNumber numberWithFloat:average];
    }
    
    return self;
}

#pragma mark -
#pragma mark Getters and Setters

- (NSMutableArray *) hogFeatures
{
    if(!_hogFeatures){
        _hogFeatures = [[NSMutableArray alloc] initWithCapacity:self.numPyramids];
        for(int i=0;i<self.numPyramids;i++) [_hogFeatures addObject:@0]; //null initialization;
    }
    return _hogFeatures;
}

- (void) setHogFeatures:(NSMutableArray *)hogFeatures
{
    _hogFeatures = hogFeatures;
}


- (NSMutableSet *) levelsToCalculate
{
    if(!_levelsToCalculate){
        _levelsToCalculate = [[NSMutableSet alloc] init];
        for(int i=0;i<self.numPyramids;i++)
            [_levelsToCalculate addObject:[NSNumber numberWithInt:i]];
    }
    return _levelsToCalculate;
}


#pragma mark -
#pragma mark Public Methods


- (void) constructPyramidForImage:(UIImage *)image withOrientation:(int)orientation
{
    //rotate image depending on the orientation
    //TODO: take out the orientation of the pyramid!!
    if(UIDeviceOrientationIsLandscape(orientation))
        image = [UIImage imageWithCGImage:image.CGImage scale:1.0 orientation:UIImageOrientationUp];
    
    //scaling factor for the image
    double initialScale = self.scaleFactor.doubleValue/sqrt(image.size.width*image.size.width);
    double scale = pow(2, 1.0/SCALES_PER_OCTAVE);
    UIImage *scaledImage = [image scaleImageTo:initialScale/pow(scale,0)]; //TODO: optimize to start to the first true index
    
    for(int i=0; i<self.numPyramids; i++){
        if([self.levelsToCalculate containsObject:[NSNumber numberWithInt:i]]){
            float scaleLevel = pow(1.0/scale, i);
            HogFeature *imageHog = [[scaledImage scaleImageTo:scaleLevel] obtainHogFeatures];
            [self.hogFeatures setObject:imageHog atIndexedSubscript:i];
        }
    }

    //reset indexes to look into
    [self.levelsToCalculate removeAllObjects];
    
}

@end
