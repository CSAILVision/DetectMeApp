//
//  ShareDetector.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 12/09/13.
//  Copyright (c) 2013 CSAIL. All rights reserved.
//

#import "ShareDetector.h"
#import "PostHTTPConstructor.h"
#import "ConstantsServer.h"
#import "AnnotatedImage.h"
#import "User.h"
#import "Rating.h"
#import "Reachability+DetectMe.h"

#define OBJECTIVE_DELETE_DETECTOR 1
#define OBJECTIVE_SEND_DETECTOR 2
#define OBJECTIVE_SEND_AIMAGE 3
#define OBJECTIVE_SEND_RATING 4
#define OBJECTIVE_SEND_PROFILE 5

@interface ShareDetector()
{
    NSString *_user;
    NSString *_password;
    PostHTTPConstructor *_requestConstructor;
    NSMutableData *_responseData;
    
    Detector *_detector;
    AnnotatedImage *_annotatedImage;
    Rating *_rating;
    
    int _objective;
}
@end






@implementation ShareDetector

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

-(void) shareDetector:(Detector *)detector toUpdate:(BOOL)isToUpdate;
{
    
    if(![Reachability isNetworkReachable]){
        detector.isSent = NO;
        return;
    }
    
    _objective = OBJECTIVE_SEND_DETECTOR;
    _detector = detector;
    
    NSString *urlWebServer = [NSString stringWithFormat:@"%@detectors/api/",SERVER_ADDRESS];
    
    NSString *httpMethod;
    if(isToUpdate){
        httpMethod =  @"PUT";
        urlWebServer = [NSString stringWithFormat:@"%@%@/",urlWebServer,detector.serverDatabaseID];
    }else httpMethod = @"POST";
    
    
    // initiate creation of the request
    [_requestConstructor createRequestForURL:[NSURL URLWithString:urlWebServer] forHTTPMethod:httpMethod];
    [_requestConstructor addTokenAuthentication];
    
    // authenticate with basic HTTP (used for development, not used with token authorization)
    //[_requestConstructor addAuthenticationWihtUsername:@"ramon" andPassword:@"ramon"];
    
    NSDictionary *dict = [self dictionaryFromDetector:detector];
    
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
    if(![Reachability isNetworkReachable]){
        annotatedImage.isSent = NO;
        return;
    }
    
    _objective = OBJECTIVE_SEND_AIMAGE;
    _annotatedImage = annotatedImage;
    
    NSString *urlWebServer = [NSString stringWithFormat:@"%@detectors/api/annotatedimages/",SERVER_ADDRESS];
    
    // initiate creation of the request
    [_requestConstructor createRequestForURL:[NSURL URLWithString:urlWebServer] forHTTPMethod:@"POST"];
    [_requestConstructor addTokenAuthentication];
    
    NSDictionary *dict = [self dictionaryFromAnnotatedImage:annotatedImage];
    
    // construct the request adding the fields from the dictionary and the images
    for(NSString *key in dict)
        [_requestConstructor addFieldWithTitle:key forValue:[dict objectForKey:key]];
    
    [_requestConstructor addFileFieldWithTitle:SERVER_AIMAGE_IMAGE
                                  withFilename:[NSString stringWithFormat:@"%@_annotated_image.jpeg",annotatedImage.detector.name]
                                  withMIMEType:@"image/jpeg"
                                       forData:annotatedImage.image];
    
    // URL Connection
    _responseData = [[NSMutableData alloc] init];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[_requestConstructor getRequest] delegate:self];
    [conn start];
}

