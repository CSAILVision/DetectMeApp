//
//  DetailViewController.h
//  DetectTube
//
//  Created by Josep Marc Mingot Hidalgo on 25/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "Detector.h"
#import "ShareDetector.h"


@interface DetailViewController : UIViewController <UITableViewDataSource, UIActionSheetDelegate, ShareDectorDelegate, UIAlertViewDelegate>


@property (strong, nonatomic) Detector *detector;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *ratingControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *isPublicControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;



- (IBAction)deleteAction:(id)sender;
- (IBAction)isPublicAction:(UISegmentedControl *) isPublicControl;
- (IBAction)ratingAction:(UISegmentedControl *)ratingControl;


@end
