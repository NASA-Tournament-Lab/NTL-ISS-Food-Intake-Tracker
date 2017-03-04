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
//  DataUpdateServiceImpl.m
//  ISSFoodIntakeTracker
//
//  Created by LokiYang on 2013-07-27.
//
//  Updated by pvmagacho on 04/19/2014
//  F2Finish - NASA iPad App Updates
//

#import "DataUpdateServiceImpl.h"
#import "FoodProductServiceImpl.h"
#import "UserServiceImpl.h"
#import "Models.h"
#import "LoggingHelper.h"
#import "DataHelper.h"
#import "AppDelegate.h"
#import "WebserviceCoreData.h"

@implementation DataUpdateServiceImpl

@synthesize cancelUpdate = _cancelUpdate;
@synthesize localFileSystemDirectory = _localFileSystemDirectory;
@synthesize imageFileNameSuffix = _imageFileNameSuffix;
@synthesize voiceRecordingFileNameSuffix = _voiceRecordingFileNameSuffix;

#define CHECK_ERROR_AND_RETURN(error, return_error, error_msg, error_code, unlock_context, undo_context) \
    if (error || self.cancelUpdate) {\
        if (error && return_error) {\
            *return_error = [NSError errorWithDomain:@"DataUpdateService" code:error_code\
                                            userInfo:@{NSUnderlyingErrorKey:error_msg}];\
        }\
        if (undo_context) {\
            [self undo];\
        }\
        if (unlock_context) {\
            [[self managedObjectContext] unlock];\
        }\
        [LoggingHelper logMethodExit:methodName returnValue:@NO];\
        return NO;\
    }

/*!
 @discussion Initialize the class instance with NSManagedObjectContext and configuration.
 * @param context The NSManagedObjectContext.
 * @param configuration The configuration.
 * @return The newly created object.
 */
-(id)initWithConfiguration:(NSDictionary *)configuration {
    self = [super initWithConfiguration:configuration];
    
    if(self) {
        _localFileSystemDirectory = [configuration valueForKey:@"LocalFileSystemDirectory"];
        _imageFileNameSuffix = [configuration valueForKey:@"ImageFileNameSuffix"];
        _voiceRecordingFileNameSuffix = [configuration valueForKey:@"VoiceRecordingFileNameSuffix"];
    }
    return self;
}

