//
//  UIImage+Rotation.h
//  LabelMe
//
//  Created by Josep Marc Mingot Hidalgo on 22/05/13.
//  Copyright (c) 2013 CSAIL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Rotation)

//make correspond intrinsic orientation (byte level) with metadata orientation
- (UIImage *)fixOrientation;

//rotate byte data to desired orientation
- (UIImage *)rotate:(UIImageOrientation) orientation;

@end
