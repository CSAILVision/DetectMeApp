//
//  TagImageView.m
//  LabelMe
//
//  Created by Josep Marc Mingot Hidalgo on 31/07/13.
//  Copyright (c) 2013 CSAIL. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TagImageView.h"
#import "UIImage+Resize.h"


// masks for flexible ajusting each views
#define kUIViewAutoresizingFlexibleHeighWidth   \
    UIViewAutoresizingFlexibleWidth           | \
    UIViewAutoresizingFlexibleHeight

@interface TagImageView()

@property (nonatomic, strong) UIScrollView *zoomScrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *containerView; //container view for |ImageView| and |TagView|


// Needed when we want the TagView to adapt to the image size inside UIScrollView
- (CGRect) getImageFrameFromImageView: (UIImageView *)iv;

@end


@implementation TagImageView

#pragma mark -
#pragma mark Initialization

- (void) initialize
{
    self.zoomScrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    [self.zoomScrollView setBackgroundColor:[UIColor blackColor]];
    [self.zoomScrollView setCanCancelContentTouches:NO];
    self.zoomScrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    self.zoomScrollView.clipsToBounds = YES;
    self.zoomScrollView.minimumZoomScale = 1.0;
    self.zoomScrollView.maximumZoomScale = 10.0;
    self.zoomScrollView.delegate = self;
    [self.zoomScrollView setContentSize:self.zoomScrollView.frame.size];
    
    self.containerView = [[UIView alloc] initWithFrame:self.frame];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.frame];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.tagView = [[TagView alloc] initWithFrame:self.frame];
    
    [self addSubview:self.zoomScrollView];
    [self.containerView addSubview:self.imageView];
    [self.containerView addSubview:self.tagView];
    [self.zoomScrollView addSubview:self.containerView];
    
    //register for notifications if box is selected
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isBoxSelected:) name:@"isBoxSelected" object:nil];
    
    // to adapt when rotating
    self.autoresizingMask = kUIViewAutoresizingFlexibleHeighWidth;
    self.zoomScrollView.autoresizingMask = kUIViewAutoresizingFlexibleHeighWidth;
    self.containerView.autoresizingMask = kUIViewAutoresizingFlexibleHeighWidth;
    self.imageView.autoresizingMask = kUIViewAutoresizingFlexibleHeighWidth;
    self.tagView.autoresizingMask = kUIViewAutoresizingFlexibleHeighWidth;

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

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark -
#pragma mark Getters and Setters


-(void) setImage:(UIImage *)image
{
    if(image!=_image){
        _image = image;
        [self.imageView setImage:image];
        
        //ajust the frame to be the same as the displayed image, not the whole view
        self.tagView.frame = [self getImageFrameFromImageView:self.imageView];
        
        [self setNeedsDisplay];
    }
}

#pragma mark -
#pragma mark Public methods

- (void) resetZoomView
{
    [self.zoomScrollView setZoomScale:1.0 animated:NO];
}


- (UIImage *) takeThumbnailImage
{
    UIGraphicsBeginImageContext(self.tagView.frame.size);
    [self.containerView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef imageRef = CGImageCreateWithImageInRect(viewImage.CGImage, self.tagView.frame);

    
    int thumbnailSize = 300;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) thumbnailSize = 128;
    UIImage *thumbnailImage  = [[UIImage imageWithCGImage:imageRef scale:1.0 orientation:viewImage.imageOrientation] thumbnailImage:thumbnailSize transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationLow];
    
    CGImageRelease(imageRef);

    
    return thumbnailImage;
}

- (CGRect) getVisibleRect
{
    if(self.zoomScrollView.zoomScale==1){
        
        //correct the origin to 0 because this will be used inside tagview
        CGRect visibleRectOnTagView = self.tagView.frame;
        visibleRectOnTagView.origin.x = 0.0;
        visibleRectOnTagView.origin.y = 0.0;
        return visibleRectOnTagView;
    
    }else return [self.zoomScrollView convertRect:self.zoomScrollView.bounds toView:self.tagView];
}

- (void) reloadForRotation
{
    
    [self.imageView setImage:self.image];
    self.tagView.frame = [self getImageFrameFromImageView:self.imageView];
    
    //reset boxes to force them to reajust to the new frame
//    NSArray *boxesAux = self.tagView.boxes;
//    self.tagView.boxes = nil;
//    self.tagView.boxes = boxesAux;
}


#pragma mark -
#pragma mark UIScrollViewDelegate


- (UIView*)viewForZoomingInScrollView:(UIScrollView *)aScrollView
{
    return self.containerView;
}

- (void) scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
//    [self.tagView setUpViewForZoomScale:scale];
    [self.delegate scrollDidEndZoomingAtScale:scale];
}


#pragma mark -
#pragma mark NSNotificationCenter Messages

-(void)isBoxSelected:(NSNotification *) notification
{
    //disable scrolling when a box is selected
    NSNumber *isSelected = [notification object];
    self.zoomScrollView.scrollEnabled = !isSelected.boolValue;
}


#pragma mark -
#pragma mark Private Methods

- (CGRect) getImageFrameFromImageView: (UIImageView *)iv
{
    CGSize imageSize = iv.image.size;
    CGFloat imageScale = fminf(CGRectGetWidth(iv.bounds)/imageSize.width, CGRectGetHeight(iv.bounds)/imageSize.height);
    CGSize scaledImageSize = CGSizeMake(imageSize.width*imageScale, imageSize.height*imageScale);
    CGRect imageFrame = CGRectMake(floorf(0.5f*(CGRectGetWidth(iv.bounds)-scaledImageSize.width)), floorf(0.5f*(CGRectGetHeight(iv.bounds)-scaledImageSize.height)), scaledImageSize.width, scaledImageSize.height);
    
    return imageFrame;
}

@end