/*!
 @discussion This method will be used to apply data changes (control files) pushed from Earth Laboratory.
 @parame error The NSError object if any error occurred during the operation
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)update:(NSError **)error {
    return [self update:error force:NO];
}

/*!
 @discussion This method will be used to apply data changes (control files) pushed from Earth Laboratory.
 @parame error The NSError object if any error occurred during the operation
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)update:(NSError **)error force:(BOOL)force {
    NSString *methodName = [NSString stringWithFormat:@"%@.update:error:", NSStringFromClass(self.class)];
    [LoggingHelper logMethodEntrance:methodName paramNames:nil params:nil];
    
    // Update progress
    [self updateProgress:@0.0];
    
    WebserviceCoreData *coreData = [WebserviceCoreData instance];
    if (![coreData connect]) {
        return NO;
    }

    BOOL deviceRegistered = [coreData checkDeviceId];
    
    if (!deviceRegistered || force) {
        // Lock on the managedObjectContext
        [[self managedObjectContext] lock];

        // Update progress
        [self updateProgress:@0.05];

        NSTimeInterval updateTime = [[NSDate date] timeIntervalSince1970];
        
        NSArray *allData = [coreData fetchAllObjects];

        NSError *e = nil;
        float currentProgress = 0.05, progressDelta = 0.65, count = [coreData fetchMediaCount];

        if (![coreData startFetchMedia]) {
            e = [NSError errorWithDomain:@"Domain" code:DataUpdateErrorCode userInfo:nil];
            CHECK_ERROR_AND_RETURN(e, error, @"Failed start fetch", DataUpdateErrorCode, YES, NO);
            return NO;
        }

        if (count < 0) {
            return NO;
        }

        for (int i = 0; i < count; i++) {
            [LoggingHelper logDebug:methodName message:[NSString stringWithFormat:@"Getting media %d", (i+1)]];

            NSArray *medias = [coreData fetchNextMedia];
            if (medias != nil) {
                for (NSDictionary *dictFile in medias) {
                    NSString *oId = [dictFile objectForKey:@"id"];
                    NSString *dataFile = [dictFile objectForKey:@"filename"];
                    NSData *data = [dictFile objectForKey:@"data"];

                    if([dataFile hasSuffix:self.imageFileNameSuffix] || [dataFile hasSuffix:self.voiceRecordingFileNameSuffix]) {
                        NSString *localDataFile = [[DataHelper getAbsoulteLocalDirectory:self.localFileSystemDirectory]
                                                   stringByAppendingPathComponent:dataFile];
                        if (![data writeToFile:localDataFile options:NSDataWritingAtomic error:&e]) {
                            [LoggingHelper logError:methodName error:e];
                            CHECK_ERROR_AND_RETURN(e, error, @"Cannot save file to local folder.", DataUpdateErrorCode, YES, NO);
                        }

                        NSMutableDictionary *newDict = [dictFile mutableCopy];
                        [newDict removeObjectForKey:@"data"];
                        [newDict removeObjectForKey:@"id"];
                        if (![DataHelper convertJSONToObject:oId jsonValue:newDict  name:@"Media" managegObjectContext:self.managedObjectContext]) {
                            e = [NSError errorWithDomain:@"Domain" code:DataUpdateErrorCode userInfo:nil];
                            CHECK_ERROR_AND_RETURN(e, error, @"Cannot insert object.", DataUpdateErrorCode, YES, YES);
                        }
                    }
                }
            }

            // Update progress
            currentProgress += progressDelta/count;
            [self updateProgress:[NSNumber numberWithFloat:currentProgress]];
        }

        if (![coreData endFetchMedia]) {
            e = [NSError errorWithDomain:@"Domain" code:DataUpdateErrorCode userInfo:nil];
            CHECK_ERROR_AND_RETURN(e, error, @"Failed start fetch", DataUpdateErrorCode, YES, NO);
            return NO;
        }

        currentProgress = 0.7, progressDelta = 0.29, count = allData.count;
        if (allData && allData.count > 0) {
            // Calculate the the delta progress
            for (int i = 0; i < allData.count; i++) {
                NSDictionary *data = [allData objectAtIndex:i];

                if (i % 50 == 0 || [data isEqual:allData.lastObject]) {
                    [self startUndoActions];
                }

                NSString *oId = [data objectForKey:@"id"];
                NSString *name = [data objectForKey:@"name"];
                NSDictionary *value = [data objectForKey:@"value"];
                
                // Convert from JSON
                NSDictionary *jsonDictionary = [value copy];
                if (deviceRegistered) {
                    // Check if object already exists
                    NSFetchRequest *request = [[NSFetchRequest alloc] init];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(id == %@)", oId];
                    NSEntityDescription *description = [NSEntityDescription entityForName:name
                                                                   inManagedObjectContext:[self managedObjectContext]];
                    [request setEntity:description];
                    [request setPredicate:predicate];
                    NSArray *objects = [self.managedObjectContext executeFetchRequest:request error:error];
                    CHECK_ERROR_AND_RETURN(e, error, @"Cannot fetch object in managed object context.",
                                           EntityNotFoundErrorCode, YES, YES);

                    // Update if objects exists or insert if it doesn't (only for not removed object)
                    BOOL isRemoved = [[jsonDictionary objectForKey:@"removed"] boolValue] && ![name isEqualToString:@"FoodProduct"];
                    if (objects.count > 0) {
                        SynchronizableModel *object = [objects objectAtIndex:0];
                        if (isRemoved) {
                            [object setPrimitiveValue:@YES forKey:@"synchronized"];
                        } else {
                            if (![DataHelper updateObjectWithJSON:jsonDictionary object:object managegObjectContext:self.managedObjectContext]) {
                                e = [NSError errorWithDomain:@"Domain" code:DataUpdateErrorCode userInfo:nil];
                                CHECK_ERROR_AND_RETURN(e, error, @"Cannot update object.", DataUpdateErrorCode, YES, YES);
                            }
                        }
                    } else if (!isRemoved) {
                        if (![DataHelper convertJSONToObject:oId jsonValue:jsonDictionary name:name managegObjectContext:self.managedObjectContext]) {
                            e = [NSError errorWithDomain:@"Domain" code:DataUpdateErrorCode userInfo:nil];
                            CHECK_ERROR_AND_RETURN(e, error, @"Cannot insert object.", DataUpdateErrorCode, YES, YES);
                        }
                    }
                } else {
                    if (![DataHelper convertJSONToObject:oId jsonValue:jsonDictionary name:name managegObjectContext:self.managedObjectContext]) {
                        e = [NSError errorWithDomain:@"Domain" code:DataUpdateErrorCode userInfo:nil];
                        CHECK_ERROR_AND_RETURN(e, error, @"Cannot insert object.", DataUpdateErrorCode, YES, YES);
                    }
                }

                if (i % 50 == 0 || [data isEqual:allData.lastObject]) {
                    [self endUndoActions];
                    if (![self.managedObjectContext save:&e]) {
                        CHECK_ERROR_AND_RETURN(e, error, @"Cannot save managed object context.", DataUpdateErrorCode, YES, NO);
                    }
                }
                
                // Update progress
                currentProgress += progressDelta/count;
                [self updateProgress:[NSNumber numberWithFloat:currentProgress]];                        
            }
        }

        if (![self.managedObjectContext save:&e]) {
            CHECK_ERROR_AND_RETURN(e, error, @"Cannot save managed object context.", DataUpdateErrorCode, YES, NO);
        }

        [self updateSyncTime:updateTime];
        
        // Unlock the managedObjectContext
        [[self managedObjectContext] unlock];
    }
    
    // Update progress
    [self updateProgress:@0.99];
    
    [LoggingHelper logMethodExit:methodName returnValue:@YES];
    return YES;
}

- (void) updateProgress:(NSNumber *)progress {
    NSDictionary *progressParam = @{@"progress": progress};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitialLoadingProgressEvent" object:progressParam];
}

/*!
@discussion This method will get all non synchronized entity objects.
@return Current Timestamp in long.
*/
- (NSTimeInterval)getLastSynchronizedTime{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *lastSyncTime = [defaults objectForKey:@"LastSynchronizedTime"];
    if(lastSyncTime != nil) {
        return lastSyncTime.doubleValue;
    }
    return 0;
}

-(void)updateSyncTime:(NSTimeInterval)timestamp {
    NSNumber *syncTime = [NSNumber numberWithDouble:timestamp];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:syncTime forKey:@"LastSynchronizedTime"];
    [defaults synchronize];
    return;
}

@end
