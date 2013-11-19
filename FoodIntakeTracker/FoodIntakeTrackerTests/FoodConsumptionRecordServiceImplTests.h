//
//  FoodConsumptionRecordServiceImplTests.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 7/12/13.
//  Copyright (c) 2013 tc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "BaseTests.h"
#import "FoodConsumptionRecordServiceImpl.h"
#import "UserServiceImpl.h"

//Class that contains test cases for FoodConsumptionRecordServiceImplTests
@interface FoodConsumptionRecordServiceImplTests : BaseTests

//Represents FoodConsumptionRecordServiceImpl instance for test
@property (nonatomic, strong) FoodConsumptionRecordServiceImpl *service;

//Represents UserServiceImpl instance for test
@property (nonatomic, strong) UserServiceImpl *userService;

/*!
 @property The SMBClient instance.
 */
@property (nonatomic, strong) id<SMBClient> smbClient;

@end
