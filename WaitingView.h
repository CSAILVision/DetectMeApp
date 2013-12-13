//
//  WaitingView.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 12/12/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 
 Class  Responsibilities:
 
 - Show a waiting view with activity indicator and progress bar
 
 
 */

@interface WaitingView : UIView



@property (strong, nonatomic) UILabel *label;

- (void) startWaitingViewWithMessage:(NSString *) message;
- (void) stopWatingViewWithMessage:(NSString *) message;


@end
