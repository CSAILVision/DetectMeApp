//
//  Detector.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 28/02/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#include <opencv2/core/core.hpp>

#include <opencv2/ml/ml.hpp>
#include <stdlib.h>

#import "DetectorWrapper.h"
#import "UIImage+HOG.h"
#import "UIImage+Resize.h"
#import "ConvolutionHelper.h"
#import "BoundingBox.h"
#import "NSArray+JSONHelper.h"


using namespace cv;

// training parameters
#define MAX_QUOTA 100 //max negative examples (bb) per iteration
#define MAX_TEMPLATE_SIZE 8
#define STOP_CRITERIA 0.01
#define MAX_TRAINING_ITERATIONS 20
#define NUM_TRAINING_PYRAMIDS 10
#define SVM_C 0.2
#define POSITIVE_OVERLAP_AREA 0.7
#define NEGATIVE_OVERLAP_AREA 0.5
#define TRAINING_SCALE_FACTOR 0.5 //scale factor for detection on training images

// alloc size
#define MAX_TRAINING_IMAGES 35
#define MAX_NUMBER_EXAMPLES (MAX_QUOTA + 200)*MAX_TRAINING_IMAGES //max number of examples in buffer, (500neg + 200pos)*20images

//training results
#define SUCCESS 1
#define INTERRUPTED 2 //and not trained
#define FAIL 0


@interface DetectorWrapper ()
{
    int *_sizesP; //Array with the dimensions of the features: hog_width x hog_height x features_per_hog_bin
    double *_weightsP; //Array with the weights obtained in each dimension
    
    int _numOfFeatures;
    int _numSupportVectors;
    float _diff;
    int _levelsPyramid[10]; //how many bb of each level do we obtain
    
    BOOL _isLearning;
    
    //pyramid limits for detection in execution
    int _iniPyramid;
    int _finPyramid;    
    
    //detector buffer (when training)
    NSMutableArray *_receivedImageIndex;
    NSMutableArray *_imagesHogPyramid;
    
    BOOL _isTrainCancelled;
    
    float *_trainingImageLabels; //Array containg the labels for the training set
    float *_trainingImageFeatures; //Matrix containing the features for each image of the training set
    int _numberOfTrainingExamples; //Counter of the total number of training images
}


// Show just the histogram features for debugging purposes
- (void) showOrientationHistogram;

// Make the convolution of the detector with the image and return de detected bounding boxes
- (NSArray *) getBoundingBoxesIn:(HogFeature *)imageHog forPyramid:(int)pyramidLevel forIndex:(int)imageHogIndex;

// Add a selected bounding box (its correspondent hog features) to the training buffer
- (void) addExample:(BoundingBox *)p to:(TrainingSet *)trainingSet;

// Calculate difference of weight wihtin an iteration to find that difference
- (double) computeDifferenceWithLastWeights:(double *) weightsPLast;

// Print unoriented hog features for debugging purposes
- (void) printListHogFeatures;

@end


@implementation DetectorWrapper


#pragma mark -
#pragma mark Initialization

- (id) init
{
    if (self = [super init]) {
        //dummy initialization to be replaced during the training
        _sizesP = (int *) malloc(3*sizeof(int)); _sizesP[0] = 1; _sizesP[1] = 1; _sizesP[2] = 1;
        _weightsP = (double *) malloc(sizeof(double)); _weightsP[0] = 0;
    }
    
    return self;
}


- (id) initWithDetector:(Detector *) detector
{
    if (self = [super init]) {
        self.targetClasses = [NSArray arrayWithObject:detector.targetClass];
        self.weights = [[NSArray arrayFromJSON:detector.weights] mutableCopy];
        self.sizes = [NSArray arrayFromJSON:detector.sizes];

        self.detectionThreshold = detector.detectionThreshold;
        
        // set _sizesP
        free(_sizesP);
        _sizesP = (int *) malloc(3*sizeof(int));
        _sizesP[0] = [(NSNumber *) [self.sizes objectAtIndex:0] intValue];
        _sizesP[1] = [(NSNumber *) [self.sizes objectAtIndex:1] intValue];
        _sizesP[2] = [(NSNumber *) [self.sizes objectAtIndex:2] intValue];

        int numberOfWeights = _sizesP[0]*_sizesP[1]*_sizesP[2] + 1; //+1 for the bias

        // set _weightsP
//        free(_weightsP);
//        _weightsP = (double *) malloc(numberOfWeights*sizeof(double));
//        for(int i=0; i<numberOfWeights; i++)
//            _weightsP[i] = [(NSNumber *) [self.weights objectAtIndex:i] doubleValue];
        
        // support vectors
        if(detector.supportVectors && detector.parentID>0){
            NSString *supportVectorsString = [[NSString alloc] initWithData:detector.supportVectors encoding:NSUTF8StringEncoding];
            self.supportVectors = [NSMutableArray arrayWithArray:
                                   [SupportVector suppportVectorsFromJSON:supportVectorsString]];
            supportVectorsString = nil;
                                
        }
    }
    
    return self;
    
}


