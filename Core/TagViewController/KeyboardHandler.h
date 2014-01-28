//
//  KeyboardHandler.h
//  LabelMe
//
//  Created by Josep Marc Mingot Hidalgo on 01/08/13.
//  Copyright (c) 2013 CSAIL. All rights reserved.
//
 


@protocol KeyboardHandlerDataSource <NSObject>

- (NSArray *)arrayOfWords;

@end


/*
 
 Class  Responsibilities:
 
 - Moves the given UITextField view up if it was hidden by the keyboard
 - Suggests words acorring to the data soruce

 
 */

#import <Foundation/Foundation.h>

@interface KeyboardHandler : NSObject

@property (strong, nonatomic) id<KeyboardHandlerDataSource> dataSource;

- (id) initWithTextField:(UITextField *)textField;

- (void) setTextField:(UITextField *) textField;

@end
