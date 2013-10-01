//
//  Detector+Server.m
//  DetecTube
//
//  Created by Josep Marc Mingot Hidalgo on 17/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "Detector+Server.h"
#import "Author+Create.h"
#import "DetectorFetcher.h"
#import "ConstantsServer.h"

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
        detector.serverDatabaseID = [detectorInfo objectForKey:SERVER_DETECTOR_ID];
        detector.author = [Author authorWithName:@"Ramon" inManagedObjectContext:context];
        
        NSURL *imageURL =[NSURL URLWithString:[NSString stringWithFormat:@"%@media/%@",SERVER_ADDRESS,[detectorInfo objectForKey:SERVER_DETECTOR_IMAGE]]];
        detector.image = [NSData dataWithContentsOfURL:imageURL];
        
        
    }else{
        detector = [matches lastObject];
    }
    

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