- (void) dealloc
{
    free(_sizesP);
    free(_weightsP);
}


#pragma mark -
#pragma mark Getters and Setters

- (NSNumber *) detectionThreshold
{
    if(!_detectionThreshold) _detectionThreshold = [NSNumber numberWithFloat:0.5];
    return _detectionThreshold;
}


#pragma mark -
#pragma mark Public Methods

- (int) trainOnSet:(TrainingSet *)trainingSet
{
    NSDate *start = [NSDate date]; //to compute the training time.

    _isLearning = YES;
    
    //array initialization
    _imagesHogPyramid = [[NSMutableArray alloc] init];
    for (int i = 0; i < trainingSet.images.count*NUM_TRAINING_PYRAMIDS; ++i)
        [_imagesHogPyramid addObject:[NSNull null]];
    _receivedImageIndex = [[NSMutableArray alloc] init];
    
    //set hog dimension according to the max Hog set in user preferences
    float ratio = [trainingSet getAverageGroundTruthAspectRatio]; // w/h
    if(ratio<1){
        _sizesP[0] = MAX_TEMPLATE_SIZE;
        _sizesP[1] = round(_sizesP[0]*ratio);

    }else{
        _sizesP[1] = MAX_TEMPLATE_SIZE;
        _sizesP[0] = round(_sizesP[1]/ratio);
    }
    _sizesP[2] = 31;
    
    _numOfFeatures = _sizesP[0]*_sizesP[1]*_sizesP[2];
    [self.delegate sendMessage:[NSString stringWithFormat:@"Hog features: %d %d %d for ratio:%f", _sizesP[0],_sizesP[1],_sizesP[2], ratio]];
    
    //define buffer sizes
    //TODO: max size for the buffers
    _trainingImageFeatures = (float *) malloc(MAX_NUMBER_EXAMPLES*_numOfFeatures*sizeof(float));
    _trainingImageLabels = (float *) malloc(MAX_NUMBER_EXAMPLES*sizeof(float));
    
    //convergence loop
    free(_weightsP);
    _weightsP = (double *) calloc((_numOfFeatures + 1),sizeof(double));
    for(int i=0; i<_numOfFeatures+1; i++) _weightsP[i] = 1;
    double *weightsPLast = (double *) calloc((_numOfFeatures + 1),sizeof(double));
    _diff = 1;
    int iter = 0;
    _numSupportVectors=0;
    BOOL firstTimeError = YES;
    
    // Used to train detectors from the server that just have the support vectors
    
    if(self.supportVectors) [self initializeDetectorWithSupportVectors];
    
    
    while(_diff > STOP_CRITERIA && iter<MAX_TRAINING_ITERATIONS && !_isTrainCancelled){
        
        
        [self.delegate sendMessage:[NSString stringWithFormat:@"\n******* Iteration %d *******", iter]];
        
        //Get Bounding Boxes from detection
        [self getBoundingBoxesForTrainingSet:trainingSet];
        

        //The first time that not enough positive or negative bb have been generated (due to bb with different geometries), try to unify all the sizes of the bounding boxes. This solve the problem in most of the cases at the cost of losing accuracy. However if still not solved, give an error saying not possible training done due to the ground truth bouning boxes shape.
        if(self.numberOfPositives.intValue < 2 || self.numberOfPositives.intValue == _numberOfTrainingExamples){
            if(firstTimeError){
                [trainingSet unifyGroundTruthBoundingBoxes];
                firstTimeError = NO;
                continue;
            }else{
                free(weightsPLast);
                free(_trainingImageFeatures);
                free(_trainingImageLabels);
                return FAIL;
            }
        }
        
        //Train the SVM, update weights and store support vectors and labels
        [self trainSVMAndGetWeights];
        
        _diff = [self computeDifferenceWithLastWeights:weightsPLast];
        iter++;
        if(iter!=1) [self.delegate updateProgress:STOP_CRITERIA/_diff];
    }
    
    if(_isTrainCancelled){
        [self.delegate sendMessage:@"\n TRAINING INTERRUPTED \n"];
        free(weightsPLast);
        free(_trainingImageFeatures);
        free(_trainingImageLabels);
        return INTERRUPTED;
    }

    //update information about the detector
    self.timeLearning = @(-[start timeIntervalSinceNow]);
    [self saveWeights];
    [self storeSupportVectors];
    
    //See the results on training set
    [self.delegate updateProgress:1];
    _isLearning = NO;
    _imagesHogPyramid = nil;
    _receivedImageIndex = nil;
    free(weightsPLast);
    free(_trainingImageFeatures);
    free(_trainingImageLabels);
    
    return SUCCESS; 
}

