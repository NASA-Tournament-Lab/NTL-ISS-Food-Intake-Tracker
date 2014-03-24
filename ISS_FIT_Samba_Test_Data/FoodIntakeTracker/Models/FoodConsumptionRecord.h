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
//  FoodConsumptionRecord.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 7/12/13.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SynchronizableModel.h"

@class FoodProduct, StringWrapper, User;

//Represents the food consumption record.
@interface FoodConsumptionRecord : SynchronizableModel

//Represents iPad user comment.
@property (nonatomic, strong) NSString * comment;

//Represents the total consumed energy.
@property (nonatomic, strong) NSNumber * energy;

//Represents the total consumed fluid.
@property (nonatomic, strong) NSNumber * fluid;

//Represents the quantity.
@property (nonatomic, strong) NSNumber * quantity;

//Represents the total consumed sodium.
@property (nonatomic, strong) NSNumber * sodium;

//Represents the total consumed protein.
@property (nonatomic, strong) NSNumber * protein;

//Represents the total consumed carb.
@property (nonatomic, strong) NSNumber * carb;

//Represents the total consumed fat.
@property (nonatomic, strong) NSNumber * fat;

//Represents the record timestamp.
@property (nonatomic, strong) NSDate * timestamp;

//Represents the food product.
@property (nonatomic, strong) FoodProduct *foodProduct;

//Represents the file paths to the images associated with the record.
@property (nonatomic, strong) NSSet *images;

//Represents the user of the record.
@property (nonatomic, strong) User *user;

//Represents the file paths to the voice recordings associated with the record.
@property (nonatomic, strong) NSSet *voiceRecordings;

//Represents whether this record is ad-hoc only or not
@property (nonatomic, strong) NSNumber * adhocOnly;
@end

//Auto generated NSSet methods for images and voice recordings.
@interface FoodConsumptionRecord (CoreDataGeneratedAccessors)

//Add image file name
- (void)addImagesObject:(StringWrapper *)value;

//Remove image file name
- (void)removeImagesObject:(StringWrapper *)value;

//Add set of image file names
- (void)addImages:(NSSet *)values;

//Remove set of image file names
- (void)removeImages:(NSSet *)values;


//Add voice recording file name
- (void)addVoiceRecordingsObject:(StringWrapper *)value;

//Remove voice recording file name
- (void)removeVoiceRecordingsObject:(StringWrapper *)value;

//Add set of voice recording file names
- (void)addVoiceRecordings:(NSSet *)values;

//Remove set of voice recording file names
- (void)removeVoiceRecordings:(NSSet *)values;

@end
