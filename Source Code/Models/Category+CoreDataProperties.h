//
//  Category+CoreDataProperties.h
//  FoodIntakeTracker
//
//  Created by pvmagacho on 6/5/16.
//  Copyright © pvmagacho All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Category.h"

NS_ASSUME_NONNULL_BEGIN

@interface Category (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *value;
@property (nullable, nonatomic, retain) NSSet<FoodProduct *> *foods;

@end

@interface Category (CoreDataGeneratedAccessors)

- (void)addFoodsObject:(FoodProduct *)value;
- (void)removeFoodsObject:(FoodProduct *)value;
- (void)addFoods:(NSSet<FoodProduct *> *)values;
- (void)removeFoods:(NSSet<FoodProduct *> *)values;

@end

NS_ASSUME_NONNULL_END