- (void) saveWeights
{
    self.sizes = [[NSArray alloc] initWithObjects:
                  [NSNumber numberWithInt:_sizesP[0]],
                  [NSNumber numberWithInt:_sizesP[1]],
                  [NSNumber numberWithInt:_sizesP[2]], nil];
    
    int numberOfSvmWeights = _sizesP[0]*_sizesP[1]*_sizesP[2] + 1; //+1 for the bias
    
    self.weights = [[NSMutableArray alloc] initWithCapacity:numberOfSvmWeights];
    for(int i=0; i<numberOfSvmWeights; i++)
        [self.weights addObject:[NSNumber numberWithDouble:_weightsP[i]]];
}

- (NSArray *) detect:(UIImage *)image
    minimumThreshold:(double) detectionThreshold
            pyramids:(int)numberPyramids
            usingNms:(BOOL)useNms
   deviceOrientation:(int)orientation
  learningImageIndex:(int) imageIndex

{
    NSMutableArray *candidateBoundingBoxes = [[NSMutableArray alloc] init];

    //scaling factor for the image
    float ratio = image.size.width*1.0 / image.size.height;
    double initialScale = SCALE_FACTOR;
    if(ratio>1) initialScale = initialScale * 1.3;
    double scale = pow(2, 1.0/SCALES_PER_OCTAVE);

    //Pyramid limits
    if(_finPyramid == 0) _finPyramid = numberPyramids;
    
    //locate pyramids already calculated in the buffer
    BOOL found=NO;
    if(_isLearning){
        
        //SCALE
        initialScale = TRAINING_SCALE_FACTOR;
        
        //pyramid limits
        _iniPyramid = 0; _finPyramid = numberPyramids;
        
        //Locate pyramids in buffer
        found = YES;
        if([_receivedImageIndex indexOfObject:[NSNumber numberWithInt:imageIndex]] == NSNotFound || _receivedImageIndex.count == 0){
            [_receivedImageIndex addObject:[NSNumber numberWithInt:imageIndex]];
            found = NO;
        }
    }
    
    dispatch_queue_t pyramidQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    UIImage *im = [image scaleImageTo:initialScale/pow(scale,_iniPyramid)];
    
    dispatch_apply(_finPyramid - _iniPyramid, pyramidQueue, ^(size_t i) {
        HogFeature *imageHog;
        int imageHogIndex = 0;
        float scaleLevel = pow(1.0/scale, i);
        if(!found){
            imageHog = [[im scaleImageTo:scaleLevel] obtainHogFeatures];
//            NSLog(@"Pyramid %zd, numblocs x:%d, numblocks y:%d", i, imageHog.numBlocksX, imageHog.numBlocksY);
            
            if(_isLearning){
                imageHogIndex = imageIndex*numberPyramids + i + _iniPyramid;
                [_imagesHogPyramid replaceObjectAtIndex:imageHogIndex withObject:imageHog];
            }
        }else{
            imageHogIndex = (imageIndex*numberPyramids + i + _iniPyramid);
            imageHog = (HogFeature *)[_imagesHogPyramid objectAtIndex:imageHogIndex];
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            [candidateBoundingBoxes addObjectsFromArray:[self getBoundingBoxesIn:imageHog forPyramid:i + _iniPyramid forIndex:imageHogIndex]];
        });
    });
    
    
    //sort array of bounding boxes by score
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *candidateBoundingBoxesSorted = [candidateBoundingBoxes sortedArrayUsingDescriptors:sortDescriptors];
    
    NSArray *nmsArray = candidateBoundingBoxesSorted;
    if(useNms) nmsArray = [ConvolutionHelper nms:candidateBoundingBoxesSorted maxOverlapArea:0.25 minScoreThreshold:detectionThreshold]; 

    if(!_isLearning && nmsArray.count > 0){
        //get the level of the maximum score bb
        int level = [(BoundingBox*)[nmsArray objectAtIndex:0] pyramidLevel];
        _iniPyramid = level-1 > -1 ? level - 1 : 0;
        _finPyramid = level+2 < numberPyramids ? level+2 : numberPyramids;
    }else{
        _iniPyramid = 0;
        _finPyramid = numberPyramids;
    }
    
    // Change the resulting orientation of the bounding boxes if the phone orientation requires it
    if(!_isLearning && UIInterfaceOrientationIsLandscape(orientation)){
        for(int i=0; i<nmsArray.count; i++){
            BoundingBox *boundingBox = [nmsArray objectAtIndex:i];
            double auxXmin, auxXmax;
            auxXmin = boundingBox.xmin;
            auxXmax = boundingBox.xmax;
            boundingBox.xmin = (1 - boundingBox.ymin);
            boundingBox.xmax = (1 - boundingBox.ymax);
            boundingBox.ymin = auxXmin;
            boundingBox.ymax = auxXmax;
        }
    }
    return nmsArray;
}



