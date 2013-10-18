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
#import "ManagedDocumentHelper.h"
#import "AnnotatedImage+Create.h"

@interface TrainingImagesCollectionViewController ()
{
    DetectorTrainer *_detectorTrainer;
    UIManagedDocument *_detectorDatabase;
    NSMutableArray *_annotatedImages;
}

@end

@implementation TrainingImagesCollectionViewController

#pragma mark -
#pragma mark initialization

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //detector trainner initilization
    _detectorTrainer = [[DetectorTrainer alloc] init];
    _detectorTrainer.name = self.detector.name;
    _detectorTrainer.targetClass = self.detector.targetClass;
    _detectorTrainer.isPublic = self.detector.isPublic.boolValue;
    
    if(!_detectorDatabase)
        _detectorDatabase = [ManagedDocumentHelper sharedDatabaseUsingBlock:^(UIManagedDocument *document){}];
    
    _annotatedImages = [NSMutableArray arrayWithArray:[self.detector.annotatedImages allObjects]];
    
	// Do any additional setup after loading the view.
}



#pragma mark -
#pragma mark Data Source


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _annotatedImages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TrainingImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"trainingCell" forIndexPath:indexPath];
    AnnotatedImage *annotatedImage = [_annotatedImages objectAtIndex:indexPath.row];
    UIImage *image = [UIImage imageWithData:annotatedImage.image];
    cell.imageView.image = image;
    return cell;
}

#pragma mark -
#pragma mark IBActions
- (IBAction)deleteAction:(UIButton *)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero fromView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:buttonPosition];
    AnnotatedImage *deleted = [_annotatedImages objectAtIndex:indexPath.row];
    [_annotatedImages removeObjectAtIndex:indexPath.row];
    [_detectorDatabase.managedObjectContext deleteObject:deleted];

    [self.collectionView reloadData];
}

#pragma mark -
#pragma mark TakePictureViewControllerDelegate


- (void) takenAnnotatedImages:(NSArray *) annotatedImages
{
    [_annotatedImages addObjectsFromArray:annotatedImages];
    [self.collectionView reloadData];
    
}

#pragma mark -
#pragma mark TagViewControllerDelegate

- (void) finishEditingWithBoxes:(NSMutableArray *)boxes
{
    [self updateBoxes:[NSArray arrayWithArray:boxes]];
}


#pragma mark -
#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowTagView"]) {
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] lastObject];
        
        TagViewController *tagVC = (TagViewController *) segue.destinationViewController;
        tagVC.images = [self extractImages];
        tagVC.boxes = [self extractBoxes];
        tagVC.currentIndex = indexPath.row;
        tagVC.delegate = self;
        
    }else if([[segue identifier] isEqualToString:@"Retrain"]){
        _detectorTrainer.previousDetector = self.detector;
        _detectorTrainer.annotatedImages = _annotatedImages;
        TrainingViewController *trainingVC = segue.destinationViewController;
        trainingVC.detectorTrainer = _detectorTrainer;
        
    }else if([[segue identifier] isEqualToString:@"TakePicture"]){
        TakePictureViewController *takePictureVC = (TakePictureViewController *) segue.destinationViewController;
        takePictureVC.delegate = self;
        takePictureVC.hideNextButton = YES;
        
    }
}

#pragma mark -
#pragma mark Private Methods

- (void) updateBoxes:(NSArray *)boxes
{
    for(int i=0; i<boxes.count; i++){
        AnnotatedImage *ai = [_annotatedImages objectAtIndex:i];
        Box *box = [boxes objectAtIndex:i];
        
        [ai setBox:box];
    }
}

- (NSMutableArray *) extractBoxes
{
    NSMutableArray *boxes = [[NSMutableArray alloc] initWithCapacity:_annotatedImages.count];
    
    for(AnnotatedImage *ai in _annotatedImages)
        [boxes addObject:[ai boxForAnnotatedImage]];
    
    return  boxes;
}

- (NSMutableArray *) extractImages
{
    NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:_annotatedImages.count];
    
    for(AnnotatedImage *ai in _annotatedImages){
        UIImage *image = [UIImage imageWithData:ai.image];
        [images addObject:image];
    }
        
    return  images;
}

@end
