//
//  BaseTests.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 7/11/13.
//  Copyright (c) 2013 tc. All rights reserved.
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
