//
//  PGManagedObject.h
//  FoodIntakeTracker
//
//  Created by pvmagacho on 8/7/14.
//  Copyright (c) 2014 topcoder. All rights reserved.
//

#import <CoreData/CoreData.h>

@class PGConnection;

@interface PGManagedObject : NSManagedObject

/*! @description Unique uuid to be shared among devices */
@property (nonatomic, strong) NSString *uuid;

- (BOOL)updateObjects:(PGConnection *) pgConnection;
- (BOOL)insertObjects:(PGConnection *) pgConnection;

@end
