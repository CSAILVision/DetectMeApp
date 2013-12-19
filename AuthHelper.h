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
- (void) requestFailedWithErrorTitle:(NSString *)title errorMessage:(NSString *) message;

@end

/*
 
 Class  Responsibilities:
 
 - Create the post for sign in
 - Store session credentials
 - Remove credentials when log out
 - Handling errors and just delegate title and body of the 
   error message
 
 
 */

@interface AuthHelper : NSObject <NSURLConnectionDataDelegate>

@property (strong, nonatomic) id<AuthHelperDelegate> delegate;
- (void) signInUsername:(NSString *)username forPassword:(NSString *) password;
+ (void) signOut;
- (void) signUpUsername:(NSString *)username forEmail:(NSString *)email forPassword:(NSString *)password;
- (void) resetPasswordForEmail:(NSString *)email;

@end
