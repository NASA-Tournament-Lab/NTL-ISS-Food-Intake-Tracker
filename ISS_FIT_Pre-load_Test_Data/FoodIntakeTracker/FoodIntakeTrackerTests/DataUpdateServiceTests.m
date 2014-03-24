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
//  DataUpdateServiceTests.m
//  ISSFoodIntakeTracker
//
//  Created by LokiYang on 8/5/13.
//

#import "DataUpdateServiceTests.h"

#import "DataUpdateServiceImpl.h"

#import "DataHelper.h"

#import "UserServiceImpl.h"



@implementation DataUpdateServiceTests
/*!
 @discussuion Private utility method for copying local file to samba server.
 */
- (BOOL)copyLocalFile:(NSString *)localFile toSMBPath:(NSString *)smbPath error:(NSError **)error {
    NSData *data = [NSData dataWithContentsOfFile:localFile];
    NSError *e = nil;
    id<SMBClient> client = [[[BaseCommunicationDataService alloc] initWithConfiguration:self.configurations]
                            createSMBClient:&e];
    if(e) {
        return NO;
    }
    [client writeFile:smbPath data:data error:&e];
    if(e) {
        return NO;
    }
    else {
        return YES;
    }
}

/*!
 @discussion Set up testing environment. It creates service and some testing data.
 */
- (void)setUp {
    [super setUp];
    self.service = [[DataUpdateServiceImpl alloc] initWithConfiguration:self.configurations];
    NSError *error = nil;
    id<SMBClient> client = [(DataUpdateServiceImpl*)self.service createSMBClient:&error];
    
    [client createDirectory:@"control_files" error:&error];
    [client createDirectory:@"control_files/food_product_inventory" error:&error];
    [client createDirectory:@"control_files/food_product_inventory/ack" error:&error];
    [client createDirectory:@"control_files/food_product_inventory/data" error:&error];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *localFolder = [bundle pathForResource:@"test_data/samba" ofType:@""];
    
    [self copyLocalFile:[localFolder
                         stringByAppendingPathComponent:@"control_files/food_product_inventory/data/bc1.png"]
              toSMBPath:@"control_files/food_product_inventory/data/bc1.png" error:&error];
    [self copyLocalFile:[localFolder
                         stringByAppendingPathComponent:@"control_files/food_product_inventory/data/bc2.png"]
              toSMBPath:@"control_files/food_product_inventory/data/bc2.png" error:&error];
    [self copyLocalFile:[localFolder
                         stringByAppendingPathComponent:@"control_files/food_product_inventory/data/black_coffee.png"]
              toSMBPath:@"control_files/food_product_inventory/data/black_coffee.png" error:&error];
    [self copyLocalFile:[localFolder
                         stringByAppendingPathComponent:@"control_files/food_product_inventory/data/data.csv"]
              toSMBPath:@"control_files/food_product_inventory/data/data.csv" error:&error];
    
    [client createDirectory:@"control_files/user_management" error:&error];
    [client createDirectory:@"control_files/user_management/ack" error:&error];
    [client createDirectory:@"control_files/user_management/data" error:&error];
    
    [self copyLocalFile:[localFolder
                         stringByAppendingPathComponent:@"control_files/user_management/data/joe.png"]
              toSMBPath:@"control_files/user_management/data/joe.png" error:&error];
    [self copyLocalFile:[localFolder
                         stringByAppendingPathComponent:@"control_files/user_management/data/joe1.png"]
              toSMBPath:@"control_files/user_management/data/joe1.png" error:&error];
    [self copyLocalFile:[localFolder
                         stringByAppendingPathComponent:@"control_files/user_management/data/joe2.png"]
              toSMBPath:@"control_files/user_management/data/joe2.png" error:&error];
    [self copyLocalFile:[localFolder
                         stringByAppendingPathComponent:@"control_files/user_management/data/data.csv"]
              toSMBPath:@"control_files/user_management/data/data.csv" error:&error];
    
    NSString* deviceID = [DataHelper getDeviceIdentifier];
    [client createDirectory:@"device_registry" error:&error];
    [client writeFile:[NSString stringWithFormat:@"device_registry/%@", deviceID] data:[NSData data] error:&error];
}

/*!
 @discussion Tear down testing environment. It deletes the testing data.
 */
-(void)tearDown {
    NSError *error = nil;
    id<SMBClient> client = [(DataUpdateServiceImpl*)self.service createSMBClient:&error];
    [client deleteDirectory:@"control_files" error:&error];
    [client deleteDirectory:@"device_registry" error:&error];
    [[NSFileManager defaultManager]
                removeItemAtPath:[DataHelper getAbsoulteLocalDirectory:self.configurations[@"LocalFileSystemDirectory"]]
                        error:&error];
    [super tearDown];
}

