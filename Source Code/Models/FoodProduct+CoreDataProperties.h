//
//  FoodProduct+CoreDataProperties.h
//  FoodIntakeTracker
//
//  Created by PAULO VITOR MAGACHO DA SILVA on 6/5/16.
//  Copyright © 2016 topcoder. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FoodProduct.h"

NS_ASSUME_NONNULL_BEGIN

@interface FoodProduct (CoreDataProperties)

@end

@interface FoodProduct (CoreDataGeneratedAccessors)

- (void)addConsumptionRecordObject:(FoodConsumptionRecord *)value;
- (void)removeConsumptionRecordObject:(FoodConsumptionRecord *)value;
- (void)addConsumptionRecord:(NSSet<FoodConsumptionRecord *> *)values;
- (void)removeConsumptionRecord:(NSSet<FoodConsumptionRecord *> *)values;

- (void)addImagesObject:(Media *)value;
- (void)removeImagesObject:(Media *)value;
- (void)addImages:(NSSet<Media *> *)values;
- (void)removeImages:(NSSet<Media *> *)values;

- (void)addCategoriesObject:(Category *)value;
- (void)removeCategoriesObject:(Category *)value;
- (void)addCategories:(NSSet<Category *> *)values;
- (void)removeCategories:(NSSet<Category *> *)values;

@end

NS_ASSUME_NONNULL_END
