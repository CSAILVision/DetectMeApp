//
//  ShareDetector.m
//  LabelMe
//
//  Created by Josep Marc Mingot Hidalgo on 12/09/13.
//  Copyright (c) 2013 CSAIL. All rights reserved.
//

#import "ShareDetector.h"
#import "PostHTTPConstructor.h"


@interface ShareDetector()
{
    NSString *_user;
    NSString *_password;
    PostHTTPConstructor *_requestConstructor;
    NSMutableData *_responseData;
}
@end


@implementation ShareDetector

#pragma mark -
#pragma mark Initialization

- (id)init
{
    if (self = [super init]) {
        _user = @"ramon";
        _password = @"ramon";
        _requestConstructor = [[PostHTTPConstructor alloc] init];
    }
    return self;
}

#pragma mark -
#pragma mark Public methods

-(void) shareDetector:(Detector *)detector
{
    
//    NSString *urlWebServer = @"http://128.30.99.160:8000/detectors/api/";
//    
//    // select between create or update of objects
//    NSString *httpMethod;
//    if(detector.databaseID != nil){
//        httpMethod =  @"PUT";
//        urlWebServer = [NSString stringWithFormat:@"%@%@",urlWebServer,detector.databaseID];
//    }else httpMethod = @"POST";
//    
//    // initiate creation of the request
//    [_requestConstructor createRequestForURL:[NSURL URLWithString:urlWebServer] forHTTPMethod:httpMethod];
//    
//    // authenticate
//    [_requestConstructor addAuthenticationWihtUsername:_user andPassword:_password];
//    
//    NSDictionary *dict = [NSDictionary dictionaryWithObjects:
//                          [NSArray arrayWithObjects:detector.name,
//                                                    @"tbd.",
//                                                    [NSString stringWithFormat:@"%@",detector.weights],
//                                                    [NSString stringWithFormat:@"%@",detector.sizes],
//                                                    @"True", nil]
//                                        forKeys:
//                          [NSArray arrayWithObjects:@"name",
//                                                    @"support_vectors",
//                                                    @"weights",
//                                                    @"dimensions",
//                                                    @"public", nil]];
//    
//    for(NSString *key in dict)
//        [_requestConstructor addFieldWithTitle:key forValue:[dict objectForKey:key]];
//    
//    UIImage *averageImage = [UIImage imageWithContentsOfFile:detector.averageImagePath];
//    NSData *imageData = [[NSData alloc] initWithData:UIImageJPEGRepresentation(averageImage, 1.0)];
//    [_requestConstructor addFileFieldWithTitle:@"average_image"
//                                 withFilename:[NSString stringWithFormat:@"%@_average_image.jpeg",detector.name]
//                                 withMIMEType:@"image/jpeg"
//                                      forData:imageData];
//    
//    // URL Connection
//    _responseData = [[NSMutableData alloc] init];
//    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[_requestConstructor getRequest] delegate:self];
//    [conn start];
    
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
    NSDictionary *detectorJSON = [NSJSONSerialization JSONObjectWithData:_responseData options:kNilOptions error:&error];
    
    // update the detectorID field that stores the id of the detector on the webserver database
    if (error != nil) [self.delegate errorReceive:@"Error parsing JSON."];
    else [self.delegate finishedUploadingDetecor:detectorJSON];
}

#pragma	mark -
#pragma mark Private methods

-(NSData *) getDataFromDetector:(Detector *) detector
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:
                          [NSArray arrayWithObjects:detector.name,@"tbd.",detector.weights,@"DETECTOR SIZES",@"True", nil]
                                                     forKeys:
                          [NSArray arrayWithObjects:@"name",@"support_vectors",@"weights",@"dimensions",@"public", nil]];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    return jsonData;
}


@end




