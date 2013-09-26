//
//  DictionaryQueue.h
//  LabelMe
//
//  Created by Josep Marc Mingot Hidalgo on 07/08/13.
//  Copyright (c) 2013 CSAIL. All rights reserved.
//

#import <Foundation/Foundation.h>



/*
 
 Class  Responsibilities:
 
 - Provides a dictionary with queue capabilities to limit the number of entries
 
 */

@interface DictionaryQueue : NSObject


- (id) initWithCapcity:(int) capacity;
- (void) enqueueObject:(id)object forKey:(id) key;
- (id) objectForKey:(id) key;
- (void) removeAllObjects;

@end
