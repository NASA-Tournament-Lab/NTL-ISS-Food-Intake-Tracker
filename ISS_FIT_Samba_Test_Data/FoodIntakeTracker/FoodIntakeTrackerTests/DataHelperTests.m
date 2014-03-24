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
//  DataHelperTests.m
//  ISSFoodIntakeTracker
//
//  Created by LokiYang on 2013-08-07.
//

#import "DataHelperTests.h"
#import "DataHelper.h"

@implementation DataHelperTests

/*!
 @discussion Set up testing environment.
 */
- (void)setUp {
    [super setUp];
}

/*!
 @discussion Tear down testing environment.
 */
-(void)tearDown {
    [super tearDown];
}

/*!
 @discussion Test getDeviceIdentifier method.
 */
- (void)testGetDeviceIdentifier {
    NSString *id1 = [DataHelper getDeviceIdentifier];
    NSString *id2 = [DataHelper getDeviceIdentifier];
    STAssertEqualObjects(id1, id2, @"result should be the same.");
    STAssertNotNil(id1, @"result should not be nil.");
    STAssertNotNil(id2, @"result should not be nil.");
}

/*!
 @discussion Test getAbsoulteLocalDirectory method.
 */
- (void)testGetAbsoulteLocalDirectory {
    NSString *id1 = [DataHelper getAbsoulteLocalDirectory:@"local"];
    NSString *id2 = [DataHelper getAbsoulteLocalDirectory:@"local"];
    NSString *id3 = [DataHelper getAbsoulteLocalDirectory:@"local3"];
    STAssertEqualObjects(id1, id2, @"result should be the same.");
    STAssertFalse([id1 isEqualToString:id3], @"result should not be the same.");
    STAssertNotNil(id1, @"result should not be nil.");
    STAssertNotNil(id2, @"result should not be nil.");
    STAssertNotNil(id3, @"result should not be nil.");
}

/*!
 @discussion Test convertNSStringToNSSet method.
 */
- (void)testConvertNSStringToNSSet {
    NSString *string = @"1;2;3";
    NSArray *components = [string componentsSeparatedByString:@";"];
    NSSet *result = [DataHelper convertNSStringToNSSet:string withEntityDescription:
                     [NSEntityDescription entityForName:@"StringWrapper"
                                 inManagedObjectContext:self.managedObjectContext]
                                inManagedObjectContext:self.managedObjectContext withSeparator:@";"];
    for (StringWrapper *c in result) {
        STAssertTrue([components containsObject:c.value], @"The string array should contain the object.");
    }
    STAssertTrue(result.count==3, @"The NSSet should have exactly 3 elements");
}

/*!
 @discussion Test buildUserFromData method.
 */
- (void)testBuildUserFromData {
    NSArray *data = @[@"NO",@"Kevin Lee",@"kl1.png;kl2.png",@"Chicken",@"USA",@"Food",@"7",
                      @"Z_TO_A",@"NO",@"30",@"20",@"20",@"30",@"20",@"20",@"5",@"kl1.png",@"YES",@"224555476",@"224555476"];
    NSError *error = nil;
    User *user = [DataHelper buildUserFromData:data inManagedObjectContext:self.managedObjectContext error:&error];
    STAssertNotNil(user, @"user should not be nil.");
    STAssertNil(error, @"error should be nil.");
    
    STAssertEquals(user.admin.boolValue, NO, @"returned user should have proper value set");
    STAssertEquals(user.fullName, @"Kevin Lee", @"returned user should have proper value set");
    STAssertEquals(user.dailyTargetFluid.intValue, 30, @"returned user should have proper value set");
    STAssertEquals(user.dailyTargetEnergy.intValue, 20, @"returned user should have proper value set");
    STAssertEquals(user.dailyTargetSodium.intValue, 20, @"returned user should have proper value set");

}

/*!
 @discussion Test buildFoodConsumptionRecordFromData method.
 */
- (void)testBuildFoodConsumptionRecordFromData {
    NSArray *data = @[@"Black Coffee",@"Joe Norton",@"2007885226",@"2",@"Two cups of coffee",@"bc1.png",@"voice1.wav",
                      @"20",@"20",@"20",@"20",@"20",@"20",@"NO",@"2244554444",@"2244554444"];
    NSError *error = nil;
    FoodConsumptionRecord *record = [DataHelper buildFoodConsumptionRecordFromData:data
                                                            inManagedObjectContext:self.managedObjectContext
                                                                             error:&error];
    STAssertNotNil(record, @"record should not be nil.");
    STAssertNil(error, @"error should be nil.");
    
    STAssertEquals(record.quantity.intValue, 2, @"should have equal quantity");
    STAssertEquals([record.fluid integerValue], 20, @"should be equal");
    STAssertEquals([record.energy integerValue], 20, @"should be equal");
    STAssertEquals([record.sodium integerValue], 20, @"should be equal");
    STAssertEquals(record.comment, @"Two cups of coffee", @"should have equal");
    STAssertEqualObjects(record.deleted, @NO, @"should be equal");

}

/*!
 @discussion Test buildAdhocFoodProductFromData method.
 */
- (void)testBuildAdhocFoodProductFromData {
    
    NSArray *data = @[@"Chicken",@"22255477",@"c1.png;c2.png",@"USA",@"Food",@"20",@"20",@"20",@"20",@"20",@"20",@"c1.png",@"Joe Norton",
                      @"NO",@"2254665584",@"2254665584"];
    NSError *error = nil;
    AdhocFoodProduct *product = [DataHelper buildAdhocFoodProductFromData:data
                                                            inManagedObjectContext:self.managedObjectContext
                                                                    error:&error];
    STAssertNotNil(product, @"product should not be nil.");
    STAssertNil(error, @"error should be nil.");
    
    STAssertEqualObjects(product.name, @"Chicken", @"name should be the same.");
    STAssertEqualObjects(product.barcode, @"22255477", @"barcode should be the same.");
    STAssertEquals([product.fluid integerValue], 20, @"fluid should be equal");
    STAssertEquals([product.energy integerValue], 20, @"energy should be equal");
    STAssertEquals([product.sodium integerValue], 20, @"sodium should be equal");

}

@end
