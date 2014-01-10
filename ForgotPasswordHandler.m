//
//  HandleCookie.m
//  DetectMe
//
//  Created by a on 20/12/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "ForgotPasswordHandler.h"
#import "ConstantsServer.h"
#import "PostHTTPConstructor.h"
#import "ManagedDocumentHelper.h"
#import "User+Create.h"


@interface ForgotPasswordHandler()
{
    NSString *_email;
    BOOL _isGet;
}

@end


@implementation ForgotPasswordHandler
    
    
#pragma mark -
#pragma mark Public methods
    
    
- (void) resetPasswordForEmail:(NSString *)email
{
    _email= email;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@accounts/password/reset/",SERVER_ADDRESS]]];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    _isGet = YES;
    [connection start];
    
}

    
#pragma mark -
#pragma mark NSURLConnectionDataDelegate
    
- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if(_isGet){
        NSString *cookie = [self parseCookieFromResponse:response];
        NSString *cookieHeader = [NSString stringWithFormat:@"csrftoken=%@", cookie];
        _isGet = NO;
        
        if(cookie)
            [self postRequestForEmailWithCookie:cookie forCookieHeader:cookieHeader];
        else
            [self.delegate requestFailedWithErrorTitle:@"Error" errorMessage:@"Cookie not received!"];
        
    }else{
    
        NSString *url = [[(NSHTTPURLResponse *)response URL] absoluteString];
        NSArray *array = [url componentsSeparatedByString:@"/"];
        NSString *lastIndex = [array objectAtIndex:array.count-2];
        NSLog(@"li: %@", lastIndex);
        if([lastIndex isEqualToString:@"done"]){
            [self.delegate resetPassawordCompleted];
        }else{
            [self.delegate requestFailedWithErrorTitle:@"Error" errorMessage:@"Incorrect email"];
        }
    }
}

    
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
}
    
-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
}
    
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
}
    
    
#pragma mark -
#pragma mark Private Methods


- (NSString *) parseCookieFromResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    NSDictionary *fields = [HTTPResponse allHeaderFields];
    NSString *cookieAll = [fields valueForKey:@"Set-Cookie"];// It is your cookie
    NSRange range = [cookieAll rangeOfString:@";"];
    NSString *cookie_cut = [cookieAll substringToIndex:range.location];
    range = [cookie_cut rangeOfString:@"="];
    NSString *cookie = [cookie_cut substringFromIndex:range.location+1];
    
    return cookie;
}

- (void) postRequestForEmailWithCookie:(NSString *)cookie forCookieHeader:(NSString *)cookieHeader
{
    NSString *urlWebServer = [NSString stringWithFormat:@"%@accounts/password/reset/",SERVER_ADDRESS];
    
    // initiate creation of the request
    PostHTTPConstructor *requestConstructor = [[PostHTTPConstructor alloc] init];
    
    [requestConstructor createRequestForURL:[NSURL URLWithString:urlWebServer] forHTTPMethod:@"POST"];
    [requestConstructor addCookieHeader:cookieHeader];
    [requestConstructor addFieldWithTitle:SERVER_AUTH_EMAIL forValue:_email];
    [requestConstructor addFieldWithTitle:SERVER_AUTH_CSRFCOOKIE forValue:cookie];
    
    
    // URL Connection
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[requestConstructor getRequest] delegate:self];
    [conn start];
}

@end