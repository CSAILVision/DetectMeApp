//
//  Detector+Server.h
//  DetecTube
//
//  Created by Josep Marc Mingot Hidalgo on 17/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "Detector.h"
#import "DetectorTrainer.h"

@interface Detector (Server)

+ (Detector *)detectorWithDictionaryInfo:(NSDictionary *)detectorInfo
                  inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Detector *) detectorWithDetectorTrainer:(DetectorTrainer *)detectorTrainer
                                  toUpdate:(BOOL) isToUpdate
                    inManagedObjectContext:(NSManagedObjectContext *)context;

// Used to update the DB. First all public detectors are removed
+ (void) removePublicDetectorsInManagedObjectContext:(NSManagedObjectContext *)context;

@end
