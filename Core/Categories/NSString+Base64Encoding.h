//
//  NSString+Base64Encoding.m
//
//  Created by Alex Reynolds on 04/29/09.
//  http://stackoverflow.com/questions/392464/how-do-i-do-base64-encoding-on-iphone-sdk
//

#import <Foundation/NSString.h>

@interface NSString (NSStringAdditions)

+ (NSString *) base64StringFromData:(NSData *)data length:(int)length;

@end
