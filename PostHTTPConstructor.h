//
//  PostHTTPConstructor.h
//  LabelMe
//
//  Created by Josep Marc Mingot Hidalgo on 13/09/13.
//  Copyright (c) 2013 CSAIL. All rights reserved.
//
/*
 
 Class  Responsibilities:
 
 - Give the methods to create easily an HTTP Post with or without files
 
 
 */
#import <Foundation/Foundation.h>

@interface PostHTTPConstructor : NSObject


- (void) createRequestForURL:(NSURL *)url forHTTPMethod:(NSString *)httpMethod;
- (void) addTokenAuthentication; 
- (void) addAuthenticationWihtUsername:(NSString *)username andPassword:(NSString *)password;
- (void) addFieldWithTitle:(NSString *)title forValue:(NSString *) value;
- (void) addFileFieldWithTitle:(NSString *)title withFilename:(NSString *)filename withMIMEType:(NSString *)mimeType forData:(NSData *)data;

- (NSMutableURLRequest *) getRequest;

@end
