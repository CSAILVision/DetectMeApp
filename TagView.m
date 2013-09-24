//
//  TagView.m
//  LabelMe_work
//
//  Created by David Way on 4/4/12.
//  Updated by Josep Marc Mingot.
//  Copyright (c) 2012 CSAIL. All rights reserved.
//


#import "TagView.h"


#define kLineWidth 6
#define kExteriorBox 0
#define kUpperLeft 1
#define kUpperRight 2
#define kLowerLeft 3
#define kLowerRight 4
#define kInteriorBox 5

#define kUIViewAutoresizingFlexibleHeighWidth   \
UIViewAutoresizingFlexibleWidth           | \
UIViewAutoresizingFlexibleHeight



@interface TagView()
{
    BOOL _touchIsMoving;
    BOOL _touchIsResizing;
}
@end


@implementation TagView


#pragma mark -
#pragma mark Initialization


- (void) initialize
{
    [self setBackgroundColor:[UIColor clearColor]];
    
    _touchIsMoving = NO;
    _touchIsResizing = NO;
    
    [self addBoxInVisibleRect:self.frame];

}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) [self initialize];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) [self initialize];
    return self;
}



#pragma mark -
#pragma mark Public Methods


- (void) addBoxInVisibleRect:(CGRect)visibleRect
{
    CGPoint newUpperLeft = CGPointMake(visibleRect.origin.x + 0.3*visibleRect.size.width, visibleRect.origin.y + 0.3*visibleRect.size.height);
    CGPoint newLowerRight = CGPointMake(visibleRect.origin.x + 0.7*visibleRect.size.width, visibleRect.origin.y + 0.7*visibleRect.size.height);
    
    Box *newBox = [[Box alloc] initWithUpperLeft:newUpperLeft lowerRight:newLowerRight forImageSize:self.frame.size];
    self.box = newBox;

}




#pragma mark -
#pragma mark Draw Rect

- (void) drawRect:(CGRect)rect
{
    self.box.lineWidth = kLineWidth;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPoint upperRight = CGPointMake([self.box lowerRight].x, [self.box upperLeft].y);
    CGPoint lowerLeft = CGPointMake([self.box upperLeft].x, [self.box lowerRight].y);
    
    // DRAW RECT
    CGContextSetLineWidth(context, kLineWidth);
    CGRect boxRect = CGRectMake([self.box upperLeft].x, [self.box upperLeft].y, [self.box lowerRight].x-[self.box upperLeft].x, [self.box lowerRight].y-[self.box upperLeft].y);
    const CGFloat *components = CGColorGetComponents([[UIColor redColor] CGColor]);
    CGContextSetRGBStrokeColor(context, components[0] ,components[1],components[2], 1);
    CGContextStrokeRect(context, boxRect);
    
    // DRAW CORNERS
    CGContextStrokeEllipseInRect(context, CGRectMake([self.box upperLeft].x-kLineWidth, [self.box upperLeft].y-kLineWidth, 2*kLineWidth, 2*kLineWidth));
    CGContextStrokeEllipseInRect(context, CGRectMake([self.box lowerRight].x-kLineWidth, [self.box lowerRight].y-kLineWidth, 2*kLineWidth, 2*kLineWidth));
    CGContextStrokeEllipseInRect(context, CGRectMake(upperRight.x-kLineWidth, upperRight.y-kLineWidth, 2*kLineWidth, 2*kLineWidth));
    CGContextStrokeEllipseInRect(context, CGRectMake(lowerLeft.x-kLineWidth, lowerLeft.y-kLineWidth, 2*kLineWidth, 2*kLineWidth));
    CGContextSetRGBStrokeColor(context, 255, 255, 255, 1);
    CGContextSetLineWidth(context, 1);
    CGContextStrokeEllipseInRect(context, CGRectMake([self.box upperLeft].x-1.5*kLineWidth, [self.box upperLeft].y-1.5*kLineWidth, 3*kLineWidth, 3*kLineWidth));
    CGContextStrokeEllipseInRect(context, CGRectMake([self.box lowerRight].x-1.5*kLineWidth, [self.box lowerRight].y-1.5*kLineWidth, 3*kLineWidth, 3*kLineWidth));
    CGContextStrokeEllipseInRect(context, CGRectMake(upperRight.x-1.5*kLineWidth, upperRight.y-1.5*kLineWidth, 3*kLineWidth, 3*kLineWidth));
    CGContextStrokeEllipseInRect(context, CGRectMake(lowerLeft.x-1.5*kLineWidth, lowerLeft.y-1.5*kLineWidth, 3*kLineWidth, 3*kLineWidth));
    
}

#pragma mark -
#pragma mark Touch Event Delegate

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:touch.view];
    
    int corner = [self.box touchAtPoint:location];
    
    if(corner == kInteriorBox){
        _touchIsMoving = YES;
        [self.box moveBeginAtPoint:location];
        
    }else if(corner == kExteriorBox){
        [self endEditing:YES];
        
    }else{
        _touchIsResizing = YES;
        [self.box resizeBeginAtPoint:location];
    }
        
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:touch.view];

    Box *currentBox = self.box;
    if (_touchIsMoving) [currentBox moveToPoint:location];
    else if (_touchIsResizing) [currentBox resizeToPoint:location];
    
    [self setNeedsDisplay];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _touchIsMoving = NO;
    _touchIsResizing = NO;

    [self setNeedsDisplay];
}




@end
