//
//  TrainingImagesCollectionViewController.h
//  DetectTube
//
//  Created by Josep Marc Mingot Hidalgo on 25/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrainingImagesCollectionViewController : UICollectionViewController 

@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) NSMutableArray *boxes;
- (IBAction)deleteAction:(UIButton *)sender;

@end
