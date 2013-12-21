//
//  WaitingView.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 12/12/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "WaitingView.h"


@interface WaitingView()
{
    UIActivityIndicatorView *_activityIndicator;
}


@end



@implementation WaitingView

#pragma mark -
#pragma mark Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //view properties
        self.hidden = YES;
        self.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.8];
        
        //activity indicator
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.center = self.center;
        [self addSubview:_activityIndicator];
        
        //text label
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
        self.label.center = CGPointMake(self.center.x, self.center.y + 70);
        self.label.numberOfLines = 0;
        self.label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.label];
        
    }
    return self;
}




#pragma mark -
#pragma mark Public methods



- (void) startWaitingViewWithMessage:(NSString *) message
{
    self.hidden = NO;
    self.label.text = message;
    [_activityIndicator startAnimating];
}

- (void) stopWatingViewWithMessage:(NSString *) message
{
    
    self.label.text = message;
    [_activityIndicator stopAnimating];
    [self performSelector:@selector(hide) withObject:nil afterDelay:2];
}

- (void) hide
{
    self.hidden = YES;
}

@end