- (NSArray *) detect:(Pyramid *) pyramid
    minimumThreshold:(double) detectionThreshold
            usingNms:(BOOL)useNms
         orientation:(int)orientation
{
    //get detections for each pyramid level (parallel processing)
    NSMutableArray *candidateBoundingBoxes = [[NSMutableArray alloc] init];    
    __block NSArray *candidatesForLevel;
    dispatch_queue_t pyramidQueue = dispatch_queue_create("pyramidQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_apply(_finPyramid - _iniPyramid, pyramidQueue, ^(size_t i) {
        if([[pyramid.hogFeatures objectAtIndex:i + _iniPyramid] isKindOfClass:[HogFeature class]]){
            __block HogFeature *imageHog;
            dispatch_sync(dispatch_get_main_queue(), ^{
                imageHog = [pyramid.hogFeatures objectAtIndex:i + _iniPyramid];
            });
            candidatesForLevel = [self getBoundingBoxesIn:imageHog forPyramid:i+_iniPyramid forIndex:0];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [candidateBoundingBoxes addObjectsFromArray:candidatesForLevel];
        });
    });
    
    //sort array of bounding boxes by score
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *candidateBoundingBoxesSorted = [candidateBoundingBoxes sortedArrayUsingDescriptors:sortDescriptors];
    
    //non maximum supression
    NSArray *nmsArray = candidateBoundingBoxesSorted;
    if(useNms) nmsArray = [ConvolutionHelper nms:candidateBoundingBoxesSorted maxOverlapArea:0.25 minScoreThreshold:detectionThreshold];
    
    //update the pyramid object with the desired pyramids for the next time
    if(nmsArray.count > 0){
        //get the level of the maximum score bb
        int level = [(BoundingBox*)[nmsArray objectAtIndex:0] pyramidLevel];
        _iniPyramid = level-1 > -1 ? level - 1 : 0;
        _finPyramid = level+2 < pyramid.numPyramids ? level+2 : pyramid.numPyramids;
    }else{
        _iniPyramid = 0;
        _finPyramid = pyramid.numPyramids;
    }
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        for(int i=_iniPyramid;i<_finPyramid;i++)
            [pyramid.levelsToCalculate addObject:[NSNumber numberWithInt:i]];
    });

    
    // Change the resulting orientation of the bounding boxes if the phone orientation requires it
    if(!_isLearning && UIInterfaceOrientationIsLandscape(orientation)){
        for(int i=0; i<nmsArray.count; i++){
            BoundingBox *boundingBox = [nmsArray objectAtIndex:i];
            double auxXmin, auxXmax;
            auxXmin = boundingBox.xmin;
            auxXmax = boundingBox.xmax;
            boundingBox.xmin = (1 - boundingBox.ymin);
            boundingBox.xmax = (1 - boundingBox.ymax);
            boundingBox.ymin = auxXmin;
            boundingBox.ymax = auxXmax;
        }
    }
    
    return nmsArray;
}


