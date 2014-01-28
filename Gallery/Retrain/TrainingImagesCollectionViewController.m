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
#import "DetectorFetcher.h"
#import "ConstantsServer.h"
#import "UIViewController+ShowAlert.h"
#import "WaitingView.h"


@interface TrainingImagesCollectionViewController ()
{
    DetectorTrainer *_detectorTrainer;
    NSMutableArray *_annotatedImages;
    WaitingView *_waitingView;
    
    UIManagedDocument *_detectorDatabase;
    NSUndoManager *_undoManager;
    BOOL _undo; //undoes all the changes when going back. Just stores if trained.
    BOOL _modified; //true if the training set has changed (add, remove, modify images)
}

@end

@implementation TrainingImagesCollectionViewController

#pragma mark -
#pragma mark initialization


- (void) initializeWaitingView
{
    _waitingView = [[WaitingView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_waitingView];
}

- (void) initializeUndoManager
{
    //create a undo manager for the current MOC (nil by default)
    [_detectorDatabase.managedObjectContext setUndoManager:[[NSUndoManager alloc] init]];
    
    //get the undomanager
    _undoManager = [_detectorDatabase.managedObjectContext undoManager];
    [_undoManager beginUndoGrouping];
}

- (void) initializeSupportVectors
{
    if(!self.detector.supportVectors){
        [_waitingView startWaitingViewWithMessage:@"Downloading support vectors..."];
        [self getSupportVectors];
    }
}


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
    
    [self initializeWaitingView];
    [self initializeUndoManager];
    [self initializeSupportVectors];
    [self setPageTitle];
    
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *bbtnBack = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                 style:UIBarButtonItemStyleBordered
                                                                target:self
                                                                action:@selector(goBack:)];
    
    self.navigationItem.leftBarButtonItem = bbtnBack;

}


- (void)goBack:(UIBarButtonItem *)sender
{
    if(_modified){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                    message:@"With this action you will loose your changes. Do you want to proceed?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
        [alert show];
    }else [self.navigationController popViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex) {
        case 0: //"No" pressed
            //do something?
            break;
        case 1: //"Yes" pressed
            //here you pop the viewController
            [self.navigationController popViewControllerAnimated:YES];
            break;
    }
}

- (void) getSupportVectors
{
    // download support vectors if not own detector to retrain.
    // if the download fails, shows connection error and returns to the previous page
    dispatch_queue_t downloadSVQueue = dispatch_queue_create("Support Vectors Fetcher", NULL);
    dispatch_async(downloadSVQueue, ^{
        NSData *jsonData = [DetectorFetcher fetchSupportVectorsSyncForDetector:self.detector];
        if(jsonData){
            NSError *error;
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
            NSString *jsonString = [jsonDictionary objectForKey:SERVER_DETECTOR_SUPPORT_VECTORS];
            self.detector.supportVectors = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            
            dispatch_async(dispatch_get_main_queue(), ^{[_waitingView stopWatingViewWithMessage:@"Support Vectors downloaded!"];});
        }else{
            //handle communication error
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlertWithTitle:@"Connection Error" andDescription:@"SV not downloaded"];
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
    });

}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // set undo flag
    _undo = YES;
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // undo if going back
    if(_undo){
        [_undoManager endUndoGrouping];
        [_undoManager undo];
    }

}

- (void) dealloc
{
    // close undo grouping if open
    if([_undoManager groupingLevel]>0)
        [_undoManager endUndoGrouping];
}


#pragma mark -
#pragma mark UICollectionView data source and delegate


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
    cell.deleteButton.tag = indexPath.row;
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionFooter) {
        reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
        reusableview.hidden = _annotatedImages.count>0 ? YES:NO;
        
    }else if(kind == UICollectionElementKindSectionHeader){
        reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
    }
    
    return reusableview;
}

// Layout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize cellSize = CGSizeMake(100, 200);
    if([@"iPad" isEqualToString:[[UIDevice currentDevice] model]]) cellSize = CGSizeMake(180, 300);
    return cellSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    
    CGSize headerSize = _annotatedImages.count>0 && _modified ? CGSizeMake(collectionView.frame.size.width, 85):CGSizeMake(0, 0);
    return headerSize;
}

#pragma mark -
#pragma mark IBActions

- (IBAction)deleteAction:(UIButton *)sender
{
    AnnotatedImage *deleted = [_annotatedImages objectAtIndex:sender.tag];
    [_annotatedImages removeObjectAtIndex:sender.tag];
    [_detectorDatabase.managedObjectContext deleteObject:deleted];

    [self reloadData];
}


- (IBAction)resetImagesAction:(id)sender
{
    UIManagedDocument *document = [ManagedDocumentHelper sharedDatabaseUsingBlock:^(UIManagedDocument *document) {}];
    
    // delete current images
    for(AnnotatedImage *ai in self.detector.annotatedImages)
        [document.managedObjectContext deleteObject:ai];
    
    // get all the current images from the server
    dispatch_queue_t fetchQ = dispatch_queue_create("AnnotatedImage Fetcher", NULL);
    dispatch_async(fetchQ, ^{
        NSArray *annotatedImages = [DetectorFetcher fetchAnnotatedImagesSyncForDetector:self.detector];
        [document.managedObjectContext performBlock:^{
            NSLog(@"received  %d images", annotatedImages.count);
            for(NSDictionary *annotatedIageInfo in annotatedImages){
                [AnnotatedImage annotatedImageWithDictionaryInfo:annotatedIageInfo
                                          inManagedObjectContext:document.managedObjectContext
                                                     forDetector:self.detector];
            }
            
        }];
    });
}

#pragma mark -
#pragma mark TakePictureViewControllerDelegate


- (void) takenAnnotatedImages:(NSArray *) annotatedImages
{
    [_annotatedImages addObjectsFromArray:annotatedImages];
    
    [self reloadData];
}

#pragma mark -
#pragma mark TagViewControllerDelegate

- (void) finishEditingWithBoxes:(NSMutableArray *)boxes
{
    [self updateBoxes:[NSArray arrayWithArray:boxes]];
    
    [self reloadData];
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
        
        [_detectorDatabase.managedObjectContext setUndoManager:nil];
        
    }else if([[segue identifier] isEqualToString:@"TakePicture"]){
        TakePictureViewController *takePictureVC = (TakePictureViewController *) segue.destinationViewController;
        takePictureVC.delegate = self;
        takePictureVC.isRetraining = YES;
        
    }
    
    //set undo
    _undo = NO;
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


- (void) reloadData
{
    [self setPageTitle];
    _modified = YES;
    [self.collectionView reloadData];
}

- (void) setPageTitle
{
    self.title = [NSString stringWithFormat:@"%d images", _annotatedImages.count];
}


@end
