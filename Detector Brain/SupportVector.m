//
//  SupportVector.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 08/10/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "SupportVector.h"

@implementation SupportVector


#pragma mark -
#pragma mark Initialization

- (id)initWithWeights:(NSArray *)weigths forLabel:(NSNumber *)label
{
    if (self = [super init]) {
        self.weights = weigths;
        self.label = label;
    }
    return self;
}


#pragma mark -
#pragma mark Public Methods

+ (NSString *) JSONFromSupportVectors:(NSArray *)supportVectors
{
    NSMutableArray *svArray = [[NSMutableArray alloc] initWithCapacity:supportVectors.count];
    for (SupportVector *sv in supportVectors) {
        [svArray addObject:[sv JSONDictionary]];
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:svArray options:0 error:&error];
    NSString *jsonString = [NSString stringWithUTF8String:[jsonData bytes]];
    return jsonString;
}

+ (NSArray *) suppportVectorsFromJSON:(NSString *) json
{
    NSError *error;
    NSArray *svArray = (NSArray *)[NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
 
    NSMutableArray *sol = [[NSMutableArray alloc] initWithCapacity:svArray.count];
    for(NSDictionary *svDictionary in svArray){
        NSArray *weights = (NSArray *)[svDictionary objectForKey:@"weights"];
        NSNumber *label = (NSNumber *)[svDictionary objectForKey:@"label"];
        [sol addObject:[[SupportVector alloc] initWithWeights:weights forLabel:label]];
    }
    
    return [NSArray arrayWithArray:sol];
    
}


#pragma mark -
#pragma mark Private Methods

- (NSDictionary *) JSONDictionary
{
    NSDictionary *json = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                              self.label,
                                                              self.weights, nil]
                                                     forKeys:[NSArray arrayWithObjects:
                                                              @"label",
                                                              @"weights",nil]];
    return json;
}

#pragma mark -
#pragma mark Print

- (NSString *)description
{
    return [NSString stringWithFormat:@"label = %@", self.label];
}

@end
