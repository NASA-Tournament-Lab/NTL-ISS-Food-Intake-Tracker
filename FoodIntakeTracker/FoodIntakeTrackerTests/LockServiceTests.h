//
//  LockServiceTests.h
//  ISSFoodIntakeTracker
//
//  Created by LokiYang on 2013-08-07.
//  Copyright (c) 2013 TopCoder Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "BaseTests.h"
#import "LockService.h"

/*!
 @class LockServiceTests
 @discussion This is the unit test cases for LockService.
 @author LokiYang
 @version 1.0
 */
@interface LockServiceTests : BaseTests

/*!
 @discussion This value represents LockService instance.
 */
@property (nonatomic, strong) id<LockService> service;

@end
