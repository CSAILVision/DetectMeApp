//
//  TrainingImagesCollectionViewController.h
//  DetectTube
//
//  Created by Josep Marc Mingot Hidalgo on 25/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Detector.h"
#import "TakePictureViewController.h"

@interface TrainingImagesCollectionViewController : UICollectionViewController <TakePictureViewControllerDelegate>

@property (strong, nonatomic) Detector *detector;

- (IBAction)deleteAction:(UIButton *)sender;

@end
