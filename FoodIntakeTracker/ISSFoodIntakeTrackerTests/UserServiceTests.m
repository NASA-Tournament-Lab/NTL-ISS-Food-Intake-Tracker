//
//  UserServiceTests.m
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 2013-07-11.
//  Copyright (c) 2013 TopCoder. All rights reserved.
//

#import "UserServiceTests.h"
#import "LockServiceImpl.h"
#import "BaseCommunicationDataService.h"

@implementation UserServiceTests

@synthesize userService;
@synthesize lockService;
@synthesize smbClient;

/*!
 @discussion Set up testing environment. It creates managed object context and populate some testing data.
 */
-(void)setUp {
    [super setUp];
    
    // insert some test data
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
    user1.faceImages = [NSMutableSet set];
    user1.lastUsedFoodProductFilter = nil;
    user1.useLastUsedFoodProductFilter = @NO;
    user1.maxPacketsPerFoodProductDaily = @2;
    user1.profileImage = @"user1.png";
   
    
    User *user2 = [[User alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
    user2.fullName = @"user2";
    user2.deleted = @NO;
    user2.admin = @YES;
    user2.dailyTargetFluid = @200;
    user2.dailyTargetEnergy = @2000;
    user2.dailyTargetSodium = @50;
    user2.faceImages = [NSMutableSet set];
    user2.lastUsedFoodProductFilter = nil;
    user2.useLastUsedFoodProductFilter = @NO;
    user2.maxPacketsPerFoodProductDaily = @2;
    user2.profileImage = @"user2.png";

    
    NSError *error = nil;
    [self.managedObjectContext save:&error];
    [self.managedObjectContext unlock];
    STAssertNil(error, @"No error should be returned");
    
    lockService = [[LockServiceImpl alloc] initWithManagedObjectContext:self.managedObjectContext
                                                          configuration:self.configurations];
                   
    userService = [[UserServiceImpl alloc] initWithManagedObjectContext:self.managedObjectContext
                                                          configuration:self.configurations lockService:lockService];
    
    BaseCommunicationDataService *baseService = [[BaseCommunicationDataService alloc]
                                                 initWithManagedObjectContext:self.managedObjectContext
                                                 configuration:self.configurations];
    smbClient = [baseService createSMBClient:&error];
    [smbClient createDirectory:@"locks" error:&error];
}

/*!
 @discussion Tear down testing environment. It deletes the database file.
 */
-(void)tearDown {
    NSError *error = nil;
    [smbClient deleteDirectory:@"locks" error:&error];
    [super tearDown];
}

/*!
 @discussion Test object initialization.
 */
-(void)testInit {
    STAssertNotNil(userService, @"Initialization should succeed");
    STAssertNotNil(userService.managedObjectContext, @"managedObjectContext should be initialized");
}

/*!
 @discussion Test buildUser method.
 */
-(void)testBuildUser {
    NSError *error = nil;
    User *user = [userService buildUser:&error];
    STAssertNil(error, @"No error should be returned");
    STAssertNotNil(user, @"User should be created");
    STAssertEqualObjects(user.fullName, @"", @"username should be initialized");
    STAssertEquals(user.admin.boolValue, NO, @"admin should be initialized");
    STAssertEquals(user.dailyTargetFluid.intValue, 0, @"dailyTargetFluid should be initialized");
}


/*!
 @discussion Test filterUsers method.
 */
-(void)testFilterUsers {
    NSError *error = nil;
    NSArray *users = [userService filterUsers:@"user" error:&error];
    STAssertNil(error, @"No error should be returned");
    STAssertEquals(users.count, (NSUInteger)2, @"2 users should be returned");
    
    User *user = users[0];
    if ([user.fullName isEqualToString:@"user1"]) {
        STAssertEquals(user.admin.boolValue, NO, @"returned user should have proper value set");
        STAssertEquals(user.dailyTargetFluid.intValue, 100, @"returned user should have proper value set");
        STAssertEquals(user.dailyTargetEnergy.intValue, 1000, @"returned user should have proper value set");
        STAssertEquals(user.dailyTargetSodium.intValue, 20, @"returned user should have proper value set");
    } else if ([user.fullName isEqualToString:@"user2"]) {
        STAssertEquals(user.admin.boolValue, YES, @"returned user should have proper value set");
        STAssertEquals(user.dailyTargetFluid.intValue, 200, @"returned user should have proper value set");
        STAssertEquals(user.dailyTargetEnergy.intValue, 2000, @"returned user should have proper value set");
        STAssertEquals(user.dailyTargetSodium.intValue, 50, @"returned user should have proper value set");
    } else {
        STFail(@"");
    }
}

/*!
 @discussion Test filterUsers method with invalid input parameters
 */
-(void)testFilterUsers_NilUser {
    NSError *error = nil;
    NSArray *users = [userService filterUsers:nil error:&error];
    STAssertEquals(error.code, IllegalArgumentErrorCode, @"Error code should be illegal argument error code");
    STAssertNil(users, @"users should be nil");
}

/*!
 @discussion Test saveUser method.
 */
-(void)testSaveUser_New {
    NSError *error = nil;
    
    User *user = [userService buildUser:&error];
    STAssertNil(error, @"No error should be returned");
    user.fullName = @"test";
    user.deleted = @NO;
    user.admin = @NO;
    user.dailyTargetFluid = @100;
    user.dailyTargetEnergy = @1000;
    user.dailyTargetSodium = @20;
    user.faceImages = [NSMutableSet set];
    user.lastUsedFoodProductFilter = nil;
    user.useLastUsedFoodProductFilter = @NO;
    user.maxPacketsPerFoodProductDaily = @2;
    user.profileImage = @"user1.png";
    [userService saveUser:user error:&error];
    
    STAssertNil(error, @"No error should be returned");
    NSArray *users = [userService filterUsers:@"test" error:&error];
    STAssertNil(error, @"No error should be returned");
    STAssertEquals(users.count, (NSUInteger)1, @"1 user should be returned");
    STAssertEqualObjects([users[0] fullName], @"test", @"returned user should have proper value set");
}

/*!
 @discussion Test saveUser method.
 */
-(void)testSaveUser_Existing {
    NSError *error = nil;
    
    User *user = [userService buildUser:&error];
    STAssertNil(error, @"No error should be returned");
    
    user.fullName = @"user1";
    user.admin = @YES;
    user.dailyTargetFluid = @500;
    user.deleted = @NO;
    user.dailyTargetEnergy = @1000;
    user.dailyTargetSodium = @20;
    user.faceImages = [NSMutableSet set];
    user.lastUsedFoodProductFilter = nil;
    user.useLastUsedFoodProductFilter = @NO;
    user.maxPacketsPerFoodProductDaily = @2;
    user.profileImage = @"user1.png";
    [userService saveUser:user error:&error];
    STAssertNil(error, @"No error should be returned");
    
    NSArray *users = [userService filterUsers:@"user1" error:&error];
    STAssertNil(error, @"No error should be returned");
    STAssertEquals(users.count, (NSUInteger)1, @"1 user should be returned");
    STAssertEqualObjects([users[0] fullName], @"user1", @"returned user should have proper value set");
    STAssertEqualObjects([users[0] admin], [NSNumber numberWithBool:YES], @"returned user should have proper value set");
    STAssertEquals([users[0] dailyTargetFluid].intValue, 500, @"returned user should have proper value set");
}

/*!
 @discussion Test saveUser method with nil input parameter
 */
-(void)testSaveUser_NilUser {
    NSError *error = nil;
    [userService saveUser:nil error:&error];
    STAssertNotNil(error, @"error should be returned");
}

/*!
 @discussion Test deleteUser method.
 */
-(void)testDeleteUser {
    NSError *error = nil;
    NSArray *users = [userService filterUsers:@"user" error:&error];
    STAssertNil(error, @"No error should be returned");
    STAssertEquals(users.count, (NSUInteger)2, @"2 users should be returned");
    
    [userService deleteUser:users[0] error:&error];
    users = [userService filterUsers:@"user" error:&error];
    STAssertNil(error, @"No error should be returned");
    STAssertEquals(users.count, (NSUInteger)1, @"1 user should be returned");
    STAssertNil(error, @"No error should be returned");
}

/*!
 @discussion Test deleteUser method with nil user
 */
-(void)testDeleteUser_NilUser {
    NSError *error = nil;
    [userService deleteUser:nil error:&error];
    STAssertNotNil(error, @"error should be returned");
}

/*!
 @discussion Test loginUser method.
 */
-(void)testLoginUser_NotFound {
    NSError *error = nil;
    User *user = [userService loginUser:@"nosuchuser" error:&error];
    STAssertNotNil(error, @"error should be returned");
    STAssertEqualObjects(error.domain, @"UserService", @"error should contain correct information");
    STAssertNil(user, @"no user should be returned");
}

/*!
 @discussion Test loginUser method.
 */
-(void)testLoginUser_Found {
    NSError *error = nil;
    User *user = [userService loginUser:@"user1" error:&error];
    STAssertNil(error, @"No error should be returned");
    STAssertNotNil(user, @"user should be returned");
    STAssertEqualObjects(user.fullName, @"user1", @"returned user should have proper value set");
    STAssertEquals(user.dailyTargetFluid.intValue, 100, @"returned user should have proper value set");
    STAssertTrue([lockService acquireLock:user error:&error], @"lock should be acquired");
    [userService logoutUser:user error:&error];
}

/*!
 @discussion Test loginUser method with nil full name
 */
-(void)testLoginUser_NilFullName {
    NSError *error = nil;
    User *user = [userService loginUser:nil error:&error];
    STAssertNotNil(error, @"error should be returned");
    STAssertNil(user, @"user should be nil");
}

/*!
 @discussion Test logoutUser method.
 */
-(void)testLogoutUser {
    NSError *error = nil;
    User *user = [userService loginUser:@"user1" error:&error];
    STAssertNil(error, @"No error should be returned");
    STAssertNotNil(user, @"user should be returned");
    STAssertEqualObjects(user.fullName, @"user1", @"returned user should have proper value set");
    STAssertEquals(user.dailyTargetFluid.intValue, 100, @"returned user should have proper value set");
    STAssertTrue([lockService acquireLock:user error:&error], @"lock should be acquired");
    
    [userService logoutUser:user error:&error];
    STAssertNil(error, @"No error should be returned");
}

/*!
 @discussion Test logoutUser method with nil user
 */
-(void)testLogoutUser_NilUser {
    NSError *error = nil;
    [userService logoutUser:nil error:&error];
    STAssertNotNil(error, @"error should be returned");
}

/*!
 @discussion Test isAuthorized method.
 */
-(void)testIsAuthorized_NonAdmin {
    NSError *error = nil;
    User *user = [userService filterUsers:@"user1" error:&error][0];
    STAssertNil(error, @"No error should be returned");
    
    BOOL authorized = [userService isAuthorized:user action:@"Action1" error:&error];
    STAssertNil(error, @"No error should be returned");
    STAssertTrue(authorized, @"user should be authorized");
    
    authorized = [userService isAuthorized:user action:@"Action2" error:&error];
    STAssertNil(error, @"No error should be returned");
    STAssertFalse(authorized, @"user should not be authorized");
}

/*!
 @discussion Test isAuthorized method.
 */
-(void)testIsAuthorized_Admin {
    NSError *error = nil;
    User *user = [userService filterUsers:@"user2" error:&error][0];
    STAssertNil(error, @"No error should be returned");
    
    BOOL authorized = [userService isAuthorized:user action:@"Action1" error:&error];
    STAssertNil(error, @"No error should be returned");
    STAssertTrue(authorized, @"user should be authorized");
    
    authorized = [userService isAuthorized:user action:@"Action2" error:&error];
    STAssertNil(error, @"No error should be returned");
    STAssertTrue(authorized, @"user should be authorized");
}

/*!
 @discussion Test isAuthorized method with nil user and nil action
 */
-(void)testIsAuthorized_NilUserNilAction {
    NSError *error = nil;
    BOOL authorized = [userService isAuthorized:nil action:nil error:&error];
    STAssertNotNil(error, @"error should be returned");
    STAssertFalse(authorized, @"user should not be authorized");
}

@end
