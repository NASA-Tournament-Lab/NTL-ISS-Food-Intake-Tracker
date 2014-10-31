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
#import "parseCSV.h"
#import "Models.h"
#import "LoggingHelper.h"
#import "DataHelper.h"
#import "AppDelegate.h"

#import "PGCoreData.h"

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
    
    PGCoreData *coreData = [PGCoreData instance];
    if (![coreData isConnected]) {
        if (![coreData connect]) {
            return NO;
        }
    }
    
    BOOL deviceRegistered = [coreData checkDeviceId];
    
    if (!deviceRegistered || force) {
        // Lock on the managedObjectContext
        [[self managedObjectContext] lock];
    
        
        // Update progress
        [self updateProgress:@0.05];
        
        NSArray *allData = [coreData fetchAllObjects];

        NSError *e = nil;
        float currentProgress = 0.1, progressDelta = 0.6, count = allData.count;
        if (allData && allData.count > 0) {
            // Calculate the the delta progress
            for (NSDictionary *data in allData) {
                [self startUndoActions];
                
                NSString *oId = [data objectForKey:@"id"];
                NSString *name = [data objectForKey:@"name"];
                NSString *value = [data objectForKey:@"value"];
                
                // Convert from JSON
                NSData *jsonData = [value dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
                CHECK_ERROR_AND_RETURN(e, error, @"Cannot convert JSON data to managed object.", DataUpdateErrorCode, YES, YES);
                
                // Check if object already exists
                NSFetchRequest *request = [[NSFetchRequest alloc] init];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(uuid == %@)", oId];
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
                
                [self endUndoActions];
                [[self managedObjectContext] save:&e];
                CHECK_ERROR_AND_RETURN(e, error, @"Cannot save managed object context.", DataUpdateErrorCode, YES, NO);
                
                // Update progress
                currentProgress += progressDelta/count;
                [self updateProgress:[NSNumber numberWithFloat:currentProgress]];                        
            }
        }
        
        [coreData.pgConnection reset];
        
        if (![coreData startFetchMedia]) {
            e = [NSError errorWithDomain:@"Domain" code:DataUpdateErrorCode userInfo:nil];
            CHECK_ERROR_AND_RETURN(e, error, @"Failed start fetch", DataUpdateErrorCode, YES, NO);
            return NO;
        }
        
        currentProgress = 0.7, progressDelta = 0.29, count = [coreData fetchMediaCount];
        if (count < 0) {
            return NO;
        }
        
        for (int i = 0; i < count; i++) {
            [LoggingHelper logDebug:methodName message:[NSString stringWithFormat:@"Getting image %d", (i+1)]];
            
            NSDictionary *dictFile = [coreData fetchNextMedia];
            NSString *dataFile = [dictFile objectForKey:@"filename"];
            NSData *data = [dictFile objectForKey:@"data"];
            if([dataFile hasSuffix:self.imageFileNameSuffix] || [dataFile hasSuffix:self.voiceRecordingFileNameSuffix]) {
                NSString *localDataFile = [[DataHelper getAbsoulteLocalDirectory:self.localFileSystemDirectory]
                                           stringByAppendingPathComponent:dataFile];
                [data writeToFile:localDataFile options:NSDataWritingAtomic error:&e];
                [LoggingHelper logError:methodName error:e];
                CHECK_ERROR_AND_RETURN(e, error, @"Cannot save file to local folder.", DataUpdateErrorCode, YES, NO);
            }
            
            // Update progress
            currentProgress += progressDelta/count;
            [self updateProgress:[NSNumber numberWithFloat:currentProgress]];
        }
        
        [[PGCoreData instance] clearObjectSyncData];
        
        if (![coreData endFetchMedia]) {
            e = [NSError errorWithDomain:@"Domain" code:DataUpdateErrorCode userInfo:nil];
            CHECK_ERROR_AND_RETURN(e, error, @"Failed start fetch", DataUpdateErrorCode, YES, NO);
            return NO;
        }
        
        [[PGCoreData instance] clearMediaSyncData];
        
        [self updateSyncTime:[[NSDate date] timeIntervalSince1970] * 1000];
        
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
- (long long)getLastSynchronizedTime{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *lastSyncTime = [defaults objectForKey:@"LastSynchronizedTime"];
    if(lastSyncTime != nil) {
       return [lastSyncTime longLongValue];
    }
    return 0;
}

-(void)updateSyncTime:(long long)timestamp {
    NSNumber *syncTime = [NSNumber numberWithLongLong:timestamp];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:syncTime forKey:@"LastSynchronizedTime"];
    return;
}

@end
