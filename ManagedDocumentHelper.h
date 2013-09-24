//
//  ManagedDocumentHelper.h
//  DetectTube
//
//  Created by Josep Marc Mingot Hidalgo on 23/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 
 Class  Responsibilities:
 
 - Create and store a UIManagedDocument across the whole application. 
     From any place it can be requested to share the same NSManagedObjectContext
 
 */


typedef void (^completion_block_t)(UIManagedDocument *);

@interface ManagedDocumentHelper : NSObject

+ (UIManagedDocument *) sharedDatabaseUsingBlock:(completion_block_t)completionBlock;

@end
