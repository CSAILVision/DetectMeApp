//
//  TagImageView.h
//  LabelMe
//
//  Created by Josep Marc Mingot Hidalgo on 31/07/13.
//  Copyright (c) 2013 CSAIL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagView.h"
#import "Box.h"



@protocol TagImageViewDelegate <NSObject>

- (void) scrollDidEndZoomingAtScale:(float) scale;

@end


/*
 
 Class  Responsibilities:
 
 - Provide Image and TagView of zooming capabilities
 - Show image
 - Inform TagView when a zoom has been made to adapt to it
 - Give a thumbanail of the current visible area.
 - Inform the delegate when a zoom has been done 
    (used in the delegate to disable page scrolling while zoom in).
 
 
 */
@interface TagImageView : UIView <UIScrollViewDelegate>

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) TagView *tagView;
@property (strong, nonatomic) id<TagImageViewDelegate> delegate;

// Return to the initial state of zoom
- (void) resetZoomView;

- (UIImage *) takeThumbnailImage;

// Returns the visible rectabgle when zooming
// Needed to create a new box when zoom is in
- (CGRect) getVisibleRect;

// Reajust subviews after rotation
- (void) reloadForRotation;


@end
