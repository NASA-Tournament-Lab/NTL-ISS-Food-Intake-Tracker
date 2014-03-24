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
//  FoodProductServiceImpl.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 2013-07-13.
//

#import <Foundation/Foundation.h>
#import "BaseDataService.h"
#import "FoodProductService.h"

/*!
 @class FoodProductServiceImpl
 @discussion This class is the default implementation which conform to FoodProductService protocol.
 @author flying2hk, duxiaoyang, LokiYang
 @version 1.1
 @changes from 1.0
    1.Fixed " Method accepting NSError** should have a non-void return value to indicate whether or not an error
    occurred". Add a BOOL return to indicate whether the operation succeeds.
 */
@interface FoodProductServiceImpl : BaseDataService<FoodProductService>

@end
