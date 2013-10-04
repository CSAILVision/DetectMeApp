//
//  User+Create.h
//  DetecTube
//
//  Created by Josep Marc Mingot Hidalgo on 17/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "User.h"

@interface User (Create)

+ (User *) userWithName:(NSString *)name inManagedObjectContext:context;

@end
