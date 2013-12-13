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
#import "TagViewController.h"

@interface TrainingImagesCollectionViewController : UICollectionViewController <TakePictureViewControllerDelegate, TagViewControllerDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) Detector *detector;

- (IBAction)deleteAction:(UIButton *)sender;

// Get the detector images from the server
- (IBAction)resetImagesAction:(id)sender;

@end
