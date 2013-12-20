//
//  Detector+Server.m
//  DetecTube
//
//  Created by Josep Marc Mingot Hidalgo on 17/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "Detector+Server.h"
#import "DetectorFetcher.h"
#import "ConstantsServer.h"
#import "User+Create.h"
#import "NSArray+JSONHelper.m"
#import "AnnotatedImage.h"
#import "SupportVector.h"
#import "NSArray+JSONHelper.h"
#import "Rating.h"

@implementation Detector (Server)

+ (Detector *)detectorWithDictionaryInfo:(NSDictionary *)detectorInfo
                  inManagedObjectContext:(NSManagedObjectContext *)context
{
    Detector *detector;
    
    // look if the detector is already in the database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Detector"];
    request.predicate = [NSPredicate predicateWithFormat:@"serverDatabaseID = %@", [detectorInfo objectForKey:SERVER_DETECTOR_ID]];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if(!matches || matches.count>1){
        // handle error
    }else if (matches.count == 0){
        detector = [NSEntityDescription insertNewObjectForEntityForName:@"Detector" inManagedObjectContext:context];
        NSLog(@"New detector received %@", [detectorInfo objectForKey:SERVER_DETECTOR_NAME]);
        detector.isSent = @(YES);
    }else detector = [matches lastObject];
    
    // general update of the detector
    detector.name = [detectorInfo objectForKey:SERVER_DETECTOR_NAME];
    detector.targetClass = [detectorInfo objectForKey:SERVER_DETECTOR_TARGET_CLASS];
    detector.serverDatabaseID = [detectorInfo objectForKey:SERVER_DETECTOR_ID];
    NSString *authorUsername = [detectorInfo objectForKey:SERVER_DETECTOR_AUTHOR];
    detector.user = [User userWithName:authorUsername inManagedObjectContext:context];
    detector.sizes = [detectorInfo objectForKey:SERVER_DETECTOR_SIZES];
    detector.weights = [detectorInfo objectForKey:SERVER_DETECTOR_WEIGHTS];
    detector.numberRatings = [detectorInfo objectForKey:SERVER_DETECTOR_NUMBER_RATINGS];
    NSNumber *averageRating = [detectorInfo objectForKey:SERVER_DETECTOR_AVERAGE_RATING];
    if(averageRating.integerValue>0) detector.averageRating = averageRating;
    
    detector.parentID = @(0);
    id parentID = [detectorInfo objectForKey:SERVER_DETECTOR_PARENT];
    if ([parentID isKindOfClass:[NSNumber class]]) detector.parentID = parentID;
    
    NSURL *imageURL =[NSURL URLWithString:[NSString stringWithFormat:@"%@media/%@",SERVER_ADDRESS,[detectorInfo objectForKey:SERVER_DETECTOR_IMAGE]]];
    detector.image = [NSData dataWithContentsOfURL:imageURL];
    
    return detector;
}

+ (Detector *) detectorWithDetectorTrainer:(DetectorTrainer *)detectorTrainer
                                  toUpdate:(BOOL) isToUpdate
                    inManagedObjectContext:(NSManagedObjectContext *)context;
{
    
    // 3 possibilities:
    // (1) Create a new detector. POST.
    // (2) Update a detector for which the current user is the owner. PUT.
    // (3) Update the detector of other user. Creates a brand new detector. POST.
    
    Detector *detector = detectorTrainer.previousDetector;
    
    if(!isToUpdate){ // case (1) and (3)
        detector = [NSEntityDescription insertNewObjectForEntityForName:@"Detector" inManagedObjectContext:context];
    }
    
    detector.name = detectorTrainer.name;
    detector.targetClass = detectorTrainer.targetClass;
    User *currentUser = [User getCurrentUserInManagedObjectContext:context];
    detector.user = currentUser;
    detector.parentID = isToUpdate? detector.parentID : detectorTrainer.previousDetector.serverDatabaseID;
    detector.isPublic = [NSNumber numberWithBool:detectorTrainer.isPublic];
    detector.image = UIImageJPEGRepresentation(detectorTrainer.averageImage, 0.5);
    detector.updatedAt = [NSDate date];
    detector.weights = [detectorTrainer.weights convertToJSON];
    detector.sizes = [detectorTrainer.sizes convertToJSON];
    detector.supportVectors = [[SupportVector JSONFromSupportVectors:detectorTrainer.supportVectors] dataUsingEncoding:NSUTF8StringEncoding];
    detector.trainingLog = detectorTrainer.trainingLog;
    
    return detector;
}


+ (void) removePublicDetectorsInManagedObjectContext:(NSManagedObjectContext *)context
{
    // delete all public detectors except those owned by current user
    NSString *currentUsername = [[NSUserDefaults standardUserDefaults] stringForKey:USER_DEFAULTS_USERNAME];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Detector"];
    request.predicate = [NSPredicate predicateWithFormat:@"(isPublic == YES) AND (user.username != %@)",currentUsername];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    for(Detector *publicDetector in matches){
        NSLog(@"detector %@ removed", publicDetector);
        [context deleteObject:publicDetector];
        NSLog(@"overriden detector:");
    }
    
}


@end
