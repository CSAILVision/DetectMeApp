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

// send when and object is: moved, resized or changed the label
- (void)objectModified;


@end

@interface TagView : UIView <UITextFieldDelegate>


// Responsible to handle when the box has been modified
@property (nonatomic, weak) id <TagViewDelegate> delegate;
@property (strong, nonatomic) Box *box;

@end