/*!
 @discussuion Test initialization method
 */
- (void)testInit {
    //assert service is not nil
    STAssertNotNil(self.service, @"service should not be nil");

}

/*!
 @discussuion Test Update method
 */
- (void)testUpdate {
    NSError *error = nil;
    BOOL result = [self.service update:&error];
    STAssertTrue(result, @"result should be YES.");
    STAssertNil(error, @"error should be nil.");
    
    // check fetched user
    id<UserService> userService = [[UserServiceImpl alloc] initWithConfiguration:self.configurations
                                                                            lockService:nil];
    
    NSArray *users = [userService filterUsers:@"Joe Norton" error:&error];
    STAssertNotNil(users, @"users should not be nil.");
    STAssertTrue(users.count == 1, @"users should only contain 1 user.");
    STAssertNil(error, @"error should be nil.");
    User *user = users[0];
    STAssertEquals(user.admin.boolValue, YES, @"returned user should have proper value set");
    STAssertTrue([user.fullName isEqualToString:@"Joe Norton"], @"returned user should have proper value set");
    STAssertEquals(user.dailyTargetFluid.intValue, 20, @"returned user should have proper value set");
    STAssertEquals(user.dailyTargetEnergy.intValue, 20, @"returned user should have proper value set");
    STAssertEquals(user.dailyTargetSodium.intValue, 20, @"returned user should have proper value set");
    
    STAssertTrue(user.faceImages.count == 2, @"returned user should have proper value set.");
    NSArray *components = [@"joe1.png;joe2.png" componentsSeparatedByString:@";"];
    for (StringWrapper *c in user.faceImages) {
        STAssertTrue([components containsObject:c.value], @"The string array should contain the object.");
    }
    
    // check fetched food product
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name == %@)", @"Black Coffee"];
    NSEntityDescription *description = [NSEntityDescription  entityForName:@"FoodProduct"
                                                    inManagedObjectContext:self.managedObjectContext];
    [request setEntity:description];
    [request setPredicate:predicate];
    NSArray *products = [self.managedObjectContext executeFetchRequest:request error:&error];
    STAssertNotNil(products, @"products should not be nil.");
    STAssertTrue(products.count == 1, @"products should only contain 1 food product.");
    STAssertNil(error, @"error should be nil.");
    FoodProduct *product = products[0];
    STAssertTrue([product.name isEqualToString:@"Black Coffee"], @"returned product should have proper value set");
    STAssertTrue([product.category isEqualToString: @"Beverage"], @"returned product should have proper value set");
    STAssertTrue([product.origin isEqualToString:@"USA" ], @"returned product should have proper value set");
    STAssertTrue([product.barcode isEqualToString: @"11456588"], @"returned product should have proper value set");
    STAssertEquals(product.fluid.intValue, 20, @"returned product should have proper value set");
    STAssertEquals(product.energy.intValue, 20, @"returned product should have proper value set");
    STAssertEquals(product.sodium.intValue, 20, @"returned product should have proper value set");
    
    STAssertTrue(product.images.count == 2, @"returned product should have proper value set.");
    NSArray *productImagecomponents = [@"bc1.png;bc2.png" componentsSeparatedByString:@";"];
    for (StringWrapper *c in product.images) {
        STAssertTrue([productImagecomponents containsObject:c.value], @"The string array should contain the object.");
    }
    
    
    // check data_update directory hierachy
    id<SMBClient> client = [(DataUpdateServiceImpl*)self.service createSMBClient:&error];
    NSArray *folders = [client listDirectories:@"control_files/user_management" error:&error];
    STAssertNotNil(folders, @"result should not be nil.");
    STAssertNil(error, @"error should be nil.");
    STAssertTrue(folders.count == 2, @"should just contains 2 folders");
    for (NSString  *folder in folders) {
        STAssertTrue([(@[@"ack",@"data"]) containsObject:folder], @"The folder name does not match.");
        NSArray *subfolders = [client listDirectories:[NSString stringWithFormat:@"control_files/user_management/%@",
                                                       folder] error:&error];
        STAssertNotNil(subfolders, @"result should not be nil.");
        STAssertNil(error, @"error should be nil.");
        STAssertTrue(subfolders.count == 0, @"should just contains 0 folders");
        
        NSArray *subFiles = [client listFiles:[NSString stringWithFormat:@"control_files/user_management/%@",
                                                       folder] error:&error];
        STAssertNotNil(subFiles, @"result should not be nil.");
        STAssertNil(error, @"error should be nil.");
        STAssertTrue(subFiles.count == 0, @"should just contains 0 files");
    }
    
    folders = [client listDirectories:@"control_files/food_product_inventory" error:&error];
    STAssertNotNil(folders, @"result should not be nil.");
    STAssertNil(error, @"error should be nil.");
    STAssertTrue(folders.count == 2, @"should just contains 2 folders");
    for (NSString  *folder in folders) {
        STAssertTrue([(@[@"ack",@"data"]) containsObject:folder], @"The folder name does not match.");
        NSArray *subfolders = [client listDirectories:[NSString
                                                       stringWithFormat:@"control_files/food_product_inventory/%@",
                                                       folder] error:&error];
        STAssertNotNil(subfolders, @"result should not be nil.");
        STAssertNil(error, @"error should be nil.");
        STAssertTrue(subfolders.count == 0, @"should just contains 0 folders");
        
        NSArray *subFiles = [client listFiles:[NSString stringWithFormat:@"control_files/food_product_inventory/%@",
                                               folder] error:&error];
        STAssertNotNil(subFiles, @"result should not be nil.");
        STAssertNil(error, @"error should be nil.");
        STAssertTrue(subFiles.count == 0, @"should just contains 0 files");
    }
    
    // check local file system
    NSArray *localFiles = @[@"bc1.png", @"bc2.png", @"black_coffee.png", @"joe.png", @"joe1.png", @"joe2.png"];
    for (NSString *localFileName in localFiles) {
        NSString *localDataFile = [[DataHelper
                                    getAbsoulteLocalDirectory:self.configurations[@"LocalFileSystemDirectory"]]
                                   stringByAppendingPathComponent:localFileName];
        STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:localDataFile], @"local file should exist.");
       
    }
    
}

