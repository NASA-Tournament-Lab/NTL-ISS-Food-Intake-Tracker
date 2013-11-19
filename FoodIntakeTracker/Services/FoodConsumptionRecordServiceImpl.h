//
//  FoodConsumptionRecordServiceImpl.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 2013-07-13.
//  Copyright (c) 2013 TopCoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseCommunicationDataService.h"
#import "FoodConsumptionRecordService.h"

/*!
 @class FoodConsumptionRecordServiceImpl
 @discussion This class is the default implementation which conform to FoodConsumptionRecordService protocol.
 @author flying2hk, duxiaoyang, LokiYang, subchap
 @version 1.1
 @changes from 1.0
    1.Fixed " Method accepting NSError** should have a non-void return value to indicate whether or not an error
    occurred". Add a BOOL return to indicate whether the operation succeeds.
 */
@interface FoodConsumptionRecordServiceImpl : BaseCommunicationDataService<FoodConsumptionRecordService>

/*!
 @discussion Represents the modifiable period in days.
 */
@property (nonatomic, readonly, strong) NSNumber *modifiablePeriodInDays;

/*!
 @discussion Represents the record kept period in days.
 */
@property (nonatomic, readonly, strong) NSNumber *recordKeptPeriodInDays;

/*!
 @discussion Initialize the class instance with NSManagedObjectContext and configuration.
 * @param context The NSManagedObjectContext.
 * @param configuration The configuration.
 * @return The newly created object.
 */
-(id)initWithConfiguration:(NSDictionary *)configuration;

@end
