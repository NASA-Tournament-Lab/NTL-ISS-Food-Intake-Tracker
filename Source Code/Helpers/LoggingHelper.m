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
//  LoggingHelper.m
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 2013-07-11.
//
//  Updated by pvmagacho on 05/14/2014
//  F2Finish - NASA iPad App Updates - Round 3
//

#import "LoggingHelper.h"



@implementation LoggingHelper

+(void)logMethodEntrance:(NSString *)methodName paramNames:(NSArray *)paramNames params:(NSArray *)params {
    if (INFO_LOGON) {
        NSLog(@"[Entering method %@]", methodName);
        if (paramNames && paramNames.count > 0) {
            NSMutableString *log = [NSMutableString stringWithString:@"[Input parameters ["];
            for (unsigned int i = 0; i < paramNames.count; i++) {
                [log appendString:paramNames[i]];
                [log appendString:@":"];
                [log appendFormat:@"%@", params[i]];
                if (i < paramNames.count - 1) {
                    [log appendString:@","];
                }
            }
            NSLog(@"%@]]", log);
        }
    }
}

+(void)logMethodExit:(NSString *)methodName returnValue:(id)value {
    if (INFO_LOGON) {
        NSLog(@"[Exiting method %@]", methodName);
        if (value) {
            NSLog(@"[Output parameter %@]", value);
        }
    }
}


+(void)logDebug:(NSString *)methodName message:(NSString *)message {
    if (DEBUG_LOGON) {
        if (message) {
            NSLog(@"[Debug for thread %@ in method %@: %@]", [[NSThread currentThread] name], methodName, message);
        }
    }
}

+(void)logError:(NSString *)methodName error:(NSError *)error {
    if (ERROR_LOGON) {
        if (error) {
            NSLog(@"[Error in method %@: Details %@]", methodName, error.userInfo);
        }
    }
}

+(void)logException:(NSString *)methodName error:(NSException *)exception {
    if (ERROR_LOGON) {
        if (exception) {
            NSLog(@"[Error in method %@: Details %@]", methodName, exception.reason);
        }
    }
}

@end