- (void) testOnSet:(TrainingSet *)testSet atThresHold:(float)detectionThreshold
{
    
    _isLearning = YES;
    //TODO: not multiimage
    int tp=0, fp=0, fn=0;// tn=0;
    for(BoundingBox *groundTruthBoundingBox in testSet.groundTruthBoundingBoxes){
        bool found = NO;
        UIImage *selectedImage = [testSet.images objectAtIndex:groundTruthBoundingBox.imageIndex];
        NSArray *detectedBoundingBoxes = [self detect:selectedImage minimumThreshold:detectionThreshold pyramids:10 usingNms:YES deviceOrientation:UIImageOrientationUp learningImageIndex:groundTruthBoundingBox.imageIndex];
        for(BoundingBox *detectedBoundingBox in detectedBoundingBoxes)
            if ([detectedBoundingBox fractionOfAreaOverlappingWith:groundTruthBoundingBox]>0.5){
                tp++;
                found = YES;
            }else fp++;
        
        if(!found) fn++;
        //NSLog(@"tp at image %d: %d", groundTruthBoundingBox.imageIndex, tp);
        //NSLog(@"fp at image %d: %d", groundTruthBoundingBox.imageIndex, fp);
        //NSLog(@"fn at image %d: %d", groundTruthBoundingBox.imageIndex, fn);
    }

    [self.delegate sendMessage:[NSString stringWithFormat:@"PRECISION: %f", tp*1.0/(tp+fp)]];
    [self.delegate sendMessage:[NSString stringWithFormat:@"RECALL: %f", tp*1.0/(tp+fn)]];
    self.precisionRecall = [[NSArray alloc] initWithObjects:[NSNumber numberWithDouble:tp*1.0/(tp+fp)],[NSNumber numberWithDouble:tp*1.0/(tp+fn)] ,nil];
    
    _isLearning = NO;
}


-(void) cancelTraining
{
    _isTrainCancelled = YES;
}


- (UIImage *) getHogImageOfTheWeights
{
    return [UIImage hogImageFromFeatures:_weightsP withSize:_sizesP];
}

#pragma mark -
#pragma mark Private methods

- (NSArray *) getBoundingBoxesIn:(HogFeature *)imageHog forPyramid:(int)pyramidLevel forIndex:(int)imageHogIndex
{
    int blocks[2] = {imageHog.numBlocksY, imageHog.numBlocksX};
    
    int convolutionSize[2];
    
    convolutionSize[0] = blocks[0] - _sizesP[0] + 1;
    convolutionSize[1] = blocks[1] - _sizesP[1] + 1;
    if ((convolutionSize[0]<=0) || (convolutionSize[1]<=0))
        return NULL;
    
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:convolutionSize[0]*convolutionSize[1]];
    double *c = (double *) calloc(convolutionSize[0]*convolutionSize[1],sizeof(double)); //initialize the convolution result
    
    // convolve and add the result
    for (int f = 0; f < _sizesP[2]; f++){
        
        double *dst = c;
        double *A_src = imageHog.features + f*blocks[0]*blocks[1]; //Select the block of features to do the convolution with
        double *B_src = _weightsP + f*_sizesP[0]*_sizesP[1];
        
        // convolute and add the results to dst
        [ConvolutionHelper convolution:dst matrixA:A_src :blocks matrixB:B_src :_sizesP];
        //[ConvolutionHelper convolutionWithVDSP:dst matrixA:A_src :blocks matrixB:B_src :templateSize];
        
    }
    
    //detect max in the convolution
    double bias = _weightsP[_sizesP[0]*_sizesP[1]*_sizesP[2]];
    for (int x = 0; x < convolutionSize[1]; x++) {
        for (int y = 0; y < convolutionSize[0]; y++) {
            
            BoundingBox *p = [[BoundingBox alloc] init];
            p.score = (*(c + x*convolutionSize[0] + y) - bias);
            if( p.score > -1 ){
                
                p.xmin = (double)(x + 1)/((double)blocks[1] + 2);
                p.xmax = (double)(x + 1)/((double)blocks[1] + 2) + ((double)_sizesP[1]/((double)blocks[1] + 2));
                p.ymin = (double)(y + 1)/((double)blocks[0] + 2);
                p.ymax = (double)(y + 1)/((double)blocks[0] + 2) + ((double)_sizesP[0]/((double)blocks[0] + 2));
                p.pyramidLevel = pyramidLevel;
                p.targetClass = [self.targetClasses componentsJoinedByString:@"+"];
                
                //save the location and image hog for the later feature extraction during the learning
                if(_isLearning){
                    p.locationOnImageHog = CGPointMake(x, y);
                    p.imageHogIndex = imageHogIndex;
                }
                [result addObject:p];
            }
        }
    }
    free(c);
    return result;
}


