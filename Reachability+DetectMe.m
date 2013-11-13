//
//  Reachability+DetectMe.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 13/11/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "Reachability+DetectMe.h"
#import "ManagedDocumentHelper.h"
#import "User+Create.h"

@implementation Reachability (DetectMe)

+ (BOOL) isNetworkReachable
{
    
    UIManagedDocument *database = [ManagedDocumentHelper sharedDatabaseUsingBlock:^(UIManagedDocument *document) {}];
    User *currentUser = [User getCurrentUserInManagedObjectContext:database.managedObjectContext];
    
    //check settings for wifi only and network reachability
    BOOL isReachable = YES;
    BOOL isWifiOnly = currentUser.isWifiOnly.boolValue;
    NetworkStatus networkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if (isWifiOnly) {
        if ((networkStatus != ReachableViaWiFi) && (networkStatus !=NotReachable)) {
            isReachable = NO;
        }
    }
    
    return  isReachable;
}

@end
