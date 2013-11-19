//
//  FoodProductServiceTests.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 2013-07-13.
//  Copyright (c) 2013 TopCoder. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "FoodProductServiceImpl.h"
#import "UserServiceImpl.h"
#import "BaseTests.h"

/*!
 @class FoodProductServiceTests
 @discussion This is the unit test cases for FoodProductService.
 @author duxiaoyang
 @version 1.0
 */
@interface FoodProductServiceTests : BaseTests

/*!
 @property The FoodProductService to test.
 */
@property (nonatomic, strong) FoodProductServiceImpl *foodProductService;

/*!
 @property The UserService to test.
 */
@property (nonatomic, strong) UserServiceImpl *userService;

@end
