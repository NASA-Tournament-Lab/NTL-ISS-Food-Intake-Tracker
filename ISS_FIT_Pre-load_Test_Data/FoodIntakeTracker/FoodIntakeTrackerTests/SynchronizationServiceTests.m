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
//  SynchronizationServiceTests.m
//  ISSFoodIntakeTracker
//
//  Created by LokiYang on 2013-08-07.
//

#import "SynchronizationServiceTests.h"
#import "SynchronizationServiceImpl.h"
#import "DataHelper.h"
#import "BaseCommunicationDataService.h"
#import "FoodProductServiceImpl.h"
#import "FoodConsumptionRecordServiceImpl.h"
#import "UserServiceImpl.h"
@implementation SynchronizationServiceTests

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
    self.service = [[SynchronizationServiceImpl alloc] initWithConfiguration:self.configurations];
    
    // build sync hieracby
    NSString* deviceID = [DataHelper getDeviceIdentifier];
    NSError *error = nil;
    id<SMBClient> smbClient = [(SynchronizationServiceImpl*) self.service createSMBClient:&error];
    NSString *otherDeviceID = @"OTHER_DEVICE_ID";
    
    // create sync hierachy and create test data
    [smbClient createDirectory:@"device_registry" error:&error];
    [smbClient writeFile:[NSString stringWithFormat:@"device_registry/%@", deviceID] data:[NSData data] error:&error];
    [smbClient writeFile:[NSString stringWithFormat:@"device_registry/%@", otherDeviceID]
                    data:[NSData data] error:&error];
    
    [smbClient createDirectory:@"data_sync" error:&error];
    [smbClient createDirectory:[NSString stringWithFormat:@"data_sync/%@", deviceID] error:&error];
    [smbClient createDirectory:[NSString stringWithFormat:@"data_sync/%@", otherDeviceID] error:&error];
    NSString *timeStamp = @"1372065251";
    [smbClient createDirectory:[NSString stringWithFormat:@"data_sync/%@/%@", otherDeviceID, timeStamp]
                         error:&error];
    [smbClient createDirectory:[NSString stringWithFormat:@"data_sync/%@/%@/ack", otherDeviceID, timeStamp]
                         error:&error];
    [smbClient createDirectory:[NSString stringWithFormat:@"data_sync/%@/%@/data", otherDeviceID, timeStamp]
                         error:&error];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *localFolder = [bundle pathForResource:@"test_data/samba" ofType:@""];
    localFolder = [localFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"data_sync/%@/%@/data",
                                                               otherDeviceID, timeStamp]];
    NSString *smbFolder = [NSString stringWithFormat:@"data_sync/%@/%@/data", otherDeviceID, timeStamp];
    
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:localFolder error:&error];
    for (NSString *file in files) {
        [self copyLocalFile:[localFolder stringByAppendingPathComponent:file.lastPathComponent]
                  toSMBPath:[smbFolder stringByAppendingPathComponent:file.lastPathComponent] error:&error];
    }
    
    // create data
    [self.managedObjectContext lock];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User"
                                              inManagedObjectContext:self.managedObjectContext];

    User *user1 = [[User alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
    user1.fullName = @"user1";
    user1.deleted = @NO;
    user1.admin = @NO;
    user1.dailyTargetFluid = @100;
    user1.dailyTargetEnergy = @1000;
    user1.dailyTargetSodium = @20;
    user1.synchronized = @NO;
    NSString *faceImages = @"user1.png";
    user1.faceImages = [DataHelper convertNSStringToNSSet:faceImages withEntityDescription:
                        [NSEntityDescription entityForName:@"StringWrapper"
                                    inManagedObjectContext:self.managedObjectContext]
                                   inManagedObjectContext:self.managedObjectContext withSeparator:@";"];
    user1.lastUsedFoodProductFilter = nil;
    user1.useLastUsedFoodProductFilter = @NO;
    user1.maxPacketsPerFoodProductDaily = @2;
    user1.profileImage = @"user1.png";
    NSDate *currentDate = [NSDate dateWithTimeIntervalSince1970:1376229595];
    user1.createdDate = currentDate;
    user1.lastModifiedDate = currentDate;
    [self.managedObjectContext save:&error];
    
    id<FoodProductService> foodService = [[FoodProductServiceImpl alloc] init];
    
    FoodProductFilter *filter = [foodService buildFoodProductFilter:&error];
    
    filter.name = @"test_filter";
    filter.sortOption = [NSNumber numberWithInt:A_TO_Z];
    filter.favoriteWithinTimePeriod = @10;
    filter.origins = [DataHelper convertNSStringToNSSet:@"China" withEntityDescription:
                      [NSEntityDescription entityForName:@"StringWrapper"
                                  inManagedObjectContext:self.managedObjectContext]
                                 inManagedObjectContext:nil withSeparator:@";"];
    
    filter.categories = [DataHelper convertNSStringToNSSet:@"Cookie" withEntityDescription:
                      [NSEntityDescription entityForName:@"StringWrapper"
                                  inManagedObjectContext:self.managedObjectContext]
                                 inManagedObjectContext:nil withSeparator:@";"];
    filter.deleted = @NO;
    [foodService filterFoodProducts:user1 filter:filter error:&error];
    user1.lastModifiedDate = currentDate;

    // create food data
    NSArray *foodData = @[@"food1",@"22255477",@"f1.png",@"USA",@"Food",@"20",@"20",@"20",@"20",@"20",@"20",@"f1.png",
                          @"user1",@"NO",@"2254665584",@"2254665584"];
    AdhocFoodProduct *foodProduct = [DataHelper buildAdhocFoodProductFromData:foodData
                                                       inManagedObjectContext:self.managedObjectContext
                                                                        error:&error];
    
    [foodService addAdhocFoodProduct:user1 product:foodProduct error:&error];
    foodProduct.createdDate = [NSDate dateWithTimeIntervalSince1970:1376229595];
    foodProduct.lastModifiedDate = [NSDate dateWithTimeIntervalSince1970:1376229595];
    
    
    // create food consumption record
    NSArray *foodRecordData = @[@"food1",@"user1",@"2007885226",@"2",@"Two cups of coffee",
                                @"f.png",@"voice2.wav",@"20",@"20",@"20",@"20",@"20",@"20",@"NO",@"2244554444",@"2244554444"];
    FoodConsumptionRecord *record = [DataHelper
                                      buildFoodConsumptionRecordFromData:foodRecordData
                                      inManagedObjectContext:self.managedObjectContext
                                      error:&error];
    id<FoodConsumptionRecordService> consumptionRecordService = [[FoodConsumptionRecordServiceImpl alloc] init];
    [consumptionRecordService addFoodConsumptionRecord:user1 record:record error:&error];
    record.foodProduct = foodProduct;
    record.createdDate = [NSDate dateWithTimeIntervalSince1970:1376229595];
    record.lastModifiedDate = [NSDate dateWithTimeIntervalSince1970:1376229595];
    record.timestamp = [NSDate dateWithTimeIntervalSince1970:2007885226];
    
    // create summary generation history
    SummaryGenerationHistory *history = [NSEntityDescription
                                         insertNewObjectForEntityForName:@"SummaryGenerationHistory"
                                         inManagedObjectContext:[self managedObjectContext]];
    
    history.user = user1;
    history.startDate = [NSDate dateWithTimeIntervalSince1970:1376229595];
    history.endDate = [NSDate dateWithTimeIntervalSince1970:1376230595];
    history.createdDate = [NSDate dateWithTimeIntervalSince1970:1376229595];
    history.lastModifiedDate = [NSDate
                                dateWithTimeIntervalSince1970:1376229595];
    history.synchronized = @NO;
    history.deleted = @NO;
    
    
    [self.managedObjectContext unlock];
    [self.managedObjectContext save:&error];
    
    // create local files
    localFolder = [bundle pathForResource:@"test_data/local" ofType:@""];
    files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:localFolder error:&error];
    NSString *localFileSystemFolder = [DataHelper
                                       getAbsoulteLocalDirectory:self.configurations[@"LocalFileSystemDirectory"]];
    for (NSString *file in files) {
        NSString *destFilePath = [localFileSystemFolder stringByAppendingPathComponent:file.lastPathComponent];
        [[NSFileManager defaultManager] copyItemAtPath:[localFolder stringByAppendingPathComponent:file]
                                                toPath:destFilePath error:&error];
    }
}

