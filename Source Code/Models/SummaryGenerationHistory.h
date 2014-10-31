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
//  SummaryGenerationHistory.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 7/12/13.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SynchronizableModel.h"

@class User;

//This represents a FoodConsumptionRecord summary generation history record.
@interface SummaryGenerationHistory : SynchronizableModel

//Represents the end date of the summary.
@property (nonatomic, strong) NSDate * endDate;

//Represents the start date of the summary.
@property (nonatomic, strong) NSDate * startDate;

//Represents the user for whom the summary was generated.
@property (nonatomic, strong) User *user;

@end
