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
//  LoggingHelper.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 2013-07-11.
//
//  Updated by pvmagacho on 05/14/2014
//  F2Finish - NASA iPad App Updates - Round 3
//

#import <Foundation/Foundation.h>

//INFO_LOGON, 1 means turn on logger for info (method entrance and exit), 0 means turn off
#ifndef INFO_LOGON
#define INFO_LOGON 0
#endif

//DEBUG_LOGON, 1 means turn on logger for debug , 0 means turn off
#ifndef DEBUG_LOGON
#define DEBUG_LOGON 1
#endif

//ERROR_LOGON, 1 means turn on logger for error, 0 means turn off
#ifndef ERROR_LOGON
#define ERROR_LOGON 1
#endif

/*!
 @class LoggingHelper
 @discussion This class is a helper class used for logging.
 @author duxiaoyang, LokiYang
 @version 1.2
 @changes from 1.0
    1. minor fixes.
    2. Added differnt logging level support.
    3. Added log exception
 */
@interface LoggingHelper : NSObject

/*!
 @discussion Log method entrance.
 @param methodName The method name.
 @param paramNames The parameter names.
 @param params The parameters.
 */
+(void)logMethodEntrance:(NSString *)methodName paramNames:(NSArray *)paramNames params:(NSArray *)params;

/*!
 @discussion Log method exit.
 @param methodName The method name.
 @param returnValue The return value (if any).
 */
+(void)logMethodExit:(NSString *)methodName returnValue:(id)value;

/*!
 @discussion Log debug.
 @param methodName The method name.
 @param message The message to log.
 */
+(void)logDebug:(NSString *)methodName message:(NSString *)message;

/*!
 @discussion Log error.
 @param methodName The method name.
 @param error The error to log.
 */
+(void)logError:(NSString *)methodName error:(NSError *)error;

/*!
 @discussion Log exception.
 @param methodName The method name.
 @param exception The exception to log.
 */
+(void)logException:(NSString *)methodName error:(NSException *)exception;

@end
