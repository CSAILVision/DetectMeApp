//
//  TrainingImagesCollectionViewController.m
//  DetectTube
//
//  Created by Josep Marc Mingot Hidalgo on 25/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "TrainingImagesCollectionViewController.h"
#import "TrainingImageCell.h"
#import "TagViewController.h"

@interface TrainingImagesCollectionViewController ()

@end

@implementation TrainingImagesCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// REUSE IDENTIFIER FOR CELL: trainingCell

#pragma mark -
#pragma mark Data Source


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TrainingImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"trainingCell" forIndexPath:indexPath];
    cell.imageView.image = [self.images objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark -
#pragma mark IBActions
- (IBAction)deleteAction:(UIButton *)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero fromView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:buttonPosition];
    [self.images removeObjectAtIndex:indexPath.row];
    [self.boxes removeObjectAtIndex:indexPath.row];
    [self.collectionView reloadData];
}

#pragma mark -
#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowTagView"]) {
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] lastObject];
        
        TagViewController *tagVC = (TagViewController *) segue.destinationViewController;
        tagVC.images = self.images;
        tagVC.boxes = self.boxes;
        tagVC.currentIndex = indexPath.row;
    }
}


@end
