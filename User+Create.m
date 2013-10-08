//
//  User+Create.m
//  DetecTube
//
//  Created by Josep Marc Mingot Hidalgo on 17/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "User+Create.h"
#import "ConstantsServer.h"

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
        
    }else if (matches.count == 0){
        user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
        user.username = name;
        
        
    }else{
        user = [matches lastObject];
    }
    
    
    return user;
}


+ (User *) getCurrentUserInManagedObjectContext:(NSManagedObjectContext *)context
{
    User *user;
    NSString *currentUsername = [[NSUserDefaults standardUserDefaults] stringForKey:USER_DEFAULTS_USERNAME];
    
    // look if the detector is already in the database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    //TODO: look for the actual titles that have get.
    request.predicate = [NSPredicate predicateWithFormat:@"username = %@", currentUsername];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if(matches.count==1){
        user = (User *) [matches firstObject];
        
    }else{
        //handle error
    }
    
    return user;
}

@end
