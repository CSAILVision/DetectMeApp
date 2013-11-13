//
//  Reachability+DetectMe.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 13/11/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "Reachability.h"

/*
 
 Class  Responsibilities:
 
 - Decide if network capabilities are available 
 
 */

@interface Reachability (DetectMe)

+ (BOOL) isNetworkReachable;


@end
