//
//  ShareDetector.m
//  LabelMe
//
//  Created by Josep Marc Mingot Hidalgo on 12/09/13.
//  Copyright (c) 2013 CSAIL. All rights reserved.
//

#import "ShareDetector.h"
#import "PostHTTPConstructor.h"
#import "ConstantsServer.h"
#import "AnnotatedImage.h"

@interface ShareDetector()
{
    NSString *_user;
    NSString *_password;
    PostHTTPConstructor *_requestConstructor;
    NSMutableData *_responseData;
    
    Detector *_detector;
    AnnotatedImage *_annotatedImage;
}
@end


@implementation ShareDetector

#pragma mark -
#pragma mark Initialization

- (id)init
{
    if (self = [super init]) {
//        _user = @"ramon";
//        _password = @"ramon";
        _requestConstructor = [[PostHTTPConstructor alloc] init];
    }
    return self;
} 

#pragma mark -
#pragma mark Public methods

-(void) shareDetector:(Detector *)detector
{
    _detector = detector;
    
    NSString *urlWebServer = [NSString stringWithFormat:@"%@detectors/api/",SERVER_ADDRESS];
    
    // select between create or update of objects
    NSString *httpMethod;
    if(detector.serverDatabaseID.intValue > 0){
        httpMethod =  @"PUT";
        urlWebServer = [NSString stringWithFormat:@"%@%@",urlWebServer,detector.serverDatabaseID];
    }else httpMethod = @"POST";
    
    // initiate creation of the request
    [_requestConstructor createRequestForURL:[NSURL URLWithString:urlWebServer] forHTTPMethod:httpMethod];
    
//    // authenticate
//    [_requestConstructor addAuthenticationWihtUsername:_user andPassword:_password];
    
    NSDictionary *dict = [self getDictionaryFromDetector:detector];
    
    // construct the request adding the fields from the dictionary and the images
    for(NSString *key in dict)
        [_requestConstructor addFieldWithTitle:key forValue:[dict objectForKey:key]];
    
    [_requestConstructor addFileFieldWithTitle:SERVER_DETECTOR_IMAGE
                                  withFilename:[NSString stringWithFormat:@"%@_average_image.jpeg",detector.name]
                                  withMIMEType:@"image/jpeg"
                                       forData:detector.image];
    
    // URL Connection
    _responseData = [[NSMutableData alloc] init];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[_requestConstructor getRequest] delegate:self];
    [conn start];
}


- (void) shareAnnotatedImage:(AnnotatedImage *)annotatedImage
{
    _annotatedImage = annotatedImage;
    
    NSString *urlWebServer = [NSString stringWithFormat:@"%@detectors/api/annotatedimages/",SERVER_ADDRESS];
    
    // initiate creation of the request
    [_requestConstructor createRequestForURL:[NSURL URLWithString:urlWebServer] forHTTPMethod:@"POST"];
    
//    // authenticate
//    [_requestConstructor addAuthenticationWihtUsername:_user andPassword:_password];
    
    NSDictionary *dict = [self getDictionaryFromAnnotatedImage:annotatedImage];
    
    // construct the request adding the fields from the dictionary and the images
    for(NSString *key in dict)
        [_requestConstructor addFieldWithTitle:key forValue:[dict objectForKey:key]];
    
    [_requestConstructor addFileFieldWithTitle:SERVER_AIMAGE_IMAGE
                                  withFilename:[NSString stringWithFormat:@"%@_annotated_image.jpeg",_detector.name]
                                  withMIMEType:@"image/jpeg"
                                       forData:annotatedImage.image];
    
    // URL Connection
    _responseData = [[NSMutableData alloc] init];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[_requestConstructor getRequest] delegate:self];
    [conn start];
}


