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
//  AdhocFoodProduct.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 7/12/13.
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
