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
//  SynchronizableModel.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 7/12/13.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "PGManagedObject.h"

//This is the base class for model classes which can be synchronized between iPad devices.
@interface SynchronizableModel : PGManagedObject

//Indicates whether the model object is removed. Note that this is used to flag the object is deleted and this flag is
//mainly used to instruct SynchronizationService to notify other iPad devices of this deletion. And
//SynchronizationService will physically delete this object from Core Data persistence once it synchronizes this
//deletion to other iPad devices.
@property (nonatomic, strong) NSNumber * removed;

//Indicates whether the changes of the data model have been synchronized. Each time the data is modified, this property will be changed to NO, and once the changes are synchronized to Shared File Server it will be updated to YES.
@property (nonatomic, strong) NSNumber * synchronized;

@property (nonatomic, strong) NSDate * createdDate;

@property (nonatomic, strong) NSDate * modifiedDate;

@end