-(void) addExample:(BoundingBox *)boundingBox to:(TrainingSet *)trainingSet
{
    // Adds a BoundingBox to the C array _trainingImageFeatures, container of all the features
    //   and its values
    // Note: be sure to run it on the main thread to avoid collision
    //   when called from the concurrent |getBoundingBoxesForTrainingSet:trainingSet|
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (boundingBox.label != 0 && _numberOfTrainingExamples+1 < MAX_NUMBER_EXAMPLES) {
            
            int index = _numberOfTrainingExamples;
            HogFeature *imageHog = [_imagesHogPyramid objectAtIndex:boundingBox.imageHogIndex];
            
            //label
            _trainingImageLabels[index] = boundingBox.label;
            
            //features
            int boundingBoxPosition = boundingBox.locationOnImageHog.y + boundingBox.locationOnImageHog.x*imageHog.numBlocksY;
            for(int f=0; f<_sizesP[2]; f++)
                for(int i=0; i<_sizesP[1]; i++)
                    for(int j=0; j<_sizesP[0]; j++){
                        int sweeping1 = j + i*_sizesP[0] + f*_sizesP[0]*_sizesP[1];
                        int sweeping2 = j + i*imageHog.numBlocksY + f*imageHog.numBlocksX*imageHog.numBlocksY;
                        _trainingImageFeatures[index*_numOfFeatures + sweeping1] = (float) imageHog.features[boundingBoxPosition + sweeping2];
                    }

            _numberOfTrainingExamples++;
        }
    });
}

- (void) getBoundingBoxesForTrainingSet:(TrainingSet *)trainingSet
{
    // (1) Runs the current detector and gets detected Bounding Boxes (BB)
    // (2) if positive(overlap area with ground truth gounding box greater than threshold): add positive example
    // (3) if negatve and quota not full: add negative example
    // Note: the detector is run in parallel across the training images
    // Note: quota is just a maximum number of allowed negative examples per image. It is mainly for memory
    //   issues and it also helps to keep the classes balanced.
    
    __block int positives = 0;
    _numberOfTrainingExamples = _numSupportVectors;
    
    dispatch_queue_t trainingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(trainingSet.images.count, trainingQueue, ^(size_t i) {
        if(!_isTrainCancelled){
            
            UIImage *image = [trainingSet.images objectAtIndex:i];
            
            // We add images with no annotations to make robust training with few examples
            BoundingBox *groundTruthBB;
            if(i<trainingSet.groundTruthBoundingBoxes.count)
                groundTruthBB = [trainingSet.groundTruthBoundingBoxes objectAtIndex:i];
            
            //run the detector on the current image
            NSArray *detectedBoundingBoxes = [self detect:image minimumThreshold:-1 pyramids:NUM_TRAINING_PYRAMIDS usingNms:NO deviceOrientation:UIImageOrientationUp learningImageIndex:i];
            
            
            // max negative bounding boxes detected allowed per image
            // It is done for memory purposes and it also helps keep balanced classes
            int quota = MAX_QUOTA;
            
            int image_positives = 0;
            for(BoundingBox *detectedBB in detectedBoundingBoxes){
                
                double overlapArea = [detectedBB fractionOfAreaOverlappingWith:groundTruthBB];
                
                detectedBB.label = 0;
                if (overlapArea > POSITIVE_OVERLAP_AREA && overlapArea<1){
                    detectedBB.label = 1;
                    positives++;
                    image_positives++;
                    [self addExample:detectedBB to:trainingSet];
                }else if(overlapArea < NEGATIVE_OVERLAP_AREA && quota>0){
                    quota--;
                    detectedBB.label = -1;
                    [self addExample:detectedBB to:trainingSet];
                }
            }
            
            dispatch_sync(dispatch_get_main_queue(),^{
                [self.delegate sendMessage:[NSString stringWithFormat:@"BB for image %zd (positive/total): %d/%d", i, image_positives,detectedBoundingBoxes.count]];
            });
        }
    });
    
    
    int positius = 0;
    for(int i=0; i<_numberOfTrainingExamples;i++){
        if(_trainingImageLabels[i]==1.0) positius++;
    }
    
    [self.delegate sendMessage:[NSString stringWithFormat:@"added %d NEW positives", positives]];
    [self.delegate sendMessage:[NSString stringWithFormat:@"positives/total (incl   uding previous SV): %d/%d", positius, _numberOfTrainingExamples]];
    
    self.numberOfPositives = @(positives);
}


