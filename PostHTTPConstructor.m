//
//  PostHTTPConstructor.m
//  LabelMe
//
//  Created by Josep Marc Mingot Hidalgo on 13/09/13.
//  Copyright (c) 2013 CSAIL. All rights reserved.
//


//    ######### POST Example ##########
//
//    POST /upload?upload_progress_id=12344 HTTP/1.1
//    Host: localhost:3000
//    Content-Length: 1325
//    Origin: http://localhost:3000
//    Content-Type: multipart/form-data; boundary=----WebKitFormBoundaryePkpFF7tjBAqx29L
//    <other headers>
//
//    ------WebKitFormBoundaryePkpFF7tjBAqx29L
//    Content-Disposition: form-data; name="MAX_FILE_SIZE"
//
//    100000
//    ------WebKitFormBoundaryePkpFF7tjBAqx29L
//    Content-Disposition: form-data; name="uploadedfile"; filename="hello.o"
//    Content-Type: application/x-object
//
//    <file data>
//    ------WebKitFormBoundaryePkpFF7tjBAqx29L--
 


#import "PostHTTPConstructor.h"
#import "NSString+Base64Encoding.h"

@interface PostHTTPConstructor()
{
    NSString *_boundary;
    NSMutableURLRequest *_request;
    NSMutableData *_postBody;
}
@end

@implementation PostHTTPConstructor


#pragma mark -
#pragma mark Initialization


- (id)init
{
    if (self = [super init])
        _boundary = @"C3pOR2d2";
    
    return self;
}

- (void) createRequestForURL:(NSURL *)url forHTTPMethod:(NSString *)httpMethod;
{
    _request = [NSMutableURLRequest requestWithURL:url];
    [_request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [_request setHTTPShouldHandleCookies:NO];
    [_request setTimeoutInterval:30];
    [_request setHTTPMethod:httpMethod];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", _boundary];
    [_request setValue:contentType forHTTPHeaderField:@"Content-type"];
    
    // POST body to be filled
    _postBody = [[NSMutableData alloc] init];
}



#pragma mark -
#pragma mark Public Methods


- (void) addAuthenticationWihtUsername:(NSString *)username andPassword:(NSString *)password
{
    NSString *credentials = [NSString stringWithFormat:@"%@:%@",username,password];
    NSData *credentialsData = [credentials dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64encoding = [NSString base64StringFromData:credentialsData length:credentialsData.length];
    NSString *authorizationValue = [NSString stringWithFormat:@"Basic %@", base64encoding];
    
    [_request setValue:authorizationValue forHTTPHeaderField:@"Authorization"];
}

- (void) addFieldWithTitle:(NSString *)title forValue:(NSString *) value
{
    [_postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", _boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [_postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", title] dataUsingEncoding:NSUTF8StringEncoding]];
    [_postBody appendData:[[NSString stringWithFormat:@"%@\r\n", value] dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void) addFileFieldWithTitle:(NSString *)title withFilename:(NSString *)filename withMIMEType:(NSString *)mimeType forData:(NSData *)data;
{
    [_postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", _boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [_postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",title, filename] dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *contentType = [NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimeType];
    [_postBody appendData:[contentType dataUsingEncoding:NSUTF8StringEncoding]];
    [_postBody appendData:data];
    [_postBody appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
}


- (NSMutableURLRequest *) getRequest
{
    [_postBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", _boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [_request setHTTPBody:_postBody];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%d", _postBody.length];
    [_request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    return _request;
}

@end
