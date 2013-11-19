//
//  FoodProductServiceImpl.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 2013-07-13.
//  Copyright (c) 2013 TopCoder. All rights reserved.
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
