//
//  ManagedDocumentHelper.m
//  DetectTube
//
//  Created by Josep Marc Mingot Hidalgo on 23/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "ManagedDocumentHelper.h"

@implementation ManagedDocumentHelper


+ (UIManagedDocument *) sharedDatabaseUsingBlock:(completion_block_t) completionBlock
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"databaseName"];
    // url is now "<Documents Directory>/databaseName"
    
    static UIManagedDocument *managedDocument = nil;
    static dispatch_once_t mngddoc;
    
    dispatch_once(&mngddoc, ^{
        managedDocument = [[UIManagedDocument alloc] initWithFileURL:url];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]){
            
            [managedDocument openWithCompletionHandler:^(BOOL success){
                completionBlock(managedDocument);
             }];
            
        } else {
            
            [managedDocument saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
                completionBlock(managedDocument);
             }];
        }
    });
    
    return managedDocument;
}

+ (UIManagedDocument *) sharedDatabase
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"Default Detector Database"];
    // url is now "<Documents Directory>/databaseName"
    
    static UIManagedDocument *managedDocument = nil;
    static dispatch_once_t mngddoc;
    
    dispatch_once(&mngddoc, ^{
        managedDocument = [[UIManagedDocument alloc] initWithFileURL:url];
    });
    
    return managedDocument;
}


@end
