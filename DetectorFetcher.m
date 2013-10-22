//
//  DetectorDownloader.m
//  LabelMe
//
//  Created by Josep Marc Mingot Hidalgo on 16/09/13.
//  Copyright (c) 2013 CSAIL. All rights reserved.
//

#import "DetectorFetcher.h"
#import "Detector.h"
#import "ConstantsServer.h"


@interface DetectorFetcher()
{
    NSMutableData *_responseData;
}

@end


@implementation DetectorFetcher


#pragma mark -
#pragma mark Initialization


+ (NSURLRequest *) createRequest
{
    NSString *requestURLString = [NSString stringWithFormat:@"%@detectors/api/",SERVER_ADDRESS];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURLString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    return request;
}

#pragma mark -
#pragma mark Public Methods

- (void) fetchDetectorsASync
{
    NSURLRequest *request = [self.class createRequest];
    
    _responseData = [[NSMutableData alloc] init];
    [NSURLConnection connectionWithRequest:request delegate:self];
    
    // show in the status bar that network activity is starting
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

+ (NSArray *) fetchDetectorsSync
{
    NSURLRequest *request = [self createRequest];
    

    NSError *error;
    NSURLResponse *response;
    NSData *jsonData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSArray *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error] : nil;
    if (error) NSLog(@"[%@ %@] JSON error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
    
    return results;
}

#pragma mark -
#pragma mark NSURLConnectionDataDelegate

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]]){
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
        NSLog(@"httpresponse: %@", httpResponse);
        
        // TODO: sent error message correctly after seeing http header.
    }
    
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
    NSArray *detectorsJSON = [NSJSONSerialization JSONObjectWithData:_responseData options:kNilOptions error:&error];
    
    // update the detectorID field that stores the id of the detector on the webserver database
    if (error != nil) [self.delegate downloadError:@"Error parsing JSON."];
    else [self.delegate obtainedDetectors:detectorsJSON];
}

#pragma mark -
#pragma mark Private Methods

- (NSArray *) detectorsJSONToObjects:(NSArray *)detectorsJSON
{
    
    NSString *serverAdress = [NSString stringWithFormat:@"%@media/", SERVER_ADDRESS];
    NSMutableArray *detectors = [NSMutableArray arrayWithCapacity:detectorsJSON.count];
    for(NSDictionary *detectorJSON in detectorsJSON) {

        NSString *url = [NSString stringWithFormat:@"%@%@",serverAdress,[detectorJSON objectForKey:@"average_image"]];
        NSString *name = [detectorJSON objectForKey:@"name"];
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:name, url,nil]
                                                         forKeys:[NSArray arrayWithObjects:@"name",@"url",nil]];
        [detectors addObject:dict];
    }
    
    return [NSArray arrayWithArray:detectors];
}


@end