/*!
 @discussuion Test Update method on failure cases
 */
- (void)testUpdate_Failure_MissingControlFolder {
    NSError *error = nil;
    id<SMBClient> client = [(DataUpdateServiceImpl*)self.service createSMBClient:&error];
    [client deleteDirectory:@"control_files" error:&error];
    BOOL result = [self.service update:&error];
    STAssertFalse(result, @"result should be NO.");
    STAssertNotNil(error, @"error should not be nil.");
}

/*!
 @discussuion Test Update method on failure cases
 */
- (void)testUpdate_Failure_MissingFoodFolder{
    NSError *error = nil;
    id<SMBClient> client = [(DataUpdateServiceImpl*)self.service createSMBClient:&error];
    [client deleteDirectory:@"control_files/food_product_inventory" error:&error];
    BOOL result = [self.service update:&error];
    STAssertFalse(result, @"result should be NO.");
    STAssertNotNil(error, @"error should not be nil.");
}

/*!
 @discussuion Test Update method on failure cases
 */
- (void)testUpdate_Failure_MissingUserFolder{
    NSError *error = nil;
    id<SMBClient> client = [(DataUpdateServiceImpl*)self.service createSMBClient:&error];
    [client deleteDirectory:@"control_files/user_management" error:&error];
    BOOL result = [self.service update:&error];
    STAssertFalse(result, @"result should be NO.");
    STAssertNotNil(error, @"error should not be nil.");
}

/*!
 @discussuion Test Update method on failure cases
 */
- (void)testUpdate_Failure_MissingDataFolder{
    NSError *error = nil;
    id<SMBClient> client = [(DataUpdateServiceImpl*)self.service createSMBClient:&error];
    [client deleteDirectory:@"control_files/food_product_inventory/data" error:&error];
    BOOL result = [self.service update:&error];
    STAssertFalse(result, @"result should be NO.");
    STAssertNotNil(error, @"error should not be nil.");
}

/*!
 @discussuion Test Update method on failure cases
 */
- (void)testUpdate_Failure_MissingAckFolder {
    NSError *error = nil;
    id<SMBClient> client = [(DataUpdateServiceImpl*)self.service createSMBClient:&error];
    [client deleteDirectory:@"control_files/user_management/ack" error:&error];
    BOOL result = [self.service update:&error];
    STAssertFalse(result, @"result should be NO.");
    STAssertNotNil(error, @"error should not be nil.");
}

/*!
 @discussuion Test Update method on failure cases
 */
- (void)testUpdate_Failure_MissingDataCSVFile {
    NSError *error = nil;
    id<SMBClient> client = [(DataUpdateServiceImpl*)self.service createSMBClient:&error];
    [client deleteFile:@"control_files/food_product_inventory/data/data.csv" error:&error];
    BOOL result = [self.service update:&error];
    STAssertFalse(result, @"result should be NO.");
    STAssertNotNil(error, @"error should not be nil.");
}
@end
