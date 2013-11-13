//
//  User+Create.m
//  DetecTube
//
//  Created by Josep Marc Mingot Hidalgo on 17/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "User+Create.h"
#import "ConstantsServer.h"
#import "MultipleDetector.h"

@implementation User (Create)

+ (User *) userWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context
{
    User *user;
    
    // look if the detector is already in the database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    //TODO: look for the actual titles that have get.
    request.predicate = [NSPredicate predicateWithFormat:@"username = %@", name];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if(!matches || matches.count>1){
        //handle error
        NSLog(@"error!!");
        NSLog(@"username: %@", name);
        
    }else if (matches.count == 0){
        NSLog(@"Creating user:%@", name);
        user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
        user.username = name;
        
        
    }else{
        user = [matches lastObject];
    }
    
    
    return user;
}


+ (User *) getCurrentUserInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSString *currentUsername = [[NSUserDefaults standardUserDefaults] stringForKey:USER_DEFAULTS_USERNAME];
    return [User userWithName:currentUsername inManagedObjectContext:context];
}



@end
