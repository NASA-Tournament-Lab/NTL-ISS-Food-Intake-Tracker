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
//  LockServiceImpl.m
//  ISSFoodIntakeTracker
//
//  Created by LokiYang on 2013-07-27.
//

#import "LockServiceImpl.h"
#import "LoggingHelper.h"
#import "DataHelper.h"

@implementation LockServiceImpl

@synthesize lockExpirationPeriodInSeconds = _lockExpirationPeriodInSeconds;

/*!
 @discussion Initialize the class instance with NSManagedObjectContext and configuration.
 * @param context The NSManagedObjectContext.
 * @param configuration The configuration.
 * @return The newly created object.
 */
-(id)initWithConfiguration:(NSDictionary *)configuration {
    self = [super initWithConfiguration:configuration];
    
    if(self) {
        _lockExpirationPeriodInSeconds = [configuration valueForKey:@"LockExpirationPeriodInSeconds"];
    }
    return self;
}

/*!
 @discussion Acquire user lock.
 If the device is not connected to Wi-Fi network, then this method will do nothing.
 @param user The user.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)acquireLock:(User *)user error:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.acquireLock:error", NSStringFromClass(self.class)];
    // Create SMBClient and connect to the shared file server
    NSError *e = nil;
    
    if (user == nil) {
        e = [NSError errorWithDomain:@"LockService" code:IllegalArgumentErrorCode
                            userInfo:@{NSUnderlyingErrorKey: @"user should not be nil"}];
        if (error) {
            *error =  e;
        }
        [LoggingHelper logError:methodName error:e];
        return NO;
        
    }
    
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"user"] params:@[user]];
    
    id<SMBClient> smbClient = [self createSMBClient:&e];
    if (e) {
        if (error) {
            *error = e;
        }
        [LoggingHelper logMethodExit:methodName returnValue:@NO];
        return NO;
    }
    
    // Get lock files
    e = nil;
    NSArray *lockFileNames = [smbClient listFiles:@"locks/" error:&e];
    if (e) {
        if(error) {
            *error = [[NSError alloc] initWithDomain:@"LockService" code:LockErrorCode
                                        userInfo:@{NSLocalizedDescriptionKey: @"Cannot connect to the server."}];
         
        }
        [LoggingHelper logError:methodName error:e];
        
    }
    else {
        // Check if a lock file is present for the user
        BOOL lockFound = NO;
        for (NSString* fileName in lockFileNames) {
            if ([fileName hasPrefix:[user.fullName stringByAppendingString:@"_"]]) {
                lockFound = YES;
                // There is an existing lock, check if it's for this device
                NSString *deviceIDInFileName = [fileName substringFromIndex:user.fullName.length+1];
                NSString* deviceID = [DataHelper getDeviceIdentifier];
                
                if (![deviceID isEqualToString:deviceIDInFileName]) {
                    // It's not for this device, check if it's expired
                    NSData *timestampData = [smbClient readFile:[NSString stringWithFormat:@"locks/%@", fileName]
                                                          error:&e];
                    if (e) {
                        if (error) {
                            *error = [[NSError alloc] initWithDomain:@"LockService"
                                                                code:LockErrorCode
                                                            userInfo:@{NSLocalizedDescriptionKey:
                                      @"Error getting timestamp from existing lock file file."}];
                        }
                        [LoggingHelper logError:methodName error:e];
                    }

                    NSString *timestampStr = [[NSString alloc] initWithData:timestampData encoding:NSUTF8StringEncoding];
                    NSNumber *lockTimestamp = [[[NSNumberFormatter alloc] init] numberFromString:timestampStr];
                    if ([[NSDate date] timeIntervalSince1970] - [lockTimestamp doubleValue]
                        > [self.lockExpirationPeriodInSeconds doubleValue]) {
                        // lock expired, delete the lock file
                        e = nil;
                        [smbClient deleteFile:[NSString stringWithFormat:@"locks/%@", fileName] error:&e];
                        if (e) {
                            if (error) {
                                *error = [[NSError alloc] initWithDomain:@"LockService"
                                                                    code:LockErrorCode
                                                                userInfo:@{NSLocalizedDescriptionKey:
                                                                            @"Error removing expired lock file."}];
                            }
                            [LoggingHelper logError:methodName error:e];
                        } else {
                            // Write lock file
                            e = nil;
                            [self writeLockFile:user smbClient:smbClient error:&e];
                            if (e) {
                                if (error) {
                                    *error = [[NSError alloc] initWithDomain:@"LockService"
                                                                        code:LockErrorCode
                                                                    userInfo:@{NSLocalizedDescriptionKey:
                                                                            @"Error creating lock file."}];
                                
                                }
                                [LoggingHelper logError:methodName error:e];
                            }
                        }
                    } else {
                        if (e) {
                            if (error) {
                                *error = [[NSError alloc] initWithDomain:@"LockService" code:LockErrorCode
                                                                userInfo:@{NSLocalizedDescriptionKey:
                                                                            @"Can't acquire lock."}];
                             
                            }
                            [LoggingHelper logError:methodName error:e];
                        }
                    }
                                                        
                } else {
                    // It's for this device, update the timestamp
                    e = nil;
                    [self writeLockFile:user smbClient:smbClient error:&e];
                    if (e) {
                        if (error) {
                            *error = [[NSError alloc] initWithDomain:@"LockService" code:LockErrorCode
                                                            userInfo:@{NSLocalizedDescriptionKey:
                                                                        @"Error updating lock file timestamp."}];
                        }
                        [LoggingHelper logError:methodName error:e];
                    }
                    
                }
                break;
            }
        }
        
        if (!lockFound) {
            // No existing lock, create lock file
            e = nil;
            [self writeLockFile:user smbClient:smbClient error:&e];
            if (e) {
                if (error) {
                    *error = [[NSError alloc] initWithDomain:@"LockService" code:LockErrorCode
                                                    userInfo:@{NSLocalizedDescriptionKey:
                                                                @"Error creating lock file."}];
                }
                [LoggingHelper logError:methodName error:e];
                
            }
        }
    }
                                            
    // Finally disconnect from shared file server
    [smbClient disconnect:&e];
    return e ? NO : YES;
}

/*!
 @discussion Release user lock.
 If the device is not connected to Wi-Fi network, then this method will do nothing.
 @param user The user.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)releaseLock:(User*)user error:(NSError**)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.releaseLock:error:", NSStringFromClass(self.class)];
     NSError *e = nil;
    
    if (user == nil) {
        e = [NSError errorWithDomain:@"LockService" code:IllegalArgumentErrorCode
                            userInfo:@{NSUnderlyingErrorKey: @"user  should not be nil"}];
        if (error) {
            *error =  e;
        }
        [LoggingHelper logError:methodName error:e];
        return NO;
        
    }
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"user"] params:@[user]];
    
    id<SMBClient> smbClient = [self createSMBClient:&e];
    if (e) {
        if (error) {
            *error = e;
        }
        [LoggingHelper logMethodExit:methodName returnValue:@NO];
        return NO;
    }

    // Delete lock file
    [smbClient deleteFile:[NSString stringWithFormat:@"locks/%@_%@", user.fullName,
                           [DataHelper getDeviceIdentifier]] error:&e];
    if (e) {
        if (error) {
            *error = [[NSError alloc] initWithDomain:@"LockService" code:LockErrorCode
                                            userInfo:@{NSLocalizedDescriptionKey: @"Error deleting lock file."}];
            [LoggingHelper logError:methodName error:*error];
        }
    }
    // Finally disconnect from shared file server
    [smbClient disconnect:&e];
    [LoggingHelper logMethodExit:methodName returnValue:e ? @NO : @YES];
    return e ? NO : YES;
}

/*!
 @discussion Private utility method to write lock file, new file will be created if not present, existing file will be 
    overwritten if present.
 @param user The user that the lock belongs to
 @param smbClient shared server cient
 @param error The NSError
 @return YES if the operation succeeds. No otherwise.
 */