- (void) deletedetector:(Detector *)detector
{
    NSString *urlWebServer = [NSString stringWithFormat:@"%@detectors/api/",SERVER_ADDRESS];
    urlWebServer = [NSString stringWithFormat:@"%@%@",urlWebServer,detector.serverDatabaseID];
    
    // initiate creation of the request
    [_requestConstructor createRequestForURL:[NSURL URLWithString:urlWebServer] forHTTPMethod:@"PUT"];
    
//    // authenticate
//    [_requestConstructor addAuthenticationWihtUsername:_user andPassword:_password];
    
    [_requestConstructor addFieldWithTitle:SERVER_DETECTOR_DELETED forValue:@"True"];
    
    // URL Connection
    _responseData = [[NSMutableData alloc] init];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[_requestConstructor getRequest] delegate:self];
    [conn start];
}


#pragma mark -
#pragma mark NSURLConnectionDataDelegate

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]]){
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
        
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
    NSDictionary *objectJSON = [NSJSONSerialization JSONObjectWithData:_responseData options:kNilOptions error:&error];
    
    // update the detectorID field that stores the id of the detector on the webserver database
    if (error != nil) [self.delegate errorReceive:@"Error parsing JSON."];
    else {
        
        NSLog(@"object json: %@",objectJSON);
        
        if([objectJSON objectForKey:SERVER_DETECTOR_NAME]){ // it is a detector
            _detector.serverDatabaseID = [objectJSON objectForKey:SERVER_DETECTOR_ID];
            _detector.isSent = @(TRUE);
            [self.delegate finishedUploadingDetecor:objectJSON];
            
            for(AnnotatedImage *annotatedImage in _detector.annotatedImages)
                [self shareAnnotatedImage:annotatedImage];
            
            NSLog(@"sending this images:%@",_detector.annotatedImages);
            
        }else if([objectJSON objectForKey:SERVER_AIMAGE_AUTHOR]){
            _annotatedImage.isSent = @(TRUE);
            
        }else{
            NSLog(@"Error received with:%@",objectJSON);
        }
    }
}


#pragma	mark -
#pragma mark Private methods

- (NSDictionary *) getDictionaryFromDetector:(Detector *) detector
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjects:
                                 [NSArray arrayWithObjects:detector.name,
                                                           detector.targetClass,
                                                           detector.isPublic ? @"True":@"False",
                                                           @(2),
                                                           //detector.createdAt,
                                                           //detector.updatedAt,
                                                           [NSString stringWithFormat:@"%@",detector.sizes],
                                                           [NSString stringWithFormat:@"%@",detector.weights],
                                                           @"tbd.", nil]
                                 
                                                                   forKeys:
                                 [NSArray arrayWithObjects:SERVER_DETECTOR_NAME,
                                                           SERVER_DETECTOR_TARGET_CLASS,
                                                           SERVER_DETECTOR_PUBLIC,
                                                           SERVER_DETECTOR_AUTHOR,
                                                           //SERVER_DETECTOR_CREATED_AT,
                                                           //SERVER_DETECTOR_UPDATED_AT,
                                                           SERVER_DETECTOR_SIZES,
                                                           SERVER_DETECTOR_WEIGHTS,
                                                           SERVER_DETECTOR_SUPPORT_VECTORS,nil]];
    
    // if we are updating, specify for which detector
    if(!detector.serverDatabaseID>0){
        [dict setObject:detector.serverDatabaseID forKey:SERVER_DETECTOR_ID];
    }
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (NSDictionary *) getDictionaryFromAnnotatedImage:(AnnotatedImage *) annotatedImage
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjects:
                                 [NSArray arrayWithObjects:annotatedImage.boxX,
                                                           annotatedImage.boxY,
                                                           annotatedImage.boxWidth,
                                                           annotatedImage.boxHeight,
                                                           @(2),
                                                           _detector.serverDatabaseID,nil]
                                 
                                                                   forKeys:
                                 [NSArray arrayWithObjects:SERVER_AIMAGE_BOX_X,
                                                           SERVER_AIMAGE_BOX_Y,
                                                           SERVER_AIMAGE_BOX_WIDTH,
                                                           SERVER_AIMAGE_BOX_HEIGHT,
                                                           SERVER_AIMAGE_AUTHOR,
                                                           SERVER_AIMAGE_DETECTOR,nil]];
    
    
    return [NSDictionary dictionaryWithDictionary:dict];
}


@end




