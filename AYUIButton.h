//
//  AYUIButton.h
//
//  Created by Andy Yanok on 5/5/11.
//  Updated by Josep Marc Mingot.
//  Copyright 2011 CSAIL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

/*
    This subclass was created to be able to set the background color for UIControlState
*/

@interface AYUIButton : UIButton 

- (void) setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;
- (UIColor*) backgroundColorForState:(UIControlState)state;

//preferences for camera buttons (transparency, round coreners and title highlight)
- (void) transformButtonForCamera;


- (void) setSelected:(BOOL)selected;

@end
