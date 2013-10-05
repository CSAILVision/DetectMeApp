//
//  AuthHelper.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 04/10/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "AuthHelper.h"
#import "ConstantsServer.h"
#import "PostHTTPConstructor.h"

@interface AuthHelper()
{
    NSMutableData *_responseData;
}

@end


@implementation AuthHelper


- (void) singInUsername:(NSString *)username forPassword:(NSString *) password
{
    NSString *urlWebServer = [NSString stringWithFormat:@"%@api-token-auth/",SERVER_ADDRESS];
    
    // initiate creation of the request
    PostHTTPConstructor *requestConstructor = [[PostHTTPConstructor alloc] init];
    
    [requestConstructor createRequestForURL:[NSURL URLWithString:urlWebServer] forHTTPMethod:@"POST"];
    
    [requestConstructor addFieldWithTitle:SERVER_AUTH_USERNAME forValue:username];
    [requestConstructor addFieldWithTitle:SERVER_AUTH_PASSWORD forValue:password];
    
    
    // URL Connection
    _responseData = [[NSMutableData alloc] init];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[requestConstructor getRequest] delegate:self];
    [conn start];
}

#pragma mark -
#pragma mark NSURLConnectionDataDelegate

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error ", @"")
                                message:[error localizedDescription]
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", @"")
                      otherButtonTitles:nil] show];
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error = nil;
    NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:_responseData options:kNilOptions error:&error];
    
    NSString *token = [responseJSON objectForKey:SERVER_TOKEN];
    
    if(token){
        [self.delegate signInCompletedWithToken:token];
        
    }else{
        // TODO: send meaningful error message
        NSLog(@"error: %@", responseJSON);
        [self.delegate signInFailedWithErrorMessage:@"ERROR"];
    }
}

@end
