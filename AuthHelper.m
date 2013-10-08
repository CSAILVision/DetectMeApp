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
#import "ManagedDocumentHelper.h"
#import "User+Create.h"

@interface AuthHelper()
{
    NSMutableData *_responseData;
    NSString *_username;
    NSString *_password;
}

@end


@implementation AuthHelper


#pragma mark -
#pragma mark Public methods

- (void) signInUsername:(NSString *)username forPassword:(NSString *) password
{
    _username = username;
    _password = password;
    
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

+  (void) signOut
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"isUserStored"];
    [defaults setObject:@"" forKey:USER_DEFAULTS_TOKEN];
    [defaults setObject:@"" forKey:USER_DEFAULTS_USERNAME];
    [defaults setObject:@"" forKey:USER_DEFAULTS_PASSWORD];
    [defaults synchronize];
}

- (void) signUpUsername:(NSString *)username forEmail:(NSString *)email forPassword:(NSString *)password
{
    _username = username;
    _password = password;
    
    NSString *urlWebServer = [NSString stringWithFormat:@"%@accounts/api/create/",SERVER_ADDRESS];
    
    // initiate creation of the request
    PostHTTPConstructor *requestConstructor = [[PostHTTPConstructor alloc] init];
    
    [requestConstructor createRequestForURL:[NSURL URLWithString:urlWebServer] forHTTPMethod:@"POST"];
    
    [requestConstructor addFieldWithTitle:SERVER_AUTH_USERNAME forValue:username];
    [requestConstructor addFieldWithTitle:SERVER_AUTH_EMAIL forValue:email];
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
    NSString *username = [responseJSON objectForKey:SERVER_AUTH_USERNAME];
    
    NSLog(@"response data: %@", [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding]);
    
    if(token){ //signin
        [self storeSessionForToken:token];
        [self storeUserInCoreData];
        [self.delegate signInCompleted];
        
        
    } else if(username){ //signup
        [self.delegate signUpCompleted];
        
    }else{
        [self.delegate requestFailedWithErrorMessages:responseJSON];
    }
}


#pragma mark -
#pragma mark PrivateMethods

- (void) storeSessionForToken:(NSString *) token
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:TRUE forKey:@"isUserStored"];
    [defaults setObject:token forKey:USER_DEFAULTS_TOKEN];
    [defaults setObject:_username forKey:USER_DEFAULTS_USERNAME];
    [defaults setObject:_password forKey:USER_DEFAULTS_PASSWORD];
    [defaults synchronize];
}

- (void) storeUserInCoreData
{
    [ManagedDocumentHelper sharedDatabaseUsingBlock:^(UIManagedDocument *document){
        [User userWithName:_username inManagedObjectContext:document.managedObjectContext];
    }];
}

@end
