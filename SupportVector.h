//
//  SupportVector.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 08/10/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SupportVector : NSObject

@property (strong, nonatomic) NSArray *weights;
@property (strong, nonatomic) NSNumber *label;

- (id)initWithWeights:(NSArray *)weigths forLabel:(NSNumber *)label;
+ (NSString *) JSONFromSupportVectors:(NSArray *)supportVectors;
+ (NSArray *) suppportVectorsFromJSON:(NSString *) json;

@end
