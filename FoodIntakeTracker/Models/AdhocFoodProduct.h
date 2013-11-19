//
//  AdhocFoodProduct.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 7/12/13.
//  Copyright (c) 2013 tc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FoodProduct.h"

@class User;

//Represents an ad-hoc food product. Ad-hoc food product will be stored per user.
@interface AdhocFoodProduct : FoodProduct

//Represents the user associated with this adhoc food product
@property (nonatomic, strong) User *user;

@end
