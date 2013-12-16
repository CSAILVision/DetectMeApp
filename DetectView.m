//
//  DetectView.m
//  ImageG
//
//  Created by Dolores Blanco Almazán on 12/06/12.
//  Updated by Josep Marc Mingot.
//  Copyright (c) 2012 CSAIL. All rights reserved.
//

#import "DetectView.h"
#import "BoundingBox.h"
#import "math.h"


static inline double min(double x, double y) { return (x <= y ? x : y); }
static inline double max(double x, double y) { return (x <= y ? y : x); }


@interface DetectView()
{
    NSArray *_boxes;
    AVCaptureVideoPreviewLayer *_prevLayer;
    NSDictionary *_colorsDictionary;
    BOOL _isFrontCamera;
}

@end



@implementation DetectView


- (void)drawRect:(CGRect)rect
{
    
    //for each group of corners generated (by nmsarray)
    int j=0;
    for(NSArray *corners in _boxes){
        
        
        if (corners.count==0) continue; //skip if no bb for this class
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        BoundingBox *p;
        CGFloat x,y,w,h; //xbox: x for the box position
    
    
        for (int i=0; i<corners.count; i++){
        
            //convert the point from the device system of reference to the prevLayer system of reference
            p = [self convertBoundingBoxForDetectView:[corners objectAtIndex:i]];
            
            //set the rectangle within the current boundaries 
            x = max(0,p.xmin);
            y = max(0,p.ymin);
            w = min(self.frame.size.width,p.xmax) - x;
            h = min(self.frame.size.height,p.ymax) - y;
            
            CGRect box = CGRectMake(x, y, w, h);
            
            CGContextSetLineWidth(context, 4);
            UIColor *color = [_colorsDictionary objectForKey:p.targetClass];
            CGContextSetStrokeColorWithColor(context, color.CGColor);
            j++;
            CGContextStrokeRect(context, box);
            
            //text drawing
            CGContextSetFillColorWithColor(context,color.CGColor);
            CGFloat textBoxHeight = 20;
            
            //handle distinct orientations
            if(_isFrontCamera){
                x = x + w;
                w = abs(w);
            }
            
            CGRect textBox = CGRectMake(x - 2, y - 20 - 2, w/2.0, textBoxHeight);
            CGContextFillRect(context, textBox);
            CGContextSetFillColorWithColor(context,[UIColor blackColor].CGColor);
            [[NSString stringWithFormat:@" %@", p.targetClass] drawInRect:textBox withFont:[UIFont systemFontOfSize:15]];
//            [[NSString stringWithFormat:@" %@", p.targetClass] drawInRect:textBox withAttributes:<#(NSDictionary *)#>];
        }
        
    }
}

#pragma mark -
#pragma mark Public Methods

- (void) initializeInTheLayer:(AVCaptureVideoPreviewLayer *)prevLayer forObjectLabels:(NSArray *)labels
{
    _prevLayer = prevLayer;
    _isFrontCamera = NO;
    
    //construct the dictionary to associate each class to a color.
    NSArray *detectorColors = [NSArray arrayWithObjects:
                               [UIColor colorWithRed:217/255.0 green:58/255.0 blue:62/255.0 alpha:.6],
                               [UIColor colorWithRed:75/255.0 green:53/255.0 blue:151/255.0 alpha:.6],
                               [UIColor colorWithRed:219/255.0 green:190/255.0 blue:59/255.0 alpha:.6],
                               [UIColor colorWithRed:54/255.0 green:177/255.0 blue:48/255.0 alpha:.6],
                               nil];
    NSMutableDictionary *colorsDictionary = [[NSMutableDictionary alloc] initWithCapacity:labels.count];
    int i=0;
    for(NSString *label in labels){
        [colorsDictionary setObject:[detectorColors objectAtIndex:i%detectorColors.count] forKey:label];
        i++;
    }
    _colorsDictionary = [NSDictionary dictionaryWithDictionary:colorsDictionary];
    
}

- (void) drawBoxes:(NSArray *)boxes
{
    _boxes = boxes;
    //usually invoked from different threads, so needs to be called from the main thread
    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
}

- (void) switchCameras
{
    _isFrontCamera = !_isFrontCamera;
}

#pragma mark -
#pragma mark Private Methods

- (BoundingBox *) convertBoundingBoxForDetectView:(BoundingBox *) cp
{
    BoundingBox *newCP = [[BoundingBox alloc] initWithBoundingBox:cp];
    
    CGPoint upperLeft = [_prevLayer pointForCaptureDevicePointOfInterest:CGPointMake(cp.ymin, 1 - cp.xmin)];
    CGPoint lowerRight = [_prevLayer pointForCaptureDevicePointOfInterest:CGPointMake(cp.ymax, 1 - cp.xmax)];
    
    newCP.xmin = upperLeft.x;
    newCP.ymin = upperLeft.y;
    newCP.xmax = lowerRight.x;
    newCP.ymax = lowerRight.y;
    
    return newCP;
}




@end
