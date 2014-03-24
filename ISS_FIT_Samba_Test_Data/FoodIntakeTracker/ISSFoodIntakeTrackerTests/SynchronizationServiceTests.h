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
//  SynchronizationServiceTests.h
//  ISSFoodIntakeTracker
//
//  Created by LokiYang on 2013-08-07.
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