- (BOOL)writeLockFile:(User *)user smbClient:(id<SMBClient>)smbClient error:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.writeLockFile:smbClient:error:",
                            NSStringFromClass(self.class)];
    NSError *e = nil;
    if (user == nil || smbClient == nil) {
        e = [NSError errorWithDomain:@"LockService" code:IllegalArgumentErrorCode
                            userInfo:@{NSUnderlyingErrorKey: @"user  or smbClient should not be nil"}];
        if (error) {
            *error =  e;
        }
        [LoggingHelper logError:methodName error:e];
        return NO;
        
    }
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"user", @"smbclient"] params:@[user, smbClient]];
    
    NSString* timestamp = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
    NSData *data = [timestamp dataUsingEncoding:NSUTF8StringEncoding];

    [smbClient writeFile:[NSString stringWithFormat:@"locks/%@_%@", user.fullName,
                          [DataHelper getDeviceIdentifier]] data:data error:&e];
    if (e && error) {
        *error = [[NSError alloc] initWithDomain:@"LockService" code:LockErrorCode
                                        userInfo:@{NSLocalizedDescriptionKey: @"Error writing lock file."}];
        [LoggingHelper logError:methodName error:*error];
    }
    [LoggingHelper logMethodExit:methodName returnValue:e ? @NO : @YES];
    return e ? NO : YES;
}

/*!
 @discussion Send lock heartbeat.
 If the device is not connected to Wi-Fi network, then this method will do nothing.
 @param user The user.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)sendLockHeartbeat:(User*)user error:(NSError**)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.sendLockHeartbeat:user:error:",
                            NSStringFromClass(self.class)];
    NSError *e = nil;
    if (user == nil) {
        e = [NSError errorWithDomain:@"LockService" code:IllegalArgumentErrorCode
                            userInfo:@{NSUnderlyingErrorKey: @"user should not be nil"}];
        if (error) {
            *error =  e;
        }
        [LoggingHelper logError:methodName error:e];
        return NO;
        
    }
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"user"] params:@[user]];
    
    // Create SMBClient and connect to the shared file server
    id<SMBClient> smbClient = [self createSMBClient:&e];
    if (smbClient == nil) {
        if(error) {
            *error = e;
        }
        [LoggingHelper logMethodExit:methodName returnValue:@NO];
        return NO;
    }

    [self writeLockFile:user smbClient:smbClient error:&e];
    if (e && error ) {
        *error = e;
    }
    // Finally disconnect from shared file server
    [smbClient disconnect:&e];
    [LoggingHelper logMethodExit:methodName returnValue: e? @NO : @YES];
    return e ? NO : YES;
}
@end
