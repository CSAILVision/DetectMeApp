//
//  User+Create.h
//  DetecTube
//
//  Created by Josep Marc Mingot Hidalgo on 17/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "User.h"

@interface User (Create)

// creates a new user if it does not exist given the username
// called when creating users for downloaded detectors
+ (User *) userWithName:(NSString *)username
 inManagedObjectContext:(NSManagedObjectContext *)context;

// creates a new user if it does not exists given the server info (json dict)
// called for the sign in
+ (User *)userWithDictionaryInfo:(NSDictionary *)userInfo
          inManagedObjectContext:(NSManagedObjectContext *)context;

+ (User *) getCurrentUserInManagedObjectContext:(NSManagedObjectContext *)context;

@end
