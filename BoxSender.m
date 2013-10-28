//
//  BoxSender.m
//  LabelMe
//
//  Created by Josep Marc Mingot Hidalgo on 01/09/13.
//  Copyright (c) 2013 CSAIL. All rights reserved.
//

#import "BoxSender.h"
#import "BoundingBox.h"
#import "SocketIO.h"
#import "SocketIOPacket.h"
#import "BLWebSocketsServer.h"
#import "NSString+Base64Encoding.h"
#import "UIImage+Rotation.h"
#import "ConstantsServer.h"


@interface BoxSender() <SocketIODelegate>
{
    SocketIO *_socketIO;
    BLWebSocketsServer *_webSocketServer;
    NSString *_username;
}


@end

@implementation BoxSender

#pragma mark -
#pragma mark Initialization

- (id)init
{
    
    if (self = [super init]) {
        _username = [[NSUserDefaults standardUserDefaults] stringForKey:USER_DEFAULTS_USERNAME];
    }
    return self;
}

- (void) connectSocketIO
{    
    _socketIO = [[SocketIO alloc] initWithDelegate:self];
    [_socketIO connectToHost:SERVER_IP onPort:SERVER_PORT_NODE];
    [_socketIO sendEvent:@"iphone_connect" withData:_username];
}

- (void) disconnectSocketIo
{
    [_socketIO sendEvent:@"iphone_disconnect" withData:_username];
    [_socketIO disconnect];
}


- (void) dealloc
{
    [self closeConnection];
}


#pragma mark -
#pragma mark Public methods


- (void) openConnection
{
    // Connect to the web server to notify you are in disposition of sending detections
    [self connectSocketIO];
    
    // Start the server to send the detections
    [[BLWebSocketsServer sharedInstance] startListeningOnPort:MOBILE_LISTENING_PORT withProtocolName:@"echo-protocol" andCompletionBlock:^(NSError *error) {
        NSLog(@"Server started");
    }];
    
    [[BLWebSocketsServer sharedInstance] setHandleRequestBlock:^NSData *(NSData *data) {
        //simply echo what has been received
        return data;
    }];
}


- (void) closeConnection
{
    [[BLWebSocketsServer sharedInstance] stopWithCompletionBlock:^ {
        NSLog(@"Server stopped");
    }];
}

- (void) sendBoxes:(NSArray *)boxes
{
    
    NSMutableDictionary *boxDictionary = [[NSMutableDictionary alloc] initWithCapacity:1];
    
    for(NSArray *detectorBoxes in boxes)
        for(BoundingBox *box in detectorBoxes){
            [boxDictionary setObject:[NSString stringWithFormat:@"%f", box.xmin] forKey:@"xcoord"];
            [boxDictionary setObject:[NSString stringWithFormat:@"%f", box.ymin] forKey:@"ycoord"];
            [boxDictionary setObject:[NSString stringWithFormat:@"%f", (box.xmax - box.ymin)] forKey:@"width"];
            [boxDictionary setObject:[NSString stringWithFormat:@"%f", (box.ymax - box.ymin)] forKey:@"height"];
            [_socketIO sendEvent:@"emit_bb" withData:boxDictionary];
        }
}

- (void) sendImage:(UIImage *)image
{
    NSData *imageData = [self compressImage:image];
    NSString *imageBase64 = [NSString base64StringFromData:imageData length:imageData.length];
    [_socketIO sendEvent:@"emit_image" withData:imageBase64];
}

- (void) sendBoxes:(NSArray *)boxes forImage:(UIImage *)image
{
    NSMutableDictionary *messageDictionary = [[NSMutableDictionary alloc] init];
    
    //boxes
    NSMutableDictionary *boxDictionary = [[NSMutableDictionary alloc] initWithCapacity:1];
    
    for(NSArray *detectorBoxes in boxes)
        for(BoundingBox *box in detectorBoxes){
            
            [boxDictionary setObject:[NSString stringWithFormat:@"%f", box.xmin] forKey:@"xcoord"];
            [boxDictionary setObject:[NSString stringWithFormat:@"%f", box.ymin] forKey:@"ycoord"];
            [boxDictionary setObject:[NSString stringWithFormat:@"%f", (box.xmax - box.xmin)] forKey:@"width"];
            [boxDictionary setObject:[NSString stringWithFormat:@"%f", (box.ymax - box.ymin)] forKey:@"height"];
        }
    [messageDictionary setObject:boxDictionary forKey:@"bb"];
    
    //image
    UIImage *imageOriented = [image fixOrientation];
    NSData *imageData = [self compressImage:imageOriented];
    NSString *imageBase64 = [NSString base64StringFromData:imageData length:imageData.length];
    
    [messageDictionary setObject:imageBase64 forKey:@"imageBase64"];
    
    NSData *message;
    __autoreleasing NSError *error = nil;
    
    message = [NSJSONSerialization dataWithJSONObject:messageDictionary options:NSJSONWritingPrettyPrinted error:&error];

    
    if (!error) {
        // Enqueue the message in the push queue 
        [[BLWebSocketsServer sharedInstance] pushToAll:message];
    }else {
        NSLog(@"%@", error);
    }

    
}


- (NSData *) compressImage:(UIImage *)image
{
    return UIImageJPEGRepresentation(image, 0.0); // JPEG compression to the lowest quality
}

#pragma mark -
#pragma mark SocketIO Delegate


- (void) socketIODidConnect:(SocketIO *)socket
{
//    NSLog(@"[socketIO] connected");
}

- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
//    NSLog(@"[socketIO] disconnected");
}

- (void) socketIO:(SocketIO *)socket didSendMessage:(SocketIOPacket *)packet
{
//    NSLog(@"[socketIO] message sent");
}

- (void) socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet
{
//    NSLog(@"[socketIO] didReceiveMessage() >>> data: %@", packet.data);
}


@end
