//
//  FoodConsumptionRecordServiceImplTests.m
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 7/12/13.
//  Copyright (c) 2013 tc. All rights reserved.
//

#import "FoodConsumptionRecordServiceImplTests.h"

@implementation FoodConsumptionRecordServiceImplTests

@synthesize smbClient;

//Override setUp method
- (void)setUp
{
    [super setUp];
    self.service = [[FoodConsumptionRecordServiceImpl alloc] initWithManagedObjectContext:self.managedObjectContext
                                                                            configuration:self.configurations];
    self.userService = [[UserServiceImpl alloc] initWithManagedObjectContext:self.managedObjectContext];
    NSError *error = nil;
    BaseCommunicationDataService *baseService = [[BaseCommunicationDataService alloc]
                                                 initWithManagedObjectContext:self.managedObjectContext
                                                 configuration:self.configurations];
    smbClient = [baseService createSMBClient:&error];
    [smbClient createDirectory:@"output_files" error:&error];
}

//Override tearDown method
- (void)tearDown
{
    NSError *error = nil;
    [smbClient deleteDirectory:@"output_files" error:&error];
    [super tearDown];
}

//Test constructor
- (void)testInitObject
{
    NSDictionary *configurations = @{@"FoodConsumptionRecordModifiablePeroidInDays":@7,
    @"FoodConsumptionRecordKeptPeriodInDays":@7};
    self.service = [[FoodConsumptionRecordServiceImpl alloc] initWithManagedObjectContext:self.managedObjectContext
                                                                            configuration:configurations];
    STAssertNotNil(self.service, @"service should not be nil");
}

//Test buildFoodConsumptionRecord
- (void)testBuildFoodConsumptionRecord
{
    NSError *error = nil;
    FoodConsumptionRecord *record= [self.service buildFoodConsumptionRecord:&error];
    STAssertNil(error, @"error should be nil");
    STAssertNotNil(record, @"build a new record");
}

//Test copyFoodConsumptionRecord
- (void)testCopyFoodConsumptionRecord
{
    NSError *error = nil;
    NSDate *now = [NSDate date];
    FoodConsumptionRecord *record= [self.service buildFoodConsumptionRecord:&error];
    record.quantity = @2;
    record.foodProduct = nil;
    record.timestamp = [NSDate date];
    record.comment = nil;
    record.images = [NSMutableSet set];
    record.voiceRecordings = [NSMutableSet set];
    record.fluid = @0;
    record.energy = @0;
    record.sodium = @0;
    record.user = nil;
    record.deleted = @NO;
    FoodConsumptionRecord *copy = [self.service copyFoodConsumptionRecord:record copyToDay:now error:&error];
    STAssertNil(error, @"error should be nil");
    STAssertNotNil(copy, @"copy a record");
    STAssertEquals(copy.quantity, @2, @"should have equal quantity");
    STAssertEqualObjects(copy.foodProduct, nil, @"should be equal");
    STAssertEquals(copy.fluid, @0, @"should be equal");
    STAssertEquals(copy.energy, @0, @"should be equal");
    STAssertEquals(copy.sodium, @0, @"should be equal");
    STAssertEqualObjects(copy.deleted, @NO, @"should be equal");
}

//Test copyFoodConsumptionRecord with nil record and copyToDay
- (void)testCopyFoodConsumptionRecord_NilParameters
{
    NSError *error = nil;
    FoodConsumptionRecord *copy = [self.service copyFoodConsumptionRecord:nil copyToDay:nil error:&error];
    STAssertNotNil(error, @"error should not be nil");
    STAssertNil(copy, @"copy should be nil");
}

//Test addFoodConsumptionRecord
- (void)testAddFoodConsumptionRecord
{
    NSError *error = nil;
    FoodConsumptionRecord *record= [self.service buildFoodConsumptionRecord:&error];
    User *user = [self.userService buildUser:&error];
    [self.service addFoodConsumptionRecord:user record:record error:&error];
    STAssertNil(error, @"error should be nil");
    STAssertEquals(user, record.user, @"should have the same user");
}

//Test addFoodConsumptionRecord with nil parameters
- (void)testAddFoodConsumptionRecord_NilParameters
{
    NSError *error = nil;
    [self.service addFoodConsumptionRecord:nil record:nil error:&error];
    STAssertNotNil(error, @"error should not be nil");
}

