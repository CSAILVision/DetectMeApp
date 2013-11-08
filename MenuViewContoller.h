//
//  MenuViewContoller.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 07/11/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MenuViewContoller : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

@property (weak, nonatomic) IBOutlet UILabel *numSingle;
@property (weak, nonatomic) IBOutlet UILabel *numMultiple;
@property (weak, nonatomic) IBOutlet UILabel *numServer;



@end
