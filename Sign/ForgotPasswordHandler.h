//
//  HandleCookie.h
//  DetectMe
//
//  Created by a on 20/12/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol ForgotPasswordHandlerDelegate <NSObject>
    
@optional
- (void) resetPassawordCompleted;
- (void) requestFailedWithErrorTitle:(NSString *)title errorMessage:(NSString *) message;

@end


/*
 
 Class  Responsibilities:
 
 - Request the cookie for the reset password page
 - Store the cookie
 
 */

@interface ForgotPasswordHandler : NSObject <NSURLConnectionDataDelegate>
    
@property (strong, nonatomic) id<ForgotPasswordHandlerDelegate> delegate;
    
- (void) resetPasswordForEmail:(NSString *)email;

@end