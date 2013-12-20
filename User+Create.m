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
        
        
    }else user = [matches lastObject];
    
    
    return user;
}

+ (User *)userWithDictionaryInfo:(NSDictionary *)userInfo
          inManagedObjectContext:(NSManagedObjectContext *)context
{
    User *user;
    
    NSString *username = [userInfo objectForKey:SERVER_PROFILE_USERNAME];
    NSString *mugshot = [userInfo objectForKey:SERVER_PROFILE_IMAGE];
    NSString *imageURL = [NSString stringWithFormat:@"%@media/%@",SERVER_ADDRESS,mugshot];
    
    // look if the user is already in the database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"username = %@", username];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if(!matches || matches.count>1){
        //error!
        
    }else if (matches.count == 0){
        NSLog(@"Creating user:%@", username);
        user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
        user.username = username;
        user.image = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
        
        
    }else{ //update user info
        user = [matches lastObject];
        user.image = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
    }
    
    
    return user;
}


+ (User *) getCurrentUserInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSString *currentUsername = [[NSUserDefaults standardUserDefaults] stringForKey:USER_DEFAULTS_USERNAME];
    return [User userWithName:currentUsername inManagedObjectContext:context];
}



@end
