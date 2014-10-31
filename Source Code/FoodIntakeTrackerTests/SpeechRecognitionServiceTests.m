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
//  SpeechRecognitionServiceTests.m
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 2013-07-13.
//

#import "SpeechRecognitionServiceTests.h"
#import "Models.h"

@implementation SpeechRecognitionServiceTests

@synthesize speechRecognitionService;

/*!
 @discussion Set up testing environment. It creates managed object context and populate some testing data.
 */
-(void)setUp {
    [super setUp];
    
    // insert some test data
    [self.managedObjectContext lock];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AdhocFoodProduct"
                                              inManagedObjectContext:self.managedObjectContext];
    AdhocFoodProduct *product1 = [[AdhocFoodProduct alloc] initWithEntity:entity
                                           insertIntoManagedObjectContext:self.managedObjectContext];
    product1.name = @"apple";
    product1.barcode = @"12345";
    product1.origin = @"origin1";
    product1.category = @"category1";
    product1.fluid = @10;
    product1.energy = @20;
    product1.sodium = @5;
    product1.active = @YES;
    product1.deleted = @NO;
    product1.images = [NSMutableSet set];
    product1.productProfileImage = @"product1.png";
    
    AdhocFoodProduct *product2 = [[AdhocFoodProduct alloc] initWithEntity:entity
                                           insertIntoManagedObjectContext:self.managedObjectContext];
    product2.name = @"orange";
    product2.barcode = @"54321";
    product2.origin = @"origin2";
    product2.category = @"category2";
    product2.fluid = @20;
    product2.energy = @30;
    product2.sodium = @10;
    product2.active = @NO;
    product2.deleted = @NO;
    product2.images = [NSMutableSet set];
    product2.productProfileImage = @"product2.png";
    
    NSError *error = nil;
    [self.managedObjectContext save:&error];
    [self.managedObjectContext unlock];
    STAssertNil(error, @"No error should be returned");
    
    speechRecognitionService = [[SpeechRecognitionServiceImpl alloc] initWithConfiguration:self.configurations];
}

/*!
 @discussion Tear down testing environment. It deletes the database file.
 */
-(void)tearDown {
    NSError *error = nil;
    NSURL *storeURL = [[self applicationDocumentsDirectory]
                       URLByAppendingPathComponent:@"ISSFoodIntakeTrackerTest.sqlite"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:storeURL.path]) {
        BOOL result = [fm removeItemAtURL:storeURL error:&error];
        if (!result) {
            NSLog(@"Unresolved error %@, %@", error, [error description]);
            abort();
        }
    }
    [NSThread sleepForTimeInterval:0.1];
    [super tearDown];
}

/*!
 @discussion Test object initialization.
 */
-(void)testInit {
    STAssertNotNil(speechRecognitionService, @"Initialization should succeed");
    STAssertNotNil(speechRecognitionService.managedObjectContext, @"managedObjectContext should be initialized");
}

/*!
 @discussion Test updateFoodProductLanguageModel method.
 */
-(void)testUpdateFoodProductLanguageModel {
    NSError *error = nil;
    [speechRecognitionService updateFoodProductLanguageModel:&error];
    STAssertNil(error, @"No error should be returned");
}

/*!
 @discussion Test getFoodProductLanguageModelPaths method.
 */
-(void)testGetFoodProductLanguageModelPaths {
    NSError *error = nil;
    NSDictionary *paths = [speechRecognitionService getFoodProductLanguageModelPaths:&error];
    STAssertNil(error, @"No error should be returned");
    STAssertNotNil(paths, @"paths should be returned");
}

/*!
 @discussion Test getFoodProductLanguageModelPaths method with invalid lmPath and dicPath
 */
-(void)testGetFoodProductLanguageModelPaths_InvalidLmPath_InvalidDicPath {
    NSError *error = nil;
    NSDictionary *configuration =@{@"GeneralLanguageModelFileName":@"invalid1",
                                   @"FoodProductLanguageModelFileName":@"invalid1"};
    speechRecognitionService = [[SpeechRecognitionServiceImpl alloc] initWithConfiguration:configuration];
    NSDictionary *paths = [speechRecognitionService getFoodProductLanguageModelPaths:&error];
    STAssertNotNil(error, @"error should be returned");
    STAssertNil(paths, @"paths should be nil");
}

/*!
 @discussion Test getGeneralLanguageModelPaths method.
 */
-(void)testGetGeneralLanguageModelPaths {
    NSError *error = nil;
    NSDictionary *paths = [speechRecognitionService getGeneralLanguageModelPaths:&error];
    STAssertNil(error, @"No error should be returned");
    STAssertNotNil(paths, @"paths should be returned");
}

/*!
 @discussion Test getGeneralLanguageModelPaths method with invalid lmPath and dicPath
 */
-(void)testGetGeneralLanguageModelPaths_InvalidLmPath_InvalidDicPath {
    NSError *error = nil;
    NSDictionary *configuration =@{@"GeneralLanguageModelFileName":@"invalid1",
                                   @"FoodProductLanguageModelFileName":@"invalid1"};
    speechRecognitionService = [[SpeechRecognitionServiceImpl alloc] initWithConfiguration:configuration];
    NSDictionary *paths = [speechRecognitionService getGeneralLanguageModelPaths:&error];
    STAssertNotNil(error, @"error should be returned");
    STAssertNil(paths, @"paths should be nil");
}


@end
