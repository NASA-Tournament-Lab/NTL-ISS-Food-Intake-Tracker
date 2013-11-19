//
//  SynchronizationServiceTests.h
//  ISSFoodIntakeTracker
//
//  Created by LokiYang on 2013-08-07.
//  Copyright (c) 2013 TopCoder Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "BaseTests.h"
#import "SynchronizationService.h"

/*!
 @class SynchronizationServiceTests
 @discussion This is the unit test cases for SynchronizationService.
 @author LokiYang
 @version 1.0
 */
@interface SynchronizationServiceTests : BaseTests

/*!
 @discussion This value represents SynchronizationService instance.
 */
@property (nonatomic, strong) id<SynchronizationService> service;
@end
