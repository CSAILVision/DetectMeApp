//
//  GalleryViewController.h
//  DetecTube
//
//  Created by Josep Marc Mingot Hidalgo on 16/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataCollectionViewController.h"
#import "DetailViewController.h"
#import "DetailMultipleViewController.h"


#define FILTER_SINGLE @"MySingleDetectors"
#define FILTER_MULTIPLE @"MyMultipleDetectors"
#define FILTER_SERVER @"ServerDetectors"

//Selecting single detectors to create a multiple one
#define FILTER_SELECTION @"Selection"


@interface GalleryViewController : CoreDataCollectionViewController<UICollectionViewDelegateFlowLayout, UISearchBarDelegate, DetailViewControllerDelegate>

@property (strong, nonatomic) NSString *filter;
@property (strong, nonatomic) UIManagedDocument *detectorDatabase;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UILabel *noImagesHelperLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;



- (IBAction)refreshAction:(id)sender;
- (IBAction)addAction:(id)sender;
- (IBAction)doneSelectingAction:(id)sender;
- (IBAction)cancelSelectingAction:(id)sender;




@end
