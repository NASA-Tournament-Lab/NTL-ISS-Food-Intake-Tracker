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

#import <Foundation/Foundation.h>

//INFO_LOGON, 1 means turn on logger for info (method entrance and exit), 0 means turn off
#ifndef INFO_LOGON
#define INFO_LOGON 0
#endif


//ERROR_LOGON, 1 means turn on logger for error, 0 means turn off
#ifndef ERROR_LOGON
#define ERROR_LOGON 1
#endif

/*!
 @class LoggingHelper
 @discussion This class is a helper class used for logging.
 @author duxiaoyang, LokiYang
 @version 1.1
 @changes from 1.0
    1. minor fixes.
    2. Added differnt logging level support.
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
 @discussion Log error.
 @param methodName The method name.
 @param error The error to log.
 */
+(void)logError:(NSString *)methodName error:(NSError *)error;

@end
