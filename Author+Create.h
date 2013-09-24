//
//  Author+Create.h
//  DetecTube
//
//  Created by Josep Marc Mingot Hidalgo on 17/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "Author.h"

@interface Author (Create)

+ (Author *) authorWithName:(NSString *)name inManagedObjectContext:context;

@end
