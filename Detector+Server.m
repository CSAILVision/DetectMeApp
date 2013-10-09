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

@implementation Detector (Server)

+ (Detector *)detectorWithDictionaryInfo:(NSDictionary *)detectorInfo inManagedObjectContext:(NSManagedObjectContext *)context
{
    Detector *detector;
    
    // look if the detector is already in the database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Detector"];
    request.predicate = [NSPredicate predicateWithFormat:@"serverDatabaseID = %@", [detectorInfo objectForKey:SERVER_DETECTOR_ID]];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if(!matches || matches.count>1){
        
    }else if (matches.count == 0){
        detector = [NSEntityDescription insertNewObjectForEntityForName:@"Detector" inManagedObjectContext:context];
        detector.name = [detectorInfo objectForKey:SERVER_DETECTOR_NAME];
        detector.targetClass = [detectorInfo objectForKey:SERVER_DETECTOR_TARGET_CLASS];
        detector.serverDatabaseID = [detectorInfo objectForKey:SERVER_DETECTOR_ID];
        NSString *authorUsername = [detectorInfo objectForKey:SERVER_DETECTOR_AUTHOR];
        detector.user = [User userWithName:authorUsername inManagedObjectContext:context];
        detector.sizes = [detectorInfo objectForKey:SERVER_DETECTOR_SIZES];
        detector.weights = [detectorInfo objectForKey:SERVER_DETECTOR_WEIGHTS];
        detector.supportVectors = [detectorInfo objectForKey:SERVER_DETECTOR_SUPPORT_VECTORS];
        detector.parentID = @(0);
        id parentID = [detectorInfo objectForKey:SERVER_DETECTOR_PARENT];
        if ([parentID isKindOfClass:[NSNumber class]]) detector.parentID = parentID;
    
        NSLog(@"parent id: %@", detector.parentID);
        
        NSURL *imageURL =[NSURL URLWithString:[NSString stringWithFormat:@"%@media/%@",SERVER_ADDRESS,[detectorInfo objectForKey:SERVER_DETECTOR_IMAGE]]];
        detector.image = [NSData dataWithContentsOfURL:imageURL];
        
        
    }else detector = [matches lastObject];
    
    return detector;
}

+ (void) removePublicDetectorsInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Detector"];
    request.predicate = [NSPredicate predicateWithFormat:@"isPublic = YES"];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    for(Detector *publicDetector in matches)
        [context deleteObject:publicDetector];
    
}


@end
