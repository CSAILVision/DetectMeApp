//
//  TrainingImagesCollectionViewController.m
//  DetectTube
//
//  Created by Josep Marc Mingot Hidalgo on 25/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "TrainingImagesCollectionViewController.h"
#import "TrainingImageCell.h"
#import "DetectorTrainer.h"
#import "TrainingViewController.h"
#import "AnnotatedImage.h"

@interface TrainingImagesCollectionViewController ()
{
    DetectorTrainer *_detectorTrainer;
    NSMutableArray *_images;
    NSMutableArray *_boxes;
}

@end

@implementation TrainingImagesCollectionViewController

#pragma mark -
#pragma mark initialization

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"loading");
    //detector trainner initilization
    _detectorTrainer = [[DetectorTrainer alloc] init];
    _detectorTrainer.name = self.detector.name;
    _detectorTrainer.targetClass = self.detector.targetClass;
    _detectorTrainer.isPublic = self.detector.isPublic.boolValue;
    
    
    NSArray *annotatedImages = [self.detector.annotatedImages allObjects];
    _images = [[NSMutableArray alloc] initWithCapacity:annotatedImages.count];
    _boxes = [[NSMutableArray alloc] initWithCapacity:annotatedImages.count];
    for(AnnotatedImage *annotatedImage in annotatedImages){
        
        UIImage *image = [UIImage imageWithData:annotatedImage.image];
        [_images addObject:image];
        
        CGPoint upperLeft = CGPointMake(annotatedImage.boxX.floatValue, annotatedImage.boxY.floatValue);
        CGPoint lowerRight = CGPointMake(annotatedImage.boxX.floatValue + annotatedImage.boxWidth.floatValue,
                                         annotatedImage.boxY.floatValue + annotatedImage.boxHeight.floatValue);
        [_boxes addObject:[[Box alloc] initWithUpperLeft:upperLeft lowerRight:lowerRight forImageSize:image.size]];
    }
    
	// Do any additional setup after loading the view.
}



#pragma mark -
#pragma mark Data Source


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TrainingImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"trainingCell" forIndexPath:indexPath];
    cell.imageView.image = [_images objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark -
#pragma mark IBActions
- (IBAction)deleteAction:(UIButton *)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero fromView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:buttonPosition];
    [_images removeObjectAtIndex:indexPath.row];
    [_boxes removeObjectAtIndex:indexPath.row];
    [self.collectionView reloadData];
}

#pragma mark -
#pragma mark TakePictureViewControllerDelegate

- (void) takenImages:(NSArray *)images withBoxes:(NSArray *)boxes
{
    [_images addObjectsFromArray:images];
    [_boxes addObjectsFromArray:boxes];
    [self.collectionView reloadData];

}

#pragma mark -
#pragma mark TagViewControllerDelegate

- (void) finishEditingWithBoxes:(NSMutableArray *)boxes
{
    _boxes = boxes;
}


#pragma mark -
#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowTagView"]) {
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] lastObject];
        
        TagViewController *tagVC = (TagViewController *) segue.destinationViewController;
        tagVC.images = _images;
        tagVC.boxes = _boxes;
        tagVC.currentIndex = indexPath.row;
        tagVC.delegate = self;
        
    }else if([[segue identifier] isEqualToString:@"Retrain"]){
        _detectorTrainer.images = _images;
        _detectorTrainer.boxes = _boxes;
        TrainingViewController *trainingVC = segue.destinationViewController;
        trainingVC.detectorTrainer = _detectorTrainer;
        trainingVC.detector = self.detector;
        
    }else if([[segue identifier] isEqualToString:@"TakePicture"]){
        TakePictureViewController *takePictureVC = (TakePictureViewController *) segue.destinationViewController;
        takePictureVC.delegate = self;
        takePictureVC.hideNextButton = YES;
        
    }
}


@end