/*!
 @discussion Tear down testing environment. It deletes the testing data.
 */
-(void)tearDown {
    NSError *error = nil;
    id<SMBClient> smbClient = [(SynchronizationServiceImpl*) self.service createSMBClient:&error];
    [smbClient deleteDirectory:@"data_sync" error:&error];
    [smbClient deleteDirectory:@"device_registry" error:&error];
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
 @discussuion Test synchronize method
 */
- (void)testSynchronizesynchronize {
    NSError *error = nil;
    BOOL result = [self.service synchronize:&error];
    STAssertTrue(result, @"result should be YES.");
    STAssertNil(error, @"error should be nil.");
    
    
    // check synchronized data
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
    STAssertTrue([user.createdDate timeIntervalSince1970] == 224555466, @"create date is not right.");
    STAssertTrue([user.lastModifiedDate timeIntervalSince1970] == 224555466, @"last modified date is not right.");
    
    // check last used food product filter
    STAssertTrue([user.lastUsedFoodProductFilter.name isEqualToString:@"Black Coffee"], @"filter name is not right");
    STAssertTrue(user.lastUsedFoodProductFilter.origins.count == 2, @"returned filter should have proper value set.");
    NSArray *originComponents = [@"USA;Japan" componentsSeparatedByString:@";"];
    for (StringWrapper *c in user.lastUsedFoodProductFilter.origins) {
        STAssertTrue([originComponents containsObject:c.value], @"The string array should contain the object.");
    }
    STAssertTrue(user.lastUsedFoodProductFilter.categories.count == 1, @"returned filter should have proper value set.");
    NSArray *categoryComponents = [@"Food" componentsSeparatedByString:@";"];
    for (StringWrapper *c in user.lastUsedFoodProductFilter.categories) {
        STAssertTrue([categoryComponents containsObject:c.value], @"The string array should contain the object.");
    }
    STAssertEquals([user.lastUsedFoodProductFilter.favoriteWithinTimePeriod intValue], 7, @"filter is not right");
    STAssertEquals([user.lastUsedFoodProductFilter.sortOption intValue], A_TO_Z, @"filter is not right");
    STAssertEquals([user.useLastUsedFoodProductFilter boolValue], YES, @"user is not right");
    
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
    STAssertTrue([product.barcode isEqualToString: @"22255466"], @"returned product should have proper value set");
    STAssertEquals(product.fluid.intValue, 20, @"returned product should have proper value set");
    STAssertEquals(product.energy.intValue, 20, @"returned product should have proper value set");
    STAssertEquals(product.sodium.intValue, 20, @"returned product should have proper value set");
    
    STAssertTrue(product.images.count == 2, @"returned product should have proper value set.");
    NSArray *productImagecomponents = [@"bc1.png;bc2.png" componentsSeparatedByString:@";"];
    for (StringWrapper *c in product.images) {
        STAssertTrue([productImagecomponents containsObject:c.value], @"The string array should contain the object.");
    }
    
    STAssertTrue([product.createdDate timeIntervalSince1970] == 2254665544, @"create date is not right.");
    STAssertTrue([product.lastModifiedDate timeIntervalSince1970] == 2254665544, @"last modified date is not right.");
    
    // check fetched food comsumption record
    request = [[NSFetchRequest alloc] init];
    predicate = [NSPredicate predicateWithFormat:@"(user.fullName == %@) AND (foodProduct.name == %@) "
                 "AND (timestamp == %@)", @"Joe Norton", @"Black Coffee",
                 [NSDate dateWithTimeIntervalSince1970:2007885226]];
    description = [NSEntityDescription  entityForName:@"FoodConsumptionRecord"
                                                    inManagedObjectContext:self.managedObjectContext];
    [request setEntity:description];
    [request setPredicate:predicate];
    NSArray *records = [self.managedObjectContext executeFetchRequest:request error:&error];
    STAssertNotNil(records, @"records should not be nil.");
    STAssertTrue(records.count == 1, @"records should only contain 1 record.");
    STAssertNil(error, @"error should be nil.");
    FoodConsumptionRecord *record = records[0];
    STAssertTrue([record.foodProduct.name isEqualToString:@"Black Coffee"], @"returned record should have proper value");
    STAssertTrue([record.user.fullName isEqualToString: @"Joe Norton"], @"returned record should have proper value set");
    STAssertTrue(record.timestamp.timeIntervalSince1970 == 2007885226, @"returned record should have proper value set");
    STAssertEquals(record.quantity.intValue, 2, @"returned record should have proper value set");
    STAssertTrue([record.comment isEqualToString:@"Two cups of coffee"], @"returned record should have proper value");
    STAssertEquals(record.fluid.intValue, 20, @"returned record should have proper value set");
    STAssertEquals(record.energy.intValue, 20, @"returned record should have proper value set");
    STAssertEquals(record.sodium.intValue, 20, @"returned record should have proper value set");
    
    STAssertTrue(record.images.count == 1, @"returned record should have proper value set.");
    NSArray *recordImageComponents = [@"bc1.png" componentsSeparatedByString:@";"];
    for (StringWrapper *c in record.images) {
        STAssertTrue([recordImageComponents containsObject:c.value], @"The string array should contain the object.");
    }
    
    STAssertTrue(record.voiceRecordings.count == 1, @"returned record should have proper value set.");
    NSArray *recordVoicesComponents = [@"voice1.wav" componentsSeparatedByString:@";"];
    for (StringWrapper *c in record.voiceRecordings) {
        STAssertTrue([recordVoicesComponents containsObject:c.value], @"The string array should contain the object.");
    }
    
    STAssertTrue([record.createdDate timeIntervalSince1970] == 2244554444, @"create date is not right.");
    STAssertTrue([record.lastModifiedDate timeIntervalSince1970] == 2244554444, @"last modified date is not right.");
    
    // check fetched summary generation history
    request = [[NSFetchRequest alloc] init];
    predicate = [NSPredicate predicateWithFormat:@"(user.fullName == %@) AND "
                 "(startDate == %@) AND (endDate == %@)", @"Joe Norton",
                 [NSDate dateWithTimeIntervalSince1970:224445577545],
                 [NSDate dateWithTimeIntervalSince1970:224445587545]];
    description = [NSEntityDescription entityForName:@"SummaryGenerationHistory"
                              inManagedObjectContext:[self managedObjectContext]];
    [request setEntity:description];
    [request setPredicate:predicate];
    NSArray *histories = [[self managedObjectContext] executeFetchRequest:request error:&error];
    STAssertNotNil(histories, @"histories should not be nil.");
    STAssertTrue(histories.count == 1, @"histories should only contain 1 history.");
    STAssertNil(error, @"error should be nil.");
    SummaryGenerationHistory *history = histories[0];
    STAssertTrue([history.user.fullName isEqualToString: @"Joe Norton"],
                  @"returned history should have proper value");
    STAssertTrue([history.startDate timeIntervalSince1970] == 224445577545,
                 @"returned history should have proper value.");
    STAssertTrue([history.endDate timeIntervalSince1970] == 224445587545,
                 @"returned history should have proper value.");
    
    STAssertTrue([history.createdDate timeIntervalSince1970] == 224445587545,
                 @"create date is not right.");
    STAssertTrue([history.lastModifiedDate timeIntervalSince1970] == 224445587545,
                 @"last modified date is not right.");
    
    // check local file system
    NSArray *localFiles = @[@"bc1.png", @"bc2.png", @"c1.png",@"c2.png",@"joe1.png", @"joe2.png",
                            @"kl1.png", @"kl2.png", @"voice1.wav"];
    for (NSString *localFileName in localFiles) {
        NSString *localDataFile = [[DataHelper
                                    getAbsoulteLocalDirectory:self.configurations[@"LocalFileSystemDirectory"]]
                                   stringByAppendingPathComponent:localFileName];
        STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:localDataFile], @"local file should exist.");
        
    }
    
    // check remote files
    NSArray *remoteFiles = @[@"f.png", @"f1.png", @"user1.png", @"voice2.wav", @"User.csv",
                             @"AdhocFoodProduct.csv", @"FoodConsumptionRecord.csv", @"SummaryGenerationHistory.csv"];
    
    id<SMBClient> smbClient = [(SynchronizationServiceImpl*) self.service createSMBClient:&error];
    NSString* deviceID = [DataHelper getDeviceIdentifier];
    NSArray *folders = [smbClient listDirectories:[NSString stringWithFormat:@"data_sync/%@", deviceID] error:&error];
    STAssertTrue(folders.count == 1, @"remote folder is not right.");
    STAssertNil(error, @"error should be nil.");
    NSArray *files = [smbClient listFiles:[NSString stringWithFormat:@"data_sync/%@/%@/data", deviceID,folders[0]]
                                    error:&error];
    STAssertTrue(files.count == 8, @"remote file is not right.");
    STAssertNil(error, @"error should be nil.");
    for (NSString *remoteFile in files) {
        STAssertTrue([remoteFiles containsObject:remoteFile], @"remote file is not right.");
    }
    
    // check csv files
    
    NSString *userLine = @"\"NO\",\"user1\",\"user1.png\",\"test_filter\",\"China\",\"Cookie\",\"10\",\"2\",\"NO\","
                        "\"100\",\"1000\",\"20\",\"0\",\"0\",\"0\",\"2\",\"user1.png\",\"NO\",\"1376229595\",\"1376229595\"\r\n";
    NSString *foodProductLine= @"\"food1\",\"22255477\",\"f1.png\",\"USA\",\"Food\",\"20\",\"20\",\"20\",\"f1.png\","
                        "\"user1\",\"NO\",\"1376229595\",\"1376229595\"\r\n";
    NSString *foodConsumptionRecordLine = @"\"food1\",\"user1\",\"2007885226\",\"2\",\"Two cups of coffee\",\"f.png\","
                        "\"voice2.wav\",\"20\",\"20\",\"20\",\"NO\",\"1376229595\",\"1376229595\"\r\n";
    NSString *historyLine = @"\"user1\",\"1376229595\",\"1376230595\",\"NO\",\"1376229595\",\"1376229595\"\r\n";
    
    // User.csv
    NSData *userData = [smbClient readFile:[NSString stringWithFormat:@"data_sync/%@/%@/data/User.csv",
                                            deviceID,folders[0]] error:&error];
    STAssertNil(error, @"error should be nil.");
    NSString *userCSVLine = [[NSString alloc] initWithData:userData encoding:NSUTF8StringEncoding];
    STAssertTrue([userCSVLine isEqualToString:userLine], @"User.csv is not right.");
    
    // AdhocFoodProduct.csv
    NSData *foodData = [smbClient readFile:[NSString stringWithFormat:@"data_sync/%@/%@/data/AdhocFoodProduct.csv",
                                            deviceID,folders[0]] error:&error];
    STAssertNil(error, @"error should be nil.");
    NSString *foodCSVLine = [[NSString alloc] initWithData:foodData encoding:NSUTF8StringEncoding];
    STAssertTrue([foodCSVLine isEqualToString:foodProductLine], @"AdhocFoodProduct.csv is not right.");
    
    // FoodConsumptionRecord.csv
    NSData *recordData = [smbClient readFile:[NSString
                                              stringWithFormat:@"data_sync/%@/%@/data/FoodConsumptionRecord.csv",
                                            deviceID,folders[0]] error:&error];
    STAssertNil(error, @"error should be nil.");
    NSString *recordCSVLine = [[NSString alloc] initWithData:recordData encoding:NSUTF8StringEncoding];
    
    STAssertTrue([recordCSVLine isEqualToString:foodConsumptionRecordLine],
                 @"FoodConsumptionRecord.csv is not right.");
    
    // SummaryGenerationHistory.csv
    NSData *historyData = [smbClient readFile:[NSString
                                               stringWithFormat:@"data_sync/%@/%@/data/SummaryGenerationHistory.csv",
                                            deviceID,folders[0]] error:&error];
    STAssertNil(error, @"error should be nil.");
    NSString *historyCSVLine = [[NSString alloc] initWithData:historyData encoding:NSUTF8StringEncoding];
    STAssertTrue([historyCSVLine isEqualToString:historyLine],
                 @"SummaryGenerationHistory.csv is not right.");
    
}

