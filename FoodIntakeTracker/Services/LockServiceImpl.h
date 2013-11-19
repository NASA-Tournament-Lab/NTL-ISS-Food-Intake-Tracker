//
//  LockServiceImpl.h
//  ISSFoodIntakeTracker
//
//  Created by LokiYang on 2013-07-27.
//  Copyright (c) 2013 TopCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseCommunicationDataService.h"
#import "LockService.h"

/*!
 @class LockServiceImpl
 @discussion This is the default implementation of LockService protocol.
 @author flying2hk, LokiYang
 @version 1.0
 */
@interface LockServiceImpl : BaseCommunicationDataService<LockService>

/*!
 @discussion This value represents the lock expiration time period (in seconds). Can't be null or non-positive value.
 */
@property (nonatomic, readonly, strong) NSNumber *lockExpirationPeriodInSeconds;
@end
