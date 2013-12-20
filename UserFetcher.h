//
//  UserFetcher.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 20/12/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol UserFetcherDelegate <NSObject>

- (void) obtainedUser:(NSDictionary *)userJSON;
- (void) downloadError:(NSString *)error;

@end

@interface UserFetcher : NSObject <NSURLConnectionDataDelegate>

// request info from the server about the user
// wait response on the delegate
- (void) getUserWithUsername:(NSString *)username;

// same as above but when it finishes
// stores the user in the db
- (void) getAndStoreUserWithUsername:(NSString *) username;

@property (strong, nonatomic) id<UserFetcherDelegate> delegate;

@end
