//
//  AYUIButton.m
//
//  Created by Andy Yanok on 5/5/11.
//  Updated by Josep Marc Mingot.
//  Copyright 2011 CSAIL. All rights reserved.
//

#import "AYUIButton.h"


@interface AYUIButton()
{
    NSMutableDictionary *_backgroundStates;
}

@end


@implementation AYUIButton

#pragma mark -
#pragma mark Public methods

- (void) setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state
{
    if (_backgroundStates == nil)
        _backgroundStates = [[NSMutableDictionary alloc] init];
    
    [_backgroundStates setObject:backgroundColor forKey:[NSNumber numberWithInt:state]];
    
    if (self.backgroundColor == nil)
        [self setBackgroundColor:backgroundColor];
}

- (UIColor *) backgroundColorForState:(UIControlState)state
{
    return [_backgroundStates objectForKey:[NSNumber numberWithInt:state]];
}

- (void) transformButtonForCamera
{
    self.layer.cornerRadius = 18;
    self.layer.borderColor = [[UIColor blackColor] CGColor];
    self.layer.borderWidth = 1;
    CGRect frame = self.frame;
    self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height*0.8);
    [self setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.4]];
    [self setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.8] forState:UIControlStateHighlighted];
    [self setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.4] forState:UIControlStateNormal];
    [self setTitleColor:[self titleColorForState:UIControlStateNormal] forState:UIControlStateHighlighted];
}

- (void) setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    UIColor *selectedColor = [_backgroundStates objectForKey:[NSNumber numberWithInt:UIControlStateSelected]];
    UIColor *normalColor = [_backgroundStates objectForKey:[NSNumber numberWithInt:UIControlStateNormal]];
    if (selectedColor != nil && selected) self.backgroundColor = selectedColor;
    else self.backgroundColor = normalColor;
}

#pragma mark -
#pragma mark Touches

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
    
    
    UIColor *selectedColor = [_backgroundStates objectForKey:[NSNumber numberWithInt:UIControlStateHighlighted]];
    if (selectedColor) {
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionFade];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [self.layer addAnimation:animation forKey:@"EaseOut"];
        self.backgroundColor = selectedColor;
    }
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event];

    UIColor *normalColor = [_backgroundStates objectForKey:[NSNumber numberWithInt:UIControlStateNormal]];
    if (normalColor) {
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionFade];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [self.layer addAnimation:animation forKey:@"EaseOut"];
        self.backgroundColor = normalColor;
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    UIColor *normalColor = [_backgroundStates objectForKey:[NSNumber numberWithInt:UIControlStateNormal]];
    if (normalColor) {
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionFade];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [self.layer addAnimation:animation forKey:@"EaseOut"];
        self.backgroundColor = normalColor;
    }
    
    self.selected = !self.selected;
}


@end
