//
//  AuthHelper.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 04/10/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AuthHelperDelegate <NSObject>

@optional
- (void) signInCompleted;
- (void) signUpCompleted;


- (void) forgetPasswordEndedWithResult:(BOOL) success andMessage:(NSString *)message;

- (void) requestFailedWithErrorMessages: (NSDictionary *)errorMessages;

@end

/*
 
 Class  Responsibilities:
 
 - Create the post for sign in
 - Store session credentials
 - Remove credentials when log out
 
 
 */

@interface AuthHelper : NSObject <NSURLConnectionDataDelegate>

@property (strong, nonatomic) id<AuthHelperDelegate> delegate;
- (void) signInUsername:(NSString *)username forPassword:(NSString *) password;
+ (void) signOut;
- (void) signUpUsername:(NSString *)username forEmail:(NSString *)email forPassword:(NSString *)password;

@end
