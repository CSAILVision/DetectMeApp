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


@interface DetailMultipleViewController : UIViewController <UITableViewDataSource>

@property (strong, nonatomic) MultipleDetector *multipleDetector;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


- (IBAction)deleteAction:(id)sender;

@end
