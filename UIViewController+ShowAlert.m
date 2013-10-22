//
//  UIViewController+ShowAlert.m
//  LabelMe
//
//  Created by Josep Marc Mingot Hidalgo on 06/08/13.
//  Copyright (c) 2013 CSAIL. All rights reserved.
//

#import "UIViewController+ShowAlert.h"

@implementation UIViewController (ShowAlert)

- (void) showAlertWithTitle:(NSString *)title andDescription:(NSString *)description
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:description
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}


@end
