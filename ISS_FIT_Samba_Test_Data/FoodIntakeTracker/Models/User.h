// Copyright (c) 2013 TopCoder. All rights reserved.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//
//  User.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 7/12/13.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SynchronizableModel.h"

@class FoodProductFilter, StringWrapper, FoodConsumptionRecord, AdhocFoodProduct;

//This represents a iPad app user.
@interface User : SynchronizableModel

//Indicate if the user is admin user. Default to NO.
@property (nonatomic, strong) NSNumber * admin;

//Represents the daily target energy.
@property (nonatomic, strong) NSNumber * dailyTargetEnergy;

//Represents the daily target fluid.
@property (nonatomic, strong) NSNumber * dailyTargetFluid;

//Represents the daily target sodium.
@property (nonatomic, strong) NSNumber * dailyTargetSodium;

//Represents the daily target protein.
@property (nonatomic, strong) NSNumber * dailyTargetProtein;

//Represents the daily target carb.
@property (nonatomic, strong) NSNumber * dailyTargetCarb;

//Represents the daily target fat.
@property (nonatomic, strong) NSNumber * dailyTargetFat;

//Represents the full name.
@property (nonatomic, strong) NSString * fullName;

//Represents the maximum packets can be selected by user per food per day.
@property (nonatomic, strong) NSNumber * maxPacketsPerFoodProductDaily;

//Represents the profile image(file path) of the user.
@property (nonatomic, strong) NSString * profileImage;

//Indicates whether to use the last used food product filter to initialize the food filter UI.
@property (nonatomic, strong) NSNumber * useLastUsedFoodProductFilter;

//Represents the file paths to the face images.
@property (nonatomic, strong) NSSet *faceImages;

//Represents the last used food product filter.
@property (nonatomic, strong) FoodProductFilter *lastUsedFoodProductFilter;

@property (nonatomic, retain) NSSet *adhocFoodProduct;
@property (nonatomic, retain) NSSet *consumptionRecord;
@end


//Auto generated NSSet methods for faceImages
@interface User (CoreDataGeneratedAccessors)

//Add face image file name
- (void)addFaceImagesObject:(StringWrapper *)value;

//Remove face image file name
- (void)removeFaceImagesObject:(StringWrapper *)value;

//Add set of face image file names
- (void)addFaceImages:(NSSet *)values;

//Remove set of face image file names
- (void)removeFaceImages:(NSSet *)values;

- (void)addAdhocFoodProductObject:(AdhocFoodProduct *)value;
- (void)removeAdhocFoodProductObject:(AdhocFoodProduct *)value;
- (void)addAdhocFoodProduct:(NSSet *)values;
- (void)removeAdhocFoodProduct:(NSSet *)values;

- (void)addConsumptionRecordObject:(FoodConsumptionRecord *)value;
- (void)removeConsumptionRecordObject:(FoodConsumptionRecord *)value;
- (void)addConsumptionRecord:(NSSet *)values;
- (void)removeConsumptionRecord:(NSSet *)values;

@end
