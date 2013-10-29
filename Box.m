//
//  Box.m
//  LabelMe_work
//
//  Created by David Way on 4/4/12.
//  Updated by Josep Marc Mingot.
//  Copyright (c) 2012 CSAIL. All rights reserved.
//

#import "Box.h"


#define DET 2 //Factor that represents the touchable area of the box corners

#define kExteriorBox 0
#define kUpperLeft 1
#define kUpperRight 2
#define kLowerLeft 3
#define kLowerRight 4
#define kInteriorBox 5

#define kMaxWidth 0.7
#define kMinWidth 0.3
#define kMaxHeight 0.7
#define kMinHeight 0.3

@interface Box()
{
    int _cornerResizing;
    CGPoint _firstLocation;
}


- (void) resizeUpperLeftToPoint:(CGPoint)upperLeft;
- (void) resizeLowerRightToPoint:(CGPoint)lowerRight;

@end


@implementation Box


@synthesize upperLeft = _upperLeft;
@synthesize lowerRight = _lowerRight;

- (id) initWithUpperLeft:(CGPoint)upper lowerRight:(CGPoint)lower
{
    if (self = [super init]) {
        self.upperLeft = upper;
        self.lowerRight = lower;
    }
    return self;
}

- (Box *) makeCopy
{
    return [[Box alloc] initWithUpperLeft:self.upperLeft lowerRight:self.lowerRight];
}

#pragma mark -
#pragma mark Touch Handling
- (int) touchAtPoint:(CGPoint)point
{

    int boxCorner = kExteriorBox;

    if ((CGRectContainsPoint(CGRectMake(self.upperLeft.x - DET*self.lineWidth,
                                        self.upperLeft.y - DET*self.lineWidth,
                                        2*DET*self.lineWidth,
                                        2*DET*self.lineWidth), point)))  {
        
        
        boxCorner = kUpperLeft;
        
    } else if ((CGRectContainsPoint(CGRectMake(self.lowerRight.x - DET*self.lineWidth,
                                               self.lowerRight.y - DET*self.lineWidth,
                                               2*DET*self.lineWidth,
                                               2*DET*self.lineWidth), point)))  {
        
        boxCorner = kLowerRight;
        
    } else if ((CGRectContainsPoint(CGRectMake(self.lowerRight.x - DET*self.lineWidth,
                                               self.upperLeft.y - DET*self.lineWidth,
                                               2*DET*self.lineWidth,
                                               2*DET*self.lineWidth), point)))  {
        
        boxCorner = kUpperRight;
        
    } else if ((CGRectContainsPoint(CGRectMake(self.upperLeft.x - DET*self.lineWidth,
                                               self.lowerRight.y - DET*self.lineWidth,
                                               2*DET*self.lineWidth,
                                               2*DET*self.lineWidth), point)))  {
        
        boxCorner = kLowerLeft;
        
    }else if ((CGRectContainsPoint(CGRectMake(self.upperLeft.x - self.lineWidth/2,
                                              self.upperLeft.y - self.lineWidth/2,
                                              self.lowerRight.x - self.upperLeft.x + self.lineWidth,
                                              self.lowerRight.y - self.upperLeft.y + self.lineWidth) , point))) {
        boxCorner = kInteriorBox;
    }
    
    return boxCorner;

}


#pragma mark -
#pragma mark Box resizing

- (void) resizeBeginAtPoint:(CGPoint)point
{
    int corner = [self touchAtPoint:point];
    _cornerResizing = corner;
}

- (void) resizeToPoint:(CGPoint)point
{
    switch (_cornerResizing) {
        case kUpperLeft:
            [self resizeUpperLeftToPoint:point];
            break;
            
        case kUpperRight:
            [self resizeUpperLeftToPoint:CGPointMake(self.upperLeft.x, point.y)];
            [self resizeLowerRightToPoint:CGPointMake(point.x, self.lowerRight.y)];
            break;
            
        case kLowerLeft:
            [self resizeUpperLeftToPoint:CGPointMake(point.x, self.upperLeft.y)];
            [self resizeLowerRightToPoint:CGPointMake(self.lowerRight.x, point.y)];
            break;
            
        case kLowerRight:
            [self resizeLowerRightToPoint:point];
            break;
            
        default:
            break;
    }
}