- (void) shareRating:(Rating *)rating
{
    if(![Reachability isNetworkReachable]){
        rating.isSent = NO;
        return;
    }
    
    _objective = OBJECTIVE_SEND_RATING;
    _rating = rating;
    
    NSString *urlWebServer = [NSString stringWithFormat:@"%@detectors/api/ratings/",SERVER_ADDRESS];
    
    // initiate creation of the request
    [_requestConstructor createRequestForURL:[NSURL URLWithString:urlWebServer] forHTTPMethod:@"POST"];
    [_requestConstructor addTokenAuthentication];
    
    NSDictionary *dict = [self dictionaryFromRating:rating];
    
    // construct the request adding the fields from the dictionary and the images
    for(NSString *key in dict)
        [_requestConstructor addFieldWithTitle:key forValue:[dict objectForKey:key]];
    
    // URL Connection
    _responseData = [[NSMutableData alloc] init];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[_requestConstructor getRequest] delegate:self];
    [conn start];
}

- (void) deleteDetector:(Detector *)detector
{
    if(![Reachability isNetworkReachable]){
        [self.delegate requestFailedWithErrorTitle:@"Network not reachable" errorMessage:@"Detector could not be deleted from the server. Try again with internet connection."];
        return;
    }
    
    _objective = OBJECTIVE_DELETE_DETECTOR;
    _detector = detector;

    NSString *urlWebServer = [NSString stringWithFormat:@"%@detectors/api/",SERVER_ADDRESS];
    urlWebServer = [NSString stringWithFormat:@"%@%@/",urlWebServer,detector.serverDatabaseID];
    
    // initiate creation of the request
    [_requestConstructor createRequestForURL:[NSURL URLWithString:urlWebServer] forHTTPMethod:@"PATCH"];
    [_requestConstructor addTokenAuthentication];

    
    [_requestConstructor addFieldWithTitle:SERVER_DETECTOR_DELETED forValue:@"True"];
    
    // URL Connection
    _responseData = [[NSMutableData alloc] init];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[_requestConstructor getRequest] delegate:self];
    [conn start];
}


- (void) shareProfilePicture:(UIImage *) profilePicture forUsername:(NSString *)username
{
    if(![Reachability isNetworkReachable]){
        [self.delegate requestFailedWithErrorTitle:@"Network not reachable" errorMessage:@"Picture could not be send to the server. Try again with internet connection."];
        return;
    }
    _objective = OBJECTIVE_SEND_PROFILE;

    NSString *urlWebServer = [NSString stringWithFormat:@"%@accounts/api/update/%@/",SERVER_ADDRESS,username];
    
    [_requestConstructor createRequestForURL:[NSURL URLWithString:urlWebServer] forHTTPMethod:@"PUT"];
    [_requestConstructor addTokenAuthentication];
    
    //SERVER_PROFILE_IMAGE
    [_requestConstructor addFileFieldWithTitle:@"mugshot"
                                  withFilename:[NSString stringWithFormat:@"%@_profile_picture.jpg",username]
                                  withMIMEType:@"image/jpeg"
                                       forData:UIImageJPEGRepresentation(profilePicture, 0.5)];
    
    
    // URL Connection
    _responseData = [[NSMutableData alloc] init];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[_requestConstructor getRequest] delegate:self];
    [conn start];
}

#pragma mark -
#pragma mark NSURLConnectionDataDelegate

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.delegate requestFailedWithErrorTitle:@"Error" errorMessage:[error localizedDescription]];
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
        [self.delegate requestFailedWithErrorTitle:@"Error" errorMessage:@"Parsing JSON"];
        NSLog(@"objectJSON %@", objectJSON);
    }else {

        if([objectJSON objectForKey:SERVER_DETECTOR_NAME]){ // detector returned
            _detector.serverDatabaseID = [objectJSON objectForKey:SERVER_DETECTOR_ID];
            _detector.isSent = @(YES);
            NSLog(@"detector %@ sent", _detector.name);
            
            // Inform the delegate
            if(_objective==OBJECTIVE_SEND_DETECTOR) [self.delegate detectorDidSent];
            else if(_objective==OBJECTIVE_DELETE_DETECTOR) [self.delegate detectorDeleted];

        }else if([objectJSON objectForKey:SERVER_AIMAGE_BOX_HEIGHT]){ // annotated image returned
            _annotatedImage.isSent = @(YES);
            NSLog(@"Image sent");
            
            [self.delegate annotatedImageDidSent];

        }else if([objectJSON objectForKey:SERVER_RATING_RATING]){ // rating returned
            _rating.isSent = @(YES);
            
        }else{
            NSLog(@"Sending error: %@", objectJSON);
            [self.delegate requestFailedWithErrorTitle:@"Error" errorMessage:@"Failed to sent the detector"];
        }
    }
}


