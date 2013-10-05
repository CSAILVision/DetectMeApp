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
- (void) signInCompletedWithToken:(NSString *)token;
- (void) signInFailedWithErrorMessage:(NSString *) errorMessage;


- (void) signUpEndedWithResult:(BOOL) success andMessage:(NSString *)message;
- (void) forgetPasswordEndedWithResult:(BOOL) success andMessage:(NSString *)message;

@end


@interface AuthHelper : NSObject <NSURLConnectionDataDelegate>

@property (strong, nonatomic) id<AuthHelperDelegate> delegate;
- (void) singInUsername:(NSString *)username forPassword:(NSString *) password;

@end
