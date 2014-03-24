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
//  FoodConsumptionRecordServiceImplTests.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 7/12/13.
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
