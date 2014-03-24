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
//  LockServiceTests.m
//  ISSFoodIntakeTracker
//
//  Created by LokiYang on 2013-08-07.
//

#import "LockServiceTests.h"
#import "LockServiceImpl.h"
#import "UserServiceImpl.h"
#import "User.h"

@implementation LockServiceTests
/*!
 @discussion Set up testing environment. It creates service.
 */
- (void)setUp {
    [super setUp];
    self.service = [[LockServiceImpl alloc] initWithConfiguration:self.configurations];
    NSError *error = nil;
    id<SMBClient> client = [(LockServiceImpl*)self.service createSMBClient:&error];
    [client createDirectory:@"locks" error:&error];


}

/*!
 @discussion Tear down testing environment. It deletes the testing data.
 */
- (void)tearDown {
    NSError *error = nil;
    id<SMBClient> client = [(LockServiceImpl*)self.service createSMBClient:&error];
    [client deleteDirectory:@"locks" error:&error];
    [super tearDown];
}

/*!
 @discussuion Test AcquireLock method
 */
- (void)testAcquireLock {
    id<UserService> userService = [[UserServiceImpl alloc] initWithConfiguration:self.configurations
                                                                     lockService:self.service];
    
    NSError *error = nil;
    User *user = [userService buildUser:&error];
    user.fullName = @"test_user";
    BOOL result = [self.service acquireLock:user error:&error];
    STAssertTrue(result, @"result should be YES.");
    STAssertNil(error, @"error should be nil.");
}


/*!
 @discussuion Test AcquireLock method with Login in other device
 */
- (void)testAcquireLockWithLoginInOtherDevice {
    id<UserService> userService = [[UserServiceImpl alloc] initWithConfiguration:self.configurations
                                                                     lockService:self.service];
    
    NSError *error = nil;
    User *user = [userService buildUser:&error];
    user.fullName = @"test_user";
    id<SMBClient> client = [(LockServiceImpl*)self.service createSMBClient:&error];
    NSString* timestamp = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
    NSData *data = [timestamp dataUsingEncoding:NSUTF8StringEncoding];
    [client writeFile:@"locks/test_user_otherdeviceid" data:data error:&error];
    BOOL result = [self.service acquireLock:user error:&error];
    STAssertTrue(result, @"result should be YES.");
    STAssertNil(error, @"error should be nil.");
}

/*!
 @discussuion Test AcquireLock method with multiple times
 */
- (void)testAcquireLock_MultipleTimes {
    id<UserService> userService = [[UserServiceImpl alloc] initWithConfiguration:self.configurations
                                                                     lockService:self.service];
    
    NSError *error = nil;
    User *user = [userService buildUser:&error];
    user.fullName = @"test_user";
    BOOL result = [self.service acquireLock:user error:&error];
    STAssertTrue(result, @"result should be YES.");
    STAssertNil(error, @"error should be nil.");
    
    result = [self.service acquireLock:user error:&error];
    STAssertTrue(result, @"result should be YES.");
    STAssertNil(error, @"error should be nil.");
    
    result = [self.service acquireLock:user error:&error];
    STAssertTrue(result, @"result should be YES.");
    STAssertNil(error, @"error should be nil.");
}

/*!
 @discussuion Test AcquireLock method with nil params
 */
- (void)testAcquireLock_Nil {
    NSError *error = nil;
    BOOL result = [self.service acquireLock:nil error:&error];
    STAssertFalse(result, @"result should be NO.");
    STAssertNotNil(error, @"error should not be nil.");
}

/*!
 @discussuion Test ReleaseLock method
 */
- (void)testReleaseLock {
    
    id<UserService> userService = [[UserServiceImpl alloc] initWithConfiguration:self.configurations
                                                                     lockService:self.service];
    
    NSError *error = nil;
    User *user = [userService buildUser:&error];
    user.fullName = @"test_user";
    BOOL result = [self.service acquireLock:user error:&error];
    STAssertTrue(result, @"result should be YES.");
    STAssertNil(error, @"error should be nil.");
    
    result = [self.service releaseLock:user error:&error];
    STAssertTrue(result, @"result should be YES.");
    STAssertNil(error, @"error should be nil.");
    
}

/*!
 @discussuion Test ReleaseLock method multiple times
 */
- (void)testReleaseLock_Multiple {
    
    id<UserService> userService = [[UserServiceImpl alloc] initWithConfiguration:self.configurations
                                                                     lockService:self.service];
    
    NSError *error = nil;
    User *user = [userService buildUser:&error];
    user.fullName = @"test_user";
    BOOL result = [self.service acquireLock:user error:&error];
    STAssertTrue(result, @"result should be YES.");
    STAssertNil(error, @"error should be nil.");
    
    result = [self.service releaseLock:user error:&error];
    STAssertTrue(result, @"result should be YES.");
    STAssertNil(error, @"error should be nil.");
    
    result = [self.service releaseLock:user error:&error];
    STAssertFalse(result, @"result should be NO.");
    STAssertNotNil(error, @"error should not be nil.");
    
    result = [self.service releaseLock:user error:&error];
    STAssertFalse(result, @"result should be NO.");
    STAssertNotNil(error, @"error should not be nil.");

    
}

/*!
 @discussuion Test ReleaseLock method without acquire lock
 */
- (void)testReleaseLock_Empty {
    
    id<UserService> userService = [[UserServiceImpl alloc] initWithConfiguration:self.configurations
                                                                     lockService:self.service];
    
    NSError *error = nil;
    User *user = [userService buildUser:&error];
    user.fullName = @"test_user";
    BOOL result = [self.service releaseLock:user error:&error];
    STAssertFalse(result, @"result should be NO.");
    STAssertNotNil(error, @"error should not be nil.");
    
}

/*!
 @discussuion Test ReleaseLock method with nil params
 */
- (void)testReleaseLock_Nil {
    NSError *error = nil;
    BOOL result = [self.service releaseLock:nil error:&error];
    STAssertFalse(result, @"result should be NO.");
    STAssertNotNil(error, @"error should not be nil.");
}

/*!
 @discussuion Test sendLockHeartbeat method
 */
- (void)testSendHeartbeat {
    id<UserService> userService = [[UserServiceImpl alloc] initWithConfiguration:self.configurations
                                                                     lockService:self.service];
    
    NSError *error = nil;
    User *user = [userService buildUser:&error];
    user.fullName = @"test_user";

    BOOL result = [self.service sendLockHeartbeat:user error:&error];
    STAssertTrue(result, @"result should be YES.");
    STAssertNil(error, @"error should be nil.");
}

/*!
 @discussuion Test sendLockHeartbeat method multiple times
 */
- (void)testSendHeartbeat_Multiple {
    id<UserService> userService = [[UserServiceImpl alloc] initWithConfiguration:self.configurations
                                                                     lockService:self.service];
    
    NSError *error = nil;
    User *user = [userService buildUser:&error];
    user.fullName = @"test_user";
    
    BOOL result = [self.service sendLockHeartbeat:user error:&error];
    
    result = [self.service sendLockHeartbeat:user error:&error];
    STAssertTrue(result, @"result should be YES.");
    STAssertNil(error, @"error should be nil.");
    
    result = [self.service sendLockHeartbeat:user error:&error];
    STAssertTrue(result, @"result should be YES.");
    STAssertNil(error, @"error should be nil.");
}

/*!
 @discussuion Test sendLockHeartbeat method with nil params
 */
- (void)testSendLockHeartbeat_Nil {
    NSError *error = nil;
    BOOL result = [self.service sendLockHeartbeat:nil error:&error];
    STAssertFalse(result, @"result should be NO.");
    STAssertNotNil(error, @"error should not be nil.");
}

@end
