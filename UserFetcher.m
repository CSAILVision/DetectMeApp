//
//  UserFetcher.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 20/12/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "UserFetcher.h"
#import "Reachability+DetectMe.h"
#import "ConstantsServer.h"
#import "User+Create.h"
#import "ManagedDocumentHelper.h"

@interface UserFetcher()
{
    NSMutableData *_responseData;
    BOOL _store;
}

@end


@implementation UserFetcher

- (NSURLRequest *) createRequestForURLString:(NSString *) requestURLString
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURLString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    return request;
}

#pragma mark -
#pragma mark Public functions

- (void) getUserWithUsername:(NSString *)username
{
    if(![Reachability isNetworkReachable])
        return;
        
    NSString *requestURLString = [NSString stringWithFormat:@"%@accounts/api/detail/%@/",SERVER_ADDRESS, username];
    NSURLRequest *request = [self createRequestForURLString:requestURLString];
    
    _responseData = [[NSMutableData alloc] init];
    [NSURLConnection connectionWithRequest:request delegate:self];
    
    // show in the status bar that network activity is starting
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void) getAndStoreUserWithUsername:(NSString *) username
{
    _store = YES;
    [self getUserWithUsername:username];
}

#pragma mark -
#pragma mark NSURLConnectionDelegate


- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.delegate downloadError:error.localizedDescription];
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error = nil;
    NSDictionary *userJSON = [NSJSONSerialization JSONObjectWithData:_responseData options:kNilOptions error:&error];
    
    // update the detectorID field that stores the id of the detector on the webserver database
    if (error != nil) [self.delegate downloadError:@"Error parsing JSON."];
    else [self.delegate obtainedUser:userJSON];
    
    if(_store) [self storeUserWithInfo:userJSON];
}


#pragma mark -
#pragma mark Private Methods

- (void) storeUserWithInfo:(NSDictionary *)userJSON
{
    UIManagedDocument *document = [ManagedDocumentHelper sharedDatabaseUsingBlock:^(UIManagedDocument *document) {}];
    [User userWithDictionaryInfo:userJSON inManagedObjectContext:document.managedObjectContext];
}


@end
