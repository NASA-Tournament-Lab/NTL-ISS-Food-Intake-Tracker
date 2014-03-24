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
//  BaseCommunicationDataService.m
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 2013-07-13.
//

#import "BaseCommunicationDataService.h"
#import "Reachability.h"
#import "SMBClientImpl.h"
#import "LoggingHelper.h"

@implementation BaseCommunicationDataService

@synthesize sharedFileServerPath = _sharedFileServerPath;
@synthesize sharedFileServerUsername = _sharedFileServerUsername;
@synthesize sharedFileServerPassword = _sharedFileServerPassword;
@synthesize sharedFileServerWorkgroup = _sharedFileServerWorkgroup;

/*!
 @discussion Initialize the class instance with NSManagedObjectContext and configuration.
 * @param context The NSManagedObjectContext.
 * @param configuration The configuration.
 * @return The newly created object.
 */
-(id)initWithConfiguration:(NSDictionary *)configuration {
    self = [super init];
    if (self) {
        _sharedFileServerPath = configuration[@"SharedFileServerPath"];
        _sharedFileServerWorkgroup = configuration[@"SharedFileServerWorkgroup"];
        _sharedFileServerUsername = configuration[@"SharedFileServerUsername"];
        _sharedFileServerPassword = configuration[@"SharedFileServerPassword"];
    }
    return self;
}

/*!
 @discussion Create an SMBClient.
 Note that if WiFi network isn't available, SMBClient won't be created.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return The created SMBClient.
 */
-(id<SMBClient>)createSMBClient:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.createSMBClient:", NSStringFromClass(self.class)];
    [LoggingHelper logMethodEntrance:methodName paramNames:nil params:nil];
    
    //Test local wifi reachability
    Reachability* reachability = [Reachability reachabilityForLocalWiFi];
    if ([reachability isReachable]) {
        // Create an implementation of SMBClient
        id<SMBClient> client = [[SMBClientImpl alloc] init];
        NSError *e = nil;
        [client connect:self.sharedFileServerPath workgroup:self.sharedFileServerWorkgroup
               username:self.sharedFileServerUsername password:self.sharedFileServerPassword error:&e];
        if (e) {
            if (error) {
                *error = e;
            }
            [LoggingHelper logMethodExit:methodName returnValue:nil];
            return nil;
        }
        else {
            [LoggingHelper logMethodExit:methodName returnValue:client];
            return client;
        }
    } else {
        if(error) {
            *error = [NSError errorWithDomain:@"BaseCommunicationDataService"
                                         code:WiFiNotAvailableErrorCode
                                     userInfo:@{NSUnderlyingErrorKey: @"WiFi network isn't available."}];
            [LoggingHelper logError:methodName error:*error];
        }
        [LoggingHelper logMethodExit:methodName returnValue:nil];
        return nil;
    }
}

@end
