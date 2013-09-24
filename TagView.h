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


@interface TagView : UIView <UITextFieldDelegate>

@property (strong, nonatomic) Box *box;

@end
