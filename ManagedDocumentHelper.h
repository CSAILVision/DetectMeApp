//
//  ManagedDocumentHelper.h
//  DetectTube
//
//  Created by Josep Marc Mingot Hidalgo on 23/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^completion_block_t)(UIManagedDocument *);

@interface ManagedDocumentHelper : NSObject

+ (UIManagedDocument *) sharedDatabaseUsingBlock:(completion_block_t)completionBlock;
+ (UIManagedDocument *) sharedDatabase;
@end
