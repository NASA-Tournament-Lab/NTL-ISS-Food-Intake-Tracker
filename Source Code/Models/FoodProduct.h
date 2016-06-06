//
//  FoodProduct.h
//  FoodIntakeTracker
//
//  Created by PAULO VITOR MAGACHO DA SILVA on 6/5/16.
//  Copyright © 2016 topcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynchronizableModel.h"

@class Category, FoodConsumptionRecord, Media, Origin;

NS_ASSUME_NONNULL_BEGIN

@interface FoodProduct : SynchronizableModel

@property (nullable, nonatomic, retain) NSNumber *active;
@property (nullable, nonatomic, retain) NSString *barcode;
@property (nullable, nonatomic, retain) NSNumber *carb;
@property (nullable, nonatomic, retain) NSNumber *energy;
@property (nullable, nonatomic, retain) NSNumber *fat;
@property (nullable, nonatomic, retain) NSNumber *fluid;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *protein;
@property (nullable, nonatomic, retain) NSNumber *quantity;
@property (nullable, nonatomic, retain) NSNumber *sodium;
@property (nullable, nonatomic, retain) NSSet<FoodConsumptionRecord *> *consumptionRecord;
@property (nullable, nonatomic, retain) Media *foodImage;
@property (nullable, nonatomic, retain) NSSet<Media *> *images;
@property (nullable, nonatomic, retain) Origin *origin;
@property (nullable, nonatomic, retain) NSSet<Category *> *categories;

@end

NS_ASSUME_NONNULL_END

#import "FoodProduct+CoreDataProperties.h"
