//
//  MultipleDetectorsChooseViewController.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 23/10/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "MultipleDetectorsChooseViewController.h"
#import "TrainingImageCell.h"
#import "Detector.h"
#import "ManagedDocumentHelper.h"
#import "UIViewController+ShowAlert.h"
#import "MultipleDetector+Create.h"
#import "DetectorTypeSelectionViewController.h"


@interface MultipleDetectorsChooseViewController ()
{
    NSArray *_detectors;
    NSMutableArray *_selectedDetectors;
    UIManagedDocument *_detectorDatabase;
    
}

@end

@implementation MultipleDetectorsChooseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _detectorDatabase = [ManagedDocumentHelper sharedDatabaseUsingBlock:^(UIManagedDocument *document){}];
    self.collectionView.allowsMultipleSelection = YES;
    
    // Fecth all
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Detector"];
    NSError *error;
    _detectors = [_detectorDatabase.managedObjectContext executeFetchRequest:request error:&error];
    _selectedDetectors = [[NSMutableArray alloc] initWithCapacity:_detectors.count];
    [self.collectionView reloadData];
}


#pragma mark -
#pragma mark IBActions

- (IBAction)createAction:(id)sender
{
    if(_selectedDetectors.count<2) [self showAlertWithTitle:@"Error" andDescription:@"You need at least 2 detectors."];
    else{
        [MultipleDetector multipleDetectorWithName:@"mulitple"
                                      forDetectors:_selectedDetectors
                            inManagedObjectContext:_detectorDatabase.managedObjectContext];
        

        // Pop controllers to the gallery
        NSArray *array = [self.navigationController viewControllers];
        [self.navigationController popToViewController:[array objectAtIndex:1] animated:YES];
    }
}


#pragma mark -
#pragma mark Collection View Data Source and Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _detectors.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TrainingImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"detectorCell" forIndexPath:indexPath];
    Detector *detector = [_detectors objectAtIndex:indexPath.row];
    UIImage *image = [UIImage imageWithData:detector.image];
    cell.imageView.image = image;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TrainingImageCell *imageCell = (TrainingImageCell *)[collectionView cellForItemAtIndexPath:indexPath];
    Detector *detector = [_detectors objectAtIndex:indexPath.row];
    
    
    if([_selectedDetectors containsObject:detector]){
        [self deselectCell:imageCell];
        [_selectedDetectors removeObject:detector];
    }else{
        [self selectCell:imageCell];
        [_selectedDetectors addObject:detector];
    }
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize retval = CGSizeMake(100, 100);
    return retval;
}

#pragma mark -
#pragma mark Private Methods

- (void) selectCell:(TrainingImageCell *)cell
{
    [cell.imageView.layer setBorderColor: [[UIColor redColor] CGColor]];
    [cell.imageView.layer setBorderWidth: 3.0];
}

- (void) deselectCell:(TrainingImageCell *)cell
{
    [cell.imageView.layer setBorderWidth: 0.0];
}


@end