- (void) resizeLowerRightToPoint:(CGPoint)lowerRight
{
    
    self.lowerRight = [self boundedLowerRight:lowerRight];
    
    // used when the sizes are not bounded, so you can "reverse" the box
    int rotation = 0;
    if (_upperLeft.x > _lowerRight.x) {
        float copy;
        copy = _upperLeft.x;
        _upperLeft.x = _lowerRight.x;
        _lowerRight.x = copy;
        rotation++;
    }
    if (_upperLeft.y > _lowerRight.y) {
        float copy;
        copy = _upperLeft.y;
        _upperLeft.y = _lowerRight.y;
        _lowerRight.y = copy;
        rotation+=2;
    }
    
    _cornerResizing -= rotation;
}

- (void) resizeUpperLeftToPoint:(CGPoint)upperLeft
{
    
    self.upperLeft = [self boundedUpperLeft:upperLeft];
    
    // used when the sizes are not bounded, so you can "reverse" the box
    int rotation = 0;
    if (_upperLeft.x > _lowerRight.x) {
        float copy;
        copy = _upperLeft.x;
        _upperLeft.x = _lowerRight.x;
        _lowerRight.x = copy;
        rotation++;
    }
    
    if (_upperLeft.y > _lowerRight.y) {
        float copy;
        copy = _upperLeft.y;
        _upperLeft.y = _lowerRight.y;
        _lowerRight.y = copy;
        rotation+=2;
    }
    _cornerResizing +=rotation;
}

- (CGPoint) boundedLowerRight:(CGPoint)lowerRight
{
    
    float width = lowerRight.x - self.upperLeft.x;
    float height = lowerRight.y - self.upperLeft.y;
    
    if(width>kMaxWidth) lowerRight.x = self.upperLeft.x + kMaxWidth;
    if(width<kMinWidth) lowerRight.x = self.upperLeft.x + kMinWidth;
    if(height>kMaxHeight) lowerRight.y = self.upperLeft.y + kMaxHeight;
    if(height<kMinHeight) lowerRight.y = self.upperLeft.y + kMinWidth;
    
    return lowerRight;
}

- (CGPoint) boundedUpperLeft:(CGPoint)upperLeft
{
    float width = self.lowerRight.x - upperLeft.x;
    float height = self.lowerRight.y - upperLeft.y;
    
    if(width>kMaxWidth) upperLeft.x = self.lowerRight.x - kMaxWidth;
    if(width<kMinWidth) upperLeft.x = self.lowerRight.x - kMinWidth;
    if(height>kMaxHeight) upperLeft.y = self.lowerRight.y - kMaxHeight;
    if(height<kMinHeight) upperLeft.y = self.lowerRight.y - kMinWidth;
    
    return upperLeft;
}


#pragma mark - 
#pragma mark Box moving

- (void) moveBeginAtPoint:(CGPoint)point
{
    _firstLocation = point;
}

- (void) moveToPoint:(CGPoint)end
{
    if (self.upperLeft.y + end.y - _firstLocation.y < 0 + self.lineWidth/2) {
        end.y = 0 + self.lineWidth/2 - self.upperLeft.y + _firstLocation.y;
        
    }
    if (self.lowerRight.y + end.y - _firstLocation.y > 1 - self.lineWidth/2) {
        end.y = 1 - self.lineWidth/2 - self.lowerRight.y + _firstLocation.y;
        
        
    }
    if (self.upperLeft.x + end.x - _firstLocation.x < 0 + self.lineWidth/2) {
        end.x = 0 + self.lineWidth/2 - self.upperLeft.x + _firstLocation.x;
        
    }
    if (self.lowerRight.x + end.x - _firstLocation.x > 1 - self.lineWidth/2) {
        end.x = 1 - self.lineWidth/2 - self.lowerRight.x + _firstLocation.x;
        
    }
    
    
    self.upperLeft = CGPointMake((self.upperLeft.x + end.x - _firstLocation.x), (self.upperLeft.y + end.y - _firstLocation.y));
    self.lowerRight = CGPointMake((self.lowerRight.x + end.x - _firstLocation.x), (self.lowerRight.y + end.y - _firstLocation.y));
    
    _firstLocation = end;
}

#pragma mark -
#pragma mark Private Methods


- (CGRect) getRectangleForBox
{
    CGRect rectangle = CGRectMake(self.upperLeft.x, self.upperLeft.y, self.lowerRight.x - self.upperLeft.x, self.lowerRight.y - self.upperLeft.y);
    return rectangle;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"upperLeft = (%.3f,%.3f), lowerRight = (%.3f,%.3f)",self.upperLeft.x, self.upperLeft.y, self.lowerRight.x,self.lowerRight.y];
}


@end
