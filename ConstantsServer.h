//
//  ConstantsServer.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 30/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#ifndef DetectMe_ConstantsServer_h
#define DetectMe_ConstantsServer_h

// SERVER MISCELLANIA
#define SERVER_IP @"128.30.99.19"
#define SERVER_PORT 8000
#define SERVER_PORT_NODE 7000
#define MOBILE_LISTENING_PORT 9000
#define SERVER_ADDRESS @"http://128.30.99.19:8000/"
#define SERVER_TOKEN @"token"

// AUTHORIZATION IN SERVER
#define SERVER_AUTH_USERNAME @"username"
#define SERVER_AUTH_PASSWORD @"password"
#define SERVER_AUTH_EMAIL @"email"

// DETECTOR
#define SERVER_DETECTOR_ID @"id"
#define SERVER_DETECTOR_NAME @"name"
#define SERVER_DETECTOR_TARGET_CLASS @"target_class"
#define SERVER_DETECTOR_AUTHOR @"author"
#define SERVER_DETECTOR_PUBLIC @"is_public"
#define SERVER_DETECTOR_IMAGE @"average_image"
#define SERVER_DETECTOR_CREATED_AT @"created_at"
#define SERVER_DETECTOR_UPDATED_AT @"updated_at"
#define SERVER_DETECTOR_WEIGHTS @"weights"
#define SERVER_DETECTOR_SIZES @"sizes"
#define SERVER_DETECTOR_SUPPORT_VECTORS @"support_vectors"
#define SERVER_DETECTOR_HASH @"hash_value"
#define SERVER_DETECTOR_DELETED @"is_deleted"

// ANNOTATED IMAGE
#define SERVER_AIMAGE_IMAGE @"image_jpeg"
#define SERVER_AIMAGE_BOX_X @"box_x"
#define SERVER_AIMAGE_BOX_Y @"box_y"
#define SERVER_AIMAGE_BOX_WIDTH @"box_height"
#define SERVER_AIMAGE_BOX_HEIGHT @"box_width"
#define SERVER_AIMAGE_AUTHOR @"author"
#define SERVER_AIMAGE_DETECTOR @"detector"


// USER DEFAULTS
#define USER_DEFAULTS_USERNAME @"username"
#define USER_DEFAULTS_PASSWORD @"password"
#define USER_DEFAULTS_TOKEN @"token"

#endif


