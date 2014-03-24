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
//  BaseCommunicationDataServiceTests.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 7/12/13.
//

#import <SenTestingKit/SenTestingKit.h>
#import "BaseCommunicationDataService.h"
#import "BaseTests.h"

/*!
 @class BaseCommunicationDataServiceTests
 @discussion This is the unit test cases for BaseCommunicationDataService.
 @author duxiaoyang, LokiYang
 @version 1.1
 @changes from 1.0
    1. Add SMBClient support.
 */
@interface BaseCommunicationDataServiceTests : BaseTests

//Represents BaseCommunicationDataService instance for test
@property (nonatomic, strong) BaseCommunicationDataService *service;


@end
