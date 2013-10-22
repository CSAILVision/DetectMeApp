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
    url = [url URLByAppendingPathComponent:@"detector_database"];
        
    static DebugManagedDocument *managedDocument;
    static dispatch_once_t mngddoc;
    
    
    dispatch_once(&mngddoc, ^{
        managedDocument = [[DebugManagedDocument alloc] initWithFileURL:url];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]){
            
            [managedDocument saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
                completionBlock(managedDocument);
            }];
            
        } else if(managedDocument.documentState == UIDocumentStateClosed){
            
            [managedDocument openWithCompletionHandler:^(BOOL success){
                completionBlock(managedDocument);
            }];

        } else if(managedDocument.documentState == UIDocumentStateNormal){
            completionBlock(managedDocument);
        }
    });
 
    return (UIManagedDocument *) managedDocument;
}



@end
