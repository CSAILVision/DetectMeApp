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
#define kLineWidth 6

#define kExteriorBox 0
#define kUpperLeft 1
#define kUpperRight 2
#define kLowerLeft 3
#define kLowerRight 4
#define kInteriorBox 5


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

- (id) initWithUpperLeft:(CGPoint)upper lowerRight:(CGPoint)lower forImageSize:(CGSize)imageSize
{
    if (self = [super init]) {
        self.imageSize = imageSize;
        self.upperLeft = upper;
        self.lowerRight = lower;
    }
    return self;
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
    self.lowerRight = lowerRight;
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
    self.upperLeft = upperLeft;
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
    if (self.lowerRight.y + end.y - _firstLocation.y > self.imageSize.height - self.lineWidth/2) {
        end.y = self.imageSize.height - self.lineWidth/2 - self.lowerRight.y + _firstLocation.y;
        
        
    }
    if (self.upperLeft.x + end.x - _firstLocation.x < 0 + self.lineWidth/2) {
        end.x = 0 + self.lineWidth/2 - self.upperLeft.x + _firstLocation.x;
        
    }
    if (self.lowerRight.x + end.x - _firstLocation.x > self.imageSize.width - self.lineWidth/2) {
        end.x = self.imageSize.width - self.lineWidth/2 - self.lowerRight.x + _firstLocation.x;
        
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

- (void) setBoxDimensionsForFrameSize:(CGSize) size
{    
    self.upperLeft = CGPointMake(self.upperLeft.x*size.width*1.0/self.imageSize.width, self.upperLeft.y*size.height*1.0/self.imageSize.height);
    self.lowerRight = CGPointMake(self.lowerRight.x*size.width*1.0/self.imageSize.width, self.lowerRight.y*size.height*1.0/self.imageSize.height);
    self.imageSize = size;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"upperLeft = (%.1f,%.1f), lowerRight = (%.1f,%.1f). Upper, lower, left and right bounds = (%.1f,%.1f,%.1f,%.1f)",self.upperLeft.x, self.upperLeft.y, self.lowerRight.x,self.lowerRight.y, 0.0, self.imageSize.height, 0.0, self.imageSize.width];
}


@end
