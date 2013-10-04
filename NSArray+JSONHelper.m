//
//  NSArray+JSONHelper.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 03/10/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "NSArray+JSONHelper.h"
#import <objc/runtime.h>

@implementation NSArray (JSONHelper)


- (NSString *) convertToJSON
{
    NSString *jsonArray = @"[";
    for (NSString *element in self) {
        if(element != [self lastObject])
            jsonArray = [NSString stringWithFormat:@"%@%@,",jsonArray,element];
        else jsonArray = [NSString stringWithFormat:@"%@%@]",jsonArray,element];
    }
    
    
    NSLog(@"json string: %@", jsonArray);
    
    return jsonArray;
}

+ (NSArray *) arrayFromJSON:(NSString *) jsonArray
{
    jsonArray = [jsonArray stringByReplacingOccurrencesOfString:@"[" withString:@""];
    jsonArray = [jsonArray stringByReplacingOccurrencesOfString:@"]" withString:@""];
    jsonArray = [jsonArray stringByReplacingOccurrencesOfString:@"]" withString:@"\""];
    
    NSArray *array = [jsonArray componentsSeparatedByString:@","];
    
    NSLog(@"json array: %@", array);
    
    
    return [NSArray arrayWithArray:array];
}

@end
