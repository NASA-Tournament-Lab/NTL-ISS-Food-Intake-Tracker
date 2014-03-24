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
//  BaseTests.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 7/11/13.
//

#import <SenTestingKit/SenTestingKit.h>

/**
 Base class to manage Core Data model and persistence. Its subclass simply use 'managedObjectContext' to test.
 The base class ensure that there is clean sqlite database file for each unit test case
 */
@interface BaseTests : SenTestCase

//Represents runtime managed object context
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

//Represents managed object model in design time
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

//Represents store coordinator, sqlite is current choice.
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//Represents configurations dictionary.
@property (nonatomic, strong) NSMutableDictionary *configurations;

//Help method to save managed object context
- (void)saveContext;

//URL of application document directory.
- (NSURL *)applicationDocumentsDirectory;
@end
