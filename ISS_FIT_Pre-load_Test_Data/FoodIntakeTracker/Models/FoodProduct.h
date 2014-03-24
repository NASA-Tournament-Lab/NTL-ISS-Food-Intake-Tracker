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
//  FoodProduct.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 7/13/13.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SynchronizableModel.h"

@class StringWrapper;
@class FoodConsumptionRecord;

//This represents a food product.
@interface FoodProduct : SynchronizableModel

//Indicate if the food product is still active(i.e. available) at ISS. NO means the food product isn't available at ISS anymore but the food product information will still be kept within the app so that crew members are still able to view the information of the food they took before.
@property (nonatomic, strong) NSNumber * active;

//Represents the barcode text of the food product.
@property (nonatomic, strong) NSString * barcode;

//Represents the total kcal of energy contained in the food product per packet.
@property (nonatomic, strong) NSNumber * energy;

//Represents the total liters of fluid contained in the food product per packet.
@property (nonatomic, strong) NSNumber * fluid;

//Represents the name of the food product.
@property (nonatomic, strong) NSString * name;

//Represents the profile image(file path) of the food product which is displayed as the picture in filtering results, etc.
@property (nonatomic, strong) NSString * productProfileImage;

//Represents the total milligram of sodium(Na) contained in the food product per packet.
@property (nonatomic, strong) NSNumber * sodium;

//Represents the total grams of protein contained in the food product per packet.
@property (nonatomic, strong) NSNumber * protein;

//Represents the total grams of carb contained in the food product per packet.
@property (nonatomic, strong) NSNumber * carb;

//Represents the total grams of fat contained in the food product per packet.
@property (nonatomic, strong) NSNumber * fat;

//Represents the category of the food product.
@property (nonatomic, strong) NSString * category;

//Represents the origin of the food product.
@property (nonatomic, strong) NSString * origin;

//Represents the file paths of the food product images.
@property (nonatomic, strong) NSSet *images;

//Represents the quantity
@property (nonatomic, strong) NSNumber *quantity;

@property (nonatomic, retain) NSSet *consumptionRecord;
@end

//Auto generated food product
@interface FoodProduct (CoreDataGeneratedAccessors)

//Add image file name
- (void)addImagesObject:(StringWrapper *)value;

//Remove image file name
- (void)removeImagesObject:(StringWrapper *)value;

//Add image file names
- (void)addImages:(NSSet *)values;

//Remove image file names
- (void)removeImages:(NSSet *)values;

- (void)addConsumptionRecordObject:(FoodConsumptionRecord *)value;
- (void)removeConsumptionRecordObject:(FoodConsumptionRecord *)value;
- (void)addConsumptionRecord:(NSSet *)values;
- (void)removeConsumptionRecord:(NSSet *)values;

@end
