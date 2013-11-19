//
//  LockService.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 2013-07-10.
//  Copyright (c) 2013 TopCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Models.h"

/*!
 @protocol LockService
 @discussion This interface defines the methods to acquire/release/heartbeat user locks.
 @author flying2hk, duxiaoyang, LokiYang
 @version 1.1
 @changes from 1.0
    1. Fixed " Method accepting NSError** should have a non-void return value to indicate whether or not an error
    occurred". Add a BOOL return to indicate whether the operation succeeds.
 */
@protocol LockService <NSObject>

/*!
 @discussion Acquire user lock.
 If the device is not connected to Wi-Fi network, then this method will do nothing.
 @param user The user.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)acquireLock:(User *)user error:(NSError **)error;

/*!
 @discussion Release user lock.
 If the device is not connected to Wi-Fi network, then this method will do nothing.
 @param user The user.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL) releaseLock:(User*)user error:(NSError**)error;

/*!
 @discussion Send lock heartbeat.
 If the device is not connected to Wi-Fi network, then this method will do nothing.
 @param user The user.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL) sendLockHeartbeat:(User*)user error:(NSError**)error;

@end
