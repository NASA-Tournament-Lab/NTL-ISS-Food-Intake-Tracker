//
//  DataUpdateServiceTests.h
//  ISSFoodIntakeTracker
//
//  Created by LokiYang on 8/5/13.
//  Copyright (c) 2013 TopCoder Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "BaseTests.h"
#import "DataUpdateService.h"

/*!
 @class DataUpdateServiceTests
 @discussion This is the unit test cases for DataUpdateService.
 @author LokiYang
 @version 1.0
 */
@interface DataUpdateServiceTests : BaseTests

/*!
 @discussion This value represents DataUpdateService instance.
 */
@property (nonatomic, strong) id<DataUpdateService> service;
@end