-(void) trainSVMAndGetWeights
{
    int positives=0;
    
    Mat labelsMat(_numberOfTrainingExamples,1,CV_32FC1, _trainingImageLabels);
    Mat trainingDataMat(_numberOfTrainingExamples, _numOfFeatures, CV_32FC1, _trainingImageFeatures);
    //std::cout << trainingDataMat << std::endl; //output learning matrix
    
    // Set up SVM's parameters
    CvSVMParams params;
    params.svm_type    = CvSVM::C_SVC;
    params.kernel_type = CvSVM::LINEAR;
    params.C = SVM_C;
    params.term_crit   = cvTermCriteria(CV_TERMCRIT_ITER, 1000, 1e-6);
    
    CvSVM SVM;
    SVM.train(trainingDataMat, labelsMat, Mat(), Mat(), params);
    
    //update weights and store the support vectors
    _numSupportVectors = SVM.get_support_vector_count();
    
    _numberOfTrainingExamples = _numSupportVectors+self.supportVectors.count;
    
    const CvSVMDecisionFunc *dec = SVM.decision_func;
    
    for(int i=0; i<_numOfFeatures+1; i++) _weightsP[i] = 0.0;
    
    for (int i=0; i<_numSupportVectors; i++){
        
        float alpha = dec[0].alpha[i];
        const float *supportVector = SVM.get_support_vector(i);
        float *sv_aux = (float *) malloc(_numOfFeatures*sizeof(float));
        for(int j=0;j<_numOfFeatures;j++) //const float* to float*
            sv_aux[j] = supportVector[j];
        
        // Get the current label of the supportvector
        Mat supportVectorMat(_numOfFeatures,1,CV_32FC1, sv_aux);
        _trainingImageLabels[i+self.supportVectors.count] = SVM.predict(supportVectorMat);
        if(_trainingImageLabels[i+self.supportVectors.count]==1) positives++;
        free(sv_aux);
        
        //NSLog(@"label: %f   alpha: %f \n", _trainingImageLabels[i], alpha);
        
        for(int j=0;j<_numOfFeatures;j++){
            // add to get the svm weights
            _weightsP[j] -= (double) alpha * supportVector[j];
            
            //store the support vector as the first features
            _trainingImageFeatures[(i+self.supportVectors.count)*_numOfFeatures + j] = supportVector[j];
        }
    }
    
    //Update the number of positives
    for(int i=0; i<self.supportVectors.count; i++) if(_trainingImageLabels[i]==1) positives++;
    
    
    _weightsP[_numOfFeatures] = - (double) dec[0].rho; // The sign of the bias and rho have opposed signs.
    self.numberOfPositives = [[NSNumber alloc] initWithInt:positives];
    [self.delegate sendMessage:[NSString stringWithFormat:@"Finished training!"]];
    [self.delegate sendMessage:[NSString stringWithFormat:@"SV (positives/total): %d/%d", positives,_numSupportVectors]];
    [self.delegate sendMessage:[NSString stringWithFormat:@"bias: %f", _weightsP[_numOfFeatures]]];
}


