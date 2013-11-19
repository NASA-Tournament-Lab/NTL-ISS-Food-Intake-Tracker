//
//  LoggingHelper.m
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 2013-07-11.
//  Copyright (c) 2013 TopCoder. All rights reserved.
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

+(void)logError:(NSString *)methodName error:(NSError *)error {
    if (ERROR_LOGON) {
        if (error) {
            NSLog(@"[Error in method %@: Details %@]", methodName, error.userInfo);
        }
    }
}

@end
