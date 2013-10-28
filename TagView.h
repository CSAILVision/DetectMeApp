//
//  TagView.h
//  LabelMe_work
//
//  Created by David Way on 4/4/12.
//  Updated by Josep Marc Mingot.
//  Copyright (c) 2012 CSAIL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Box.h"

@protocol TagViewDelegate <NSObject>

@optional
// inform when the moving is done to disable swipe scrolling
- (void) isObjectMoving:(BOOL) isMoving;

@end

@interface TagView : UIView <UITextFieldDelegate>


@property BOOL translucentBackground;

// Responsible to handle when the box has been modified
@property (nonatomic, weak) id <TagViewDelegate> delegate;
@property (strong, nonatomic) Box *box;
- (void) addBoxInView;

@end