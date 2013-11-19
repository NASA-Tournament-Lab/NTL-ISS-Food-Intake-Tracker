//
//  UserServiceTests.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 2013-07-11.
//  Copyright (c) 2013 TopCoder. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "UserServiceImpl.h"
#import "LockService.h"
#import "BaseTests.h"
#import "SMBClient.h"

/*!
 @class UserServiceTests
 @discussion This is the unit test cases for UserService.
 @author duxiaoyang, LokiYang
 @version 1.1
 @changes from 1.0
    1. Add LockService support.
 */
@interface UserServiceTests : BaseTests

/*!
 @property The UserService to test.
 */
@property (nonatomic, strong) UserServiceImpl *userService;

/*!
 @property The lock service for testing.
 */
@property (nonatomic, strong) id<LockService> lockService;

/*!
 @property The SMBClient instance.
 */
@property (nonatomic, strong) id<SMBClient> smbClient;

@end