//Test saveFoodConsumptionRecord
- (void)testSaveFoodConsumptionRecord
{
    NSError *error = nil;
    FoodConsumptionRecord *record= [self.service buildFoodConsumptionRecord:&error];
    User *user = [self.userService buildUser:&error];
    [self.service addFoodConsumptionRecord:user record:record error:&error];
    [self.service saveFoodConsumptionRecord:record error:&error];
    STAssertNil(error, @"error should be nil");
}

//Test saveFoodConsumptionRecord with nil parameters
- (void)testSaveFoodConsumptionRecord_NilParameters
{
    NSError *error = nil;
    [self.service saveFoodConsumptionRecord:nil error:&error];
    STAssertNotNil(error, @"error should not be nil");
}

//Test deleteFoodConsumptionRecord
- (void)testDeleteFoodConsumptionRecord
{
    NSError *error = nil;
    FoodConsumptionRecord *record= [self.service buildFoodConsumptionRecord:&error];
    User *user = [self.userService buildUser:&error];
    [self.service addFoodConsumptionRecord:user record:record error:&error];
    [self.service deleteFoodConsumptionRecord:record error:&error];
    STAssertNil(error, @"error should be nil");
    STAssertTrue([record.deleted boolValue], @"record should be marked deleted.");
}

//Test deleteFoodConsumptionRecord with nil parameters
- (void)testDeleteFoodConsumptionRecord_NilParameters
{
    NSError *error = nil;
    [self.service deleteFoodConsumptionRecord:nil error:&error];
    STAssertNotNil(error, @"error should not be nil");
}

//Test getFoodConsumptionRecords
- (void)testGetFoodConsumptionRecords
{
    NSError *error = nil;
    FoodConsumptionRecord *record= [self.service buildFoodConsumptionRecord:&error];
    User *user = [self.userService buildUser:&error];
    [self.service addFoodConsumptionRecord:user record:record error:&error];
    [self.service saveFoodConsumptionRecord:record error:&error];
    NSArray *records = [self.service getFoodConsumptionRecords:user date:[NSDate date] error:&error];
    STAssertNil(error, @"error should be nil");
    STAssertTrue([records count] == 1, @"should be only one record found");
}

//Test getFoodConsumptionRecords with nil parameters
- (void)testGetFoodConsumptionRecords_NilParameters
{
    NSError *error = nil;
    NSArray *records = [self.service getFoodConsumptionRecords:nil date:nil error:&error];
    STAssertNotNil(error, @"error should not be nil");
    STAssertNil(records, @"records should be nil");
}

//Test expireFoodConsumptionRecords method
- (void)testExpireFoodConsumptionRecords
{
    NSError *error = nil;
    FoodConsumptionRecord *record= [self.service buildFoodConsumptionRecord:&error];
    User *user = [self.userService buildUser:&error];
 
    [self.service addFoodConsumptionRecord:user record:record error:&error];
    
    //make it created date two days before for testing
    record.createdDate = [NSDate
                          dateWithTimeIntervalSinceNow:-2*[self.service.recordKeptPeriodInDays intValue]*24*60*60];
    [[self managedObjectContext] save:&error];
    
    [self.service expireFoodConsumptionRecords:&error];
    STAssertNil(error, @"error should be nil");
}

//Test genreateSummary method
- (void)testGenerateSummary
{
    NSError *error = nil;
    FoodConsumptionRecord *record= [self.service buildFoodConsumptionRecord:&error];
    User *user = [self.userService buildUser:&error];
 
    [self.service addFoodConsumptionRecord:user record:record error:&error];
    [self.service generateSummary:user
                        startDate:[NSDate dateWithTimeIntervalSinceNow:-60*60*24]
                          endDate:[NSDate date]
                            error:&error];
    STAssertNil(error, @"error should be nil");
    
    //check summary history count, it should be 1
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"SummaryGenerationHistory"
                                                   inManagedObjectContext:[self managedObjectContext]];
    [request setEntity:description];
    NSArray *result = [[self managedObjectContext] executeFetchRequest:request error:&error];
    STAssertNil(error, @"error should be nil");
    STAssertTrue([result count] == 1, @"one summary generation history is persisted");
}

//Test genreateSummary method with nil parameters
- (void)testGenerateSummary_NilParameters
{
    NSError *error = nil;
    [self.service generateSummary:nil
                        startDate:nil
                          endDate:nil
                            error:&error];
    STAssertNotNil(error, @"error should not be nil");
}


@end
