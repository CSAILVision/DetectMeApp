//
//  UIImage+ImageAveraging.h
//  LabelMe
//
//  Created by Josep Marc Mingot Hidalgo on 07/08/13.
//  Copyright (c) 2013 CSAIL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageAveraging)

+ (UIImage *) imageAverageFromImages:(NSArray *) images;

@end
