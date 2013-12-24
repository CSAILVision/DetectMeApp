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
    NSMutableData *_responseData;
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
    [connection start];
}

    
#pragma mark -
#pragma mark NSURLConnectionDataDelegate
    
- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{

    NSString *cookie = [self parseCookieFromResponse:response];
    
    if(cookie)
        [self postRequestForEmailWithCookie:cookie];
    else
        [self.delegate requestFailedWithErrorTitle:@"Error" errorMessage:@"Cookie not received!"];
}
    
    
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
}
    
-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_responseData appendData:data];
}
    
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error = nil;
    NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:_responseData options:kNilOptions error:&error];
    
    // when there is a error, the value of the key-value pair is an array.
    id email = [responseJSON objectForKey:SERVER_AUTH_EMAIL];
    
    if([email isKindOfClass:[NSString class]])
        [self.delegate resetPassawordCompleted];
    else
        [self handleErrorForJSON:responseJSON];

}
    
    
#pragma mark -
#pragma mark Private Methods

- (void) handleErrorForJSON:(NSDictionary *)errorJSON
{
    NSArray *keys = [errorJSON allKeys];
    NSArray *values = [errorJSON allValues];
    
    NSString *title = [keys firstObject];
    NSString *message = [[values firstObject] firstObject];
    
    if([title isEqualToString:@"non_field_errors"]) title = @"Error";
    
    [self.delegate requestFailedWithErrorTitle:title errorMessage:message];
}

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

- (void) postRequestForEmailWithCookie:(NSString *)cookie
{
    NSString *urlWebServer = [NSString stringWithFormat:@"%@accounts/api/password/reset/",SERVER_ADDRESS];
    
    // initiate creation of the request
    PostHTTPConstructor *requestConstructor = [[PostHTTPConstructor alloc] init];
    
    [requestConstructor createRequestForURL:[NSURL URLWithString:urlWebServer] forHTTPMethod:@"POST"];
    [requestConstructor addFieldWithTitle:SERVER_AUTH_EMAIL forValue:_email];
    [requestConstructor addFieldWithTitle:SERVER_AUTH_CSRFCOOKIE forValue:cookie];
    
    // URL Connection
    _responseData = [[NSMutableData alloc] init];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[requestConstructor getRequest] delegate:self];
    [conn start];
}

@end