/*!
 @discussuion Test synchronize method on failure case
 */
- (void)testSynchronizesynchronize_Failure_MissingSyncFolder {
    NSError *error = nil;
    id<SMBClient> smbClient = [(SynchronizationServiceImpl*) self.service createSMBClient:&error];
    [smbClient deleteDirectory:@"data_sync" error:&error];
    BOOL result = [self.service synchronize:&error];
    STAssertFalse(result, @"result should be NO.");
    STAssertNotNil(error, @"error should not be nil.");
}

/*!
 @discussuion Test synchronize method on failure case
 */
- (void)testSynchronizesynchronize_Failure_MissingRegistryFolder {
    NSError *error = nil;
    id<SMBClient> smbClient = [(SynchronizationServiceImpl*) self.service createSMBClient:&error];
    [smbClient deleteDirectory:@"device_registry" error:&error];
    BOOL result = [self.service synchronize:&error];
    STAssertFalse(result, @"result should be NO.");
    STAssertNotNil(error, @"error should not be nil.");
}

/*!
 @discussuion Test synchronize method on failure case
 */
- (void)testSynchronizesynchronize_Failure_MissingAckFolder {
    NSError *error = nil;
    id<SMBClient> smbClient = [(SynchronizationServiceImpl*) self.service createSMBClient:&error];
    [smbClient deleteDirectory:@"data_sync/OTHER_DEVICE_ID/1372065251/ack" error:&error];
    BOOL result = [self.service synchronize:&error];
    STAssertFalse(result, @"result should be NO.");
    STAssertNotNil(error, @"error should not be nil.");
}

/*!
 @discussuion Test synchronize method on failure case
 */
- (void)testSynchronizesynchronize_Failure_MissingCSVFile {
    NSError *error = nil;
    id<SMBClient> smbClient = [(SynchronizationServiceImpl*) self.service createSMBClient:&error];
    [smbClient deleteFile:@"data_sync/OTHER_DEVICE_ID/1372065251/data/User.csv" error:&error];
    BOOL result = [self.service synchronize:&error];
    STAssertFalse(result, @"result should be NO.");
    STAssertNotNil(error, @"error should not be nil.");
}

/*!
 @discussuion Test synchronize method on failure case
 */
- (void)testSynchronizesynchronize_Failure_MissingLocalFile {
    NSError *error = nil;
    NSString *localFileSystemFolder = [DataHelper
                                       getAbsoulteLocalDirectory:self.configurations[@"LocalFileSystemDirectory"]];
    [[NSFileManager defaultManager] removeItemAtPath:localFileSystemFolder error:&error];
    BOOL result = [self.service synchronize:&error];
    STAssertFalse(result, @"result should be NO.");
    STAssertNotNil(error, @"error should not be nil.");
}

@end
