//
//  DictionaryQueue.m
//  LabelMe
//
//  Created by Josep Marc Mingot Hidalgo on 07/08/13.
//  Copyright (c) 2013 CSAIL. All rights reserved.
//

#import "DictionaryQueue.h"

@interface DictionaryQueue()
{
    NSMutableDictionary *_dictionary;
    NSMutableArray *_array;
    int _capacity;
}
@end


@implementation DictionaryQueue


- (id)initWithCapcity:(int)capacity
{
    if (self = [super init]) {
        _dictionary = [[NSMutableDictionary alloc] initWithCapacity:capacity];
        _array = [[NSMutableArray alloc] initWithCapacity:capacity];
        _capacity = capacity;
    }
    return self;
}

- (void) enqueueObject:(id)object forKey:(id) key
{
    [_dictionary setObject:object forKey:key];
    [_array addObject:key];
    if(_array.count == _capacity){
        NSString *keyToRemove = [_array objectAtIndex:0];
        [_array removeObjectAtIndex:0];
        [_dictionary removeObjectForKey:keyToRemove];
    }
}

- (id) objectForKey:(id)key
{
    return [_dictionary objectForKey:key];
}

-(void) removeAllObjects
{
    [_dictionary removeAllObjects];
    [_array removeAllObjects];
}

@end
