//
//  Author+Create.m
//  DetecTube
//
//  Created by Josep Marc Mingot Hidalgo on 17/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "Author+Create.h"

@implementation Author (Create)

+ (Author *) authorWithName:(NSString *)name inManagedObjectContext:context
{
    Author *author;
    
    // look if the detector is already in the database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Author"];
    //TODO: look for the actual titles that have get.
    request.predicate = [NSPredicate predicateWithFormat:@"username = %@", name];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if(!matches || matches.count>1){
        //handle error
        
    }else if (matches.count == 0){
        author = [NSEntityDescription insertNewObjectForEntityForName:@"Author" inManagedObjectContext:context];
        author.username = @"Ramon";
        
        
    }else{
        author = [matches lastObject];
    }
    
    
    return author;
}

@end
