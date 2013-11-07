//
//  DetectorTypeSelectionViewController.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 06/11/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "DetectorTypeSelectionViewController.h"

@interface DetectorTypeSelectionViewController ()

@end

@implementation DetectorTypeSelectionViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    if(self.jump){
        self.jump = NO;
        [self.tabBarController setSelectedIndex:0];
    }

}


@end
