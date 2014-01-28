//
//  DetailMultipleViewController.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 23/10/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultipleDetector.h"
#import "DetailViewController.h"
#import "ExecuteDetectorViewController.h"


@interface DetailMultipleViewController : UIViewController <UITableViewDataSource, UIActionSheetDelegate>

@property (strong, nonatomic) MultipleDetector *multipleDetector;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *captureView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView3;
@property (weak, nonatomic) IBOutlet UIImageView *imageView4;

- (IBAction)deleteAction:(id)sender;

@end