#pragma	mark -
#pragma mark Private methods

- (NSDictionary *) dictionaryFromDetector:(Detector *) detector
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjects:
                                 [NSArray arrayWithObjects:detector.name,
                                                           detector.targetClass,
                                                           detector.isPublic.boolValue ? @"True":@"False",
                                                           //detector.createdAt,
                                                           //detector.updatedAt,
                                                           [NSString stringWithFormat:@"%@",detector.sizes],
                                                           [NSString stringWithFormat:@"%@",detector.weights],
                                                           detector.supportVectors, nil]
                                 
                                                                   forKeys:
                                 [NSArray arrayWithObjects:SERVER_DETECTOR_NAME,
                                                           SERVER_DETECTOR_TARGET_CLASS,
                                                           SERVER_DETECTOR_PUBLIC,
                                                           //SERVER_DETECTOR_CREATED_AT,
                                                           //SERVER_DETECTOR_UPDATED_AT,
                                                           SERVER_DETECTOR_SIZES,
                                                           SERVER_DETECTOR_WEIGHTS,
                                                           SERVER_DETECTOR_SUPPORT_VECTORS,nil]];
    
    // if we are updating, specify for which detector
    if(!detector.serverDatabaseID.integerValue > 0)
        [dict setObject:detector.serverDatabaseID forKey:SERVER_DETECTOR_ID];
    
    if(detector.parentID.integerValue > 0)
        [dict setObject:detector.parentID forKey:SERVER_DETECTOR_PARENT];
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (NSDictionary *) dictionaryFromAnnotatedImage:(AnnotatedImage *) annotatedImage
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:
                             [NSArray arrayWithObjects:annotatedImage.boxX,
                                                       annotatedImage.boxY,
                                                       annotatedImage.boxWidth,
                                                       annotatedImage.boxHeight,
                                                       annotatedImage.locationLatitude,
                                                       annotatedImage.locationLongitude,
                                                       annotatedImage.motionQuaternionW,
                                                       annotatedImage.motionQuaternionX,
                                                       annotatedImage.motionQuaternionY,
                                                       annotatedImage.motionQuaternionZ,
                                                       annotatedImage.detector.serverDatabaseID,nil]
                                 
                                                     forKeys:
                             [NSArray arrayWithObjects:SERVER_AIMAGE_BOX_X,
                                                       SERVER_AIMAGE_BOX_Y,
                                                       SERVER_AIMAGE_BOX_WIDTH,
                                                       SERVER_AIMAGE_BOX_HEIGHT,
                                                       SERVER_AIMAGE_LOC_LATITUDE,
                                                       SERVER_AIMAGE_LOC_LONGITUDE,
                                                       SERVER_AIMAGE_MOT_QUATW,
                                                       SERVER_AIMAGE_MOT_QUATX,
                                                       SERVER_AIMAGE_MOT_QUATY,
                                                       SERVER_AIMAGE_MOT_QUATZ,
                                                       SERVER_AIMAGE_DETECTOR,nil]];
    
    
    return dict;
}

- (NSDictionary *) dictionaryFromRating:(Rating *) rating
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:
                          [NSArray arrayWithObjects:rating.detector.serverDatabaseID,
                                                    rating.rating,nil]
                          
                                                     forKeys:
                          [NSArray arrayWithObjects:SERVER_RATING_DETECTOR,
                                                    SERVER_RATING_RATING,nil]];
    
    return dict;
}


@end




