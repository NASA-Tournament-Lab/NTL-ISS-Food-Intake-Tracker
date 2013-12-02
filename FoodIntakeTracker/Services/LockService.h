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
//  LockService.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 2013-07-10.
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
