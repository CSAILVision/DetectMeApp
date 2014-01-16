//
//  SendReport.m
//  DetectMe
//
//  Created by a on 16/01/14.
//  Copyright (c) 2014 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "SendReportHelper.h"
#import "Reachability+DetectMe.h"
#import "ConstantsServer.h"
#import "PostHTTPConstructor.h"



@interface SendReportHelper()
{
    PostHTTPConstructor *_requestConstructor;
    NSMutableData * _responseData;
}
@end


@implementation SendReportHelper

#pragma mark -
#pragma mark Initialization

- (id)init
{
    if (self = [super init]) {
        _requestConstructor = [[PostHTTPConstructor alloc] init];
    }
    return self;
}

#pragma mark -
#pragma mark Public methods
- (void) sendReport: (Detector *) detector
{
    if(![Reachability isNetworkReachable]){
        [self.delegate requestForReportFailedWithErrorTitle:@"Connection Error" errorMessage:@"No connection"];
        return;
    }
    
    
    NSString *urlWebServer = [NSString stringWithFormat:@"%@detectors/api/report/",SERVER_ADDRESS];
    
    // initiate creation of the request
    [_requestConstructor createRequestForURL:[NSURL URLWithString:urlWebServer] forHTTPMethod:@"POST"];
    [_requestConstructor addTokenAuthentication];
    
    
    [_requestConstructor addFieldWithTitle:SERVER_REPORT_DETECTOR forValue:[NSString stringWithFormat:@"%@",detector.serverDatabaseID]];
    
    // URL Connection
    _responseData = [[NSMutableData alloc] init];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[_requestConstructor getRequest] delegate:self];
    [conn start];
}

#pragma mark -
#pragma mark NSURLConnectionDelegate
- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.delegate requestForReportFailedWithErrorTitle:@"Error" errorMessage:[error localizedDescription]];
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error = nil;
    NSDictionary *objectJSON = [NSJSONSerialization JSONObjectWithData:_responseData options:kNilOptions error:&error];
    
    if (error != nil){
        [self.delegate requestForReportFailedWithErrorTitle:@"Error" errorMessage:error.localizedDescription];
        
    }else {
        
        [self.delegate didSendReport];
    }
}




@end
