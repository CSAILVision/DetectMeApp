//
//  NSArray+JSONHelper.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 03/10/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (JSONHelper)

- (NSString *) convertToJSON;
+ (NSArray *) arrayFromJSON:(NSString *) jsonArray;

@end