-(double) computeDifferenceWithLastWeights:(double *) weightsPLast
{
    _diff=0.0;
    
    double norm=0, normLast=0;
    for(int i=0; i<_sizesP[0]*_sizesP[1]*_sizesP[2] + 1; i++){
        norm += _weightsP[i]*_weightsP[i];
        normLast += weightsPLast[i]*weightsPLast[i];
    }
    norm = sqrt(norm);
    normLast = normLast!=0 ? sqrt(normLast):1;
    

    for(int i=0; i<_sizesP[0]*_sizesP[1]*_sizesP[2] + 1; i++){
        _diff += (_weightsP[i]/norm - weightsPLast[i]/normLast)*(_weightsP[i]/norm - weightsPLast[i]/normLast);
        weightsPLast[i] = _weightsP[i];
    }
    [self.delegate sendMessage:[NSString stringWithFormat:@"difference of norms: %f", sqrt(_diff)]];
    
    return sqrt(_diff);
}

#pragma mark -
#pragma mark Support Vectors

- (void) initializeDetectorWithSupportVectors
{
    // Initialize the detector with the previous weights
    _numSupportVectors = self.supportVectors.count;
    _numberOfTrainingExamples = _numSupportVectors;
    _numOfFeatures = [(SupportVector *)[self.supportVectors firstObject] weights].count;
    
    _sizesP[0] = [(NSNumber *) [self.sizes objectAtIndex:0] intValue];
    _sizesP[1] = [(NSNumber *) [self.sizes objectAtIndex:1] intValue];
    _sizesP[2] = [(NSNumber *) [self.sizes objectAtIndex:2] intValue];
    
    NSLog(@"Initial number of SV: %d", _numSupportVectors);
    
    for (int i=0; i<_numSupportVectors; i++){
        SupportVector *sv = (SupportVector *)[self.supportVectors objectAtIndex:i];
        
        _trainingImageLabels[i] = sv.label.floatValue;
        
        for(int j=0;j<_numOfFeatures;j++){
            float weight = [(NSNumber *)[sv.weights objectAtIndex:j] floatValue];
            _trainingImageFeatures[i*_numOfFeatures + j] = weight;
        }
    }
}


- (void) storeSupportVectors
{
    // Retrieve from the current traning set the support vectors stored there
    
    self.supportVectors = [[NSMutableArray alloc] initWithCapacity:_numSupportVectors];
    
    for (int i=self.supportVectors.count; i<_numSupportVectors; i++){
        float label = _trainingImageLabels[i];
        
        NSMutableArray *weights = [[NSMutableArray alloc] initWithCapacity:_numOfFeatures];
        for(int j=0;j<_numOfFeatures;j++){
            
            //store the support vector as the first features
            float weight = _trainingImageFeatures[i*_numOfFeatures + j];
            [weights addObject:@(weight)];
        }
        SupportVector *sv = [[SupportVector alloc] initWithWeights:weights forLabel:@(label)];
        [self.supportVectors addObject:sv];
    }
}

#pragma mark -
#pragma mark Visualization

- (void) printListHogFeatures
{
    //Print unoriented hog features for debugging purposes
    for(int y=0; y<_sizesP[0]; y++){
        for(int x=0; x<_sizesP[1]; x++){
            for(int f = 18; f<27; f++){
                printf("%f ", _weightsP[y + x*7 + f*7*5]);
                //                if(f==17 || f==26) printf("  |  ");
            }
            printf("\n");
        }
        printf("\n*************************************************************************\n");
    }
}


- (void) showOrientationHistogram
{
    double *histogram = (double *) calloc(18,sizeof(double));
    for(int x = 0; x<_sizesP[1]; x++)
        for(int y=0; y<_sizesP[0]; y++)
            for(int f=18; f<27; f++)
                histogram[f-18] += _weightsP[y + x*_sizesP[0] + f*_sizesP[0]*_sizesP[1]];
    
    printf("Orientation Histogram\n");
    for(int i=0; i<9; i++)
        printf("%f ", histogram[i]);
    printf("\n");
    
    free(histogram);
}

@end
