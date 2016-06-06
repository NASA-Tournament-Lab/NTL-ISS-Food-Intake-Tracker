//
//  Origin+CoreDataProperties.h
//  FoodIntakeTracker
//
//  Created by PAULO VITOR MAGACHO DA SILVA on 6/5/16.
//  Copyright © 2016 topcoder. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Origin.h"

NS_ASSUME_NONNULL_BEGIN

@interface Origin (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *value;

@end

NS_ASSUME_NONNULL_END
