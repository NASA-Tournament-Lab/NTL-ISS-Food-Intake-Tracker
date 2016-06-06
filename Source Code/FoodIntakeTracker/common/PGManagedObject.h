//
//  PGManagedObject.h
//  FoodIntakeTracker
//
//  Created by pvmagacho on 8/7/14.
//  Copyright (c) 2014 topcoder. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <LoopBack/LoopBack.h>

@interface PGManagedObject : NSManagedObject

/*! @description Unique uuid to be shared among devices */
@property (nonatomic, strong, readonly) NSString *id;

- (void)setId:(NSString *)theId;
- (NSDictionary *)getAttributes;
- (BOOL)updateObjects;

@end
