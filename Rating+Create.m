//
//  Rating+Create.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 17/10/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "Rating+Create.h"
#import "User+Create.h"


@implementation Rating (Create)

//+ (Rating *) ratingWithRating:(NSNumber *)ratingNumber
//                  forDetector:(Detector *)detector
//       inManagedObjectContext:(NSManagedObjectContext *)context
//{
//    Rating *rating;
//    User *currentUser = [User getCurrentUserInManagedObjectContext:context];
//    
//    
//    // look if the rating is already in the database
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Rating"];
//    request.predicate = [NSPredicate predicateWithFormat:@"user==%@ && detector==%@", currentUser, detector];
//    NSError *error;
//    NSArray *matches = [context executeFetchRequest:request error:&error];
//    
//    if(!matches || matches.count>1){
//        //handle error
//        
//    }else if (matches.count == 0){
//        rating = [NSEntityDescription insertNewObjectForEntityForName:@"Rating" inManagedObjectContext:context];
//        rating.rating = ratingNumber;
//        rating.detector = detector;
//        rating.user = currentUser;
//        
//        
//    }else{
//        rating = [matches lastObject];
//        rating.rating = ratingNumber;
//    }
//    
//    
//    return rating;
//}

+ (Rating *) ratingforDetector:(Detector *)detector
        inManagedObjectContext:(NSManagedObjectContext *)context
{
    Rating *rating;
    User *currentUser = [User getCurrentUserInManagedObjectContext:context];
    
    
    // look if the rating is already in the database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Rating"];
    request.predicate = [NSPredicate predicateWithFormat:@"user==%@ && detector==%@", currentUser, detector];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if(!matches || matches.count>1){
        //handle error
        
    }else if (matches.count == 0){
        rating = [NSEntityDescription insertNewObjectForEntityForName:@"Rating" inManagedObjectContext:context];
        rating.detector = detector;
        rating.user = currentUser;
        
        
    }else{
        rating = [matches lastObject];
    }
    
    
    return rating;
}

@end
