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
//  SynchronizationServiceImpl.m
//  ISSFoodIntakeTracker
//
//  Created by LokiYang,supercharger on 2013-07-27.
//
//  Updated by pvmagacho on 04/19/2014
//  F2Finish - NASA iPad App Updates
//

#import "SynchronizationServiceImpl.h"
#import "UserServiceImpl.h"
#import "FoodConsumptionRecordServiceImpl.h"
#import "FoodProductServiceImpl.h"
#import "Models.h"
#import "LoggingHelper.h"
#import "Helper.h"
#import "DataHelper.h"
#import "Settings.h"
#import "AppDelegate.h"

#import "PGCoreData.h"

@implementation SynchronizationServiceImpl

@synthesize localFileSystemDirectory = _localFileSystemDirectory;
@synthesize voiceRecordingFileNameSuffix = _voiceRecordingFileNameSuffix;
@synthesize imageFileNameSuffix = _imageFileNameSuffix;


#define CHECK_ERROR_AND_RETURN(error, return_error, error_msg, error_code, unlock_context, undo_context) \
    if (error) {\
        if (return_error) {\
            *return_error = [NSError errorWithDomain:@"SynchronizationService" code:error_code\
            userInfo:@{NSUnderlyingErrorKey:error_msg}];\
        }\
        if (undo_context) {\
            [self undo];\
        }\
        if (unlock_context) {\
            [[self managedObjectContext] unlock];\
        }\
        [LoggingHelper logMethodExit:methodName returnValue:@NO];\
        if (unlock_context || undo_context) return NO;\
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
 @discussion This method will get all non synchronized entity objects.
 @return Current Timestamp in long.
 */
- (long long)getLastSynchronizedTime{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *lastSyncTime = [defaults objectForKey:@"LastSynchronizedTime"];
    if(lastSyncTime != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:UpdateLastSync
                                                            object:[NSDate
                                                                    dateWithTimeIntervalSince1970:[lastSyncTime longLongValue]/1000]];
        
        return [lastSyncTime longLongValue];    
    }
    return 0;
}

-(void)updateSyncTime:(long long)timestamp {
    NSNumber *syncTime = [NSNumber numberWithLongLong:timestamp];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:syncTime forKey:@"LastSynchronizedTime"];
    
    NSLog(@"\tUpdated last sync to %@", [NSDate dateWithTimeIntervalSince1970:timestamp/1000]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UpdateLastSync
                                                        object:[NSDate dateWithTimeIntervalSince1970:timestamp/1000]];
    return;
}

/*!
 @discussion This method will get all entity objects.
 @param entityName The object's entity name.
 @param error The error.
 @return A NSArray contains objects.
 */
- (NSArray *)getAllObjects:(NSString *)entityName error:(NSError **)error {
    [self.managedObjectContext lock];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription  entityForName:entityName
                                                    inManagedObjectContext:[self managedObjectContext]];
    [request setEntity:description];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastModifiedDate" ascending:YES]]];
    NSArray *results = [[self managedObjectContext] executeFetchRequest:request error:error];
    [self.managedObjectContext unlock];
    return results;
}

/*!
 @discussion This method will get all non synchronized entity objects.
 @param entityName The object's entity name.
 @param error The error.
 @return A NSArray contains objects.
 */
- (NSArray *)getNonSynchronizedObject:(NSString *)entityName error:(NSError **)error {
    [self.managedObjectContext lock];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(synchronized == NO)"];
    NSEntityDescription *description = [NSEntityDescription  entityForName:entityName
                                                    inManagedObjectContext:[self managedObjectContext]];
    [request setEntity:description];
    [request setPredicate:predicate];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastModifiedDate" ascending:YES]]];
    NSArray *results = [[self managedObjectContext] executeFetchRequest:request error:error];
    [self.managedObjectContext unlock];
    return results;
}

- (void) updateProgress:(NSNumber *)progress {
    NSDictionary *progressParam = @{@"progress": progress};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InitialLoadingProgressEvent" object:progressParam];
}

/*!
 @discussion This method will be used to synchronize the data. If the iPad device is currently not connected
 to Wi-Fi network, then this method will do nothing.
 @parame error The NSError object if any error occurred during the operation
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)synchronize:(NSError **)error{
    NSString *methodName = [NSString stringWithFormat:@"%@.synchronize:", NSStringFromClass(self.class)];
  
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"synchronize:"] params:nil];

    PGCoreData *coreData = [PGCoreData instance];
    if (![coreData isConnected]) {
        if (![coreData connect]) {
            return NO;
        }
    }
    PGConnection *connection = coreData.pgConnection;

    User *loggedInUser = AppDelegate.shareDelegate.loggedInUser;
    if (loggedInUser && ![Helper checkLock:loggedInUser]) {
        [Helper showAlert:@"Error"
                  message:@"Admin user has removed lock."];

        [[NSNotificationCenter defaultCenter] postNotificationName:ForceLogoutEvent object:nil];

        return NO;
    }

    // Lock on the managedObjectContext
    [[self managedObjectContext] lock];

    NSError *e = nil;
    
    // Save any pending data
    [[self managedObjectContext] processPendingChanges];
    if (![self.managedObjectContext save:&e]) {
        CHECK_ERROR_AND_RETURN(e, error, @"Cannot save managed object context.", DataUpdateErrorCode, YES, NO);
    }

    // fetch all new objects from other devices
    NSArray *allData = [coreData fetchObjects];
    BOOL hasData = allData && allData.count > 0;
    NSMutableArray *postponedObjects = [NSMutableArray array];

    // check for unsychronized objects
    NSArray *d = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel.entities;
    NSArray *sd = [d sortedArrayWithOptions:0 usingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSEntityDescription *v1 = (NSEntityDescription *) obj1;
        NSEntityDescription *v2 = (NSEntityDescription *) obj2;
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @1, @"StringWrapper",
                              @2, @"FoodProductFilter",
                              @3, @"User",
                              @4, @"FoodProduct",
                              @5, @"AdhocFoodProduct",
                              @5, @"FoodConsumptionProduct", nil];
        NSNumber *n1 = [dict objectForKey:v1.name];
        n1 = n1 == nil ? @100 : n1;
        NSNumber *n2 = [dict objectForKey:v2.name];
        n2 = n2 == nil ? @100 : n2;
        
        return [n1 compare:n2];
    }];
    
    NSInteger totalChange = 0;
    for (NSEntityDescription *description in sd) {
        if ([description.name isEqualToString:@"PGManagedObject"] ||
            [description.name isEqualToString:@"SynchronizableModel"]||
            [description.name isEqualToString:@"FoodProduct"]) {
            continue;
        }
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(synchronized == NO)"];
        [request setEntity:description];
        [request setPredicate:predicate];
        
        NSArray *objects = [self.managedObjectContext executeFetchRequest:request error:&e];
        CHECK_ERROR_AND_RETURN(e, error, @"Cannot fetch request.", DataUpdateErrorCode, YES, NO);
        
        for (SynchronizableModel *object in objects) {
            NSNumber *synced = object.synchronized;
            if (synced && ![synced boolValue]) {
                if (hasData && [self hasObject:allData object:object]) {
                    // has server changes - merge from server and update later
                    [postponedObjects addObject:object];
                } else {
                    NSLog(@"Not synchronized %@", object);
                    if ([object updateObjects:connection] && [self saveMedia:object]) {
                        // success
                        [object setSynchronized:@YES];
                        totalChange++;
                    } else {
                        return NO;
                    }
                }
            }
        }
    }

    if (totalChange > 0) {
        [self updateSyncTime:[[NSDate date] timeIntervalSince1970] * 1000];
    }

    if (![self.managedObjectContext save:&e]) {
        CHECK_ERROR_AND_RETURN(e, error, @"Cannot save managed object context.", DataUpdateErrorCode, YES, NO);
    }

    if (hasData) {
        for (NSDictionary *data in allData) {
            [self startUndoActions];
            
            NSString *oId = [data objectForKey:@"id"];
            NSString *name = [data objectForKey:@"name"];
            NSString *value = [data objectForKey:@"value"];
            
            // Convert from JSON
            NSData *jsonData = [value dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
            CHECK_ERROR_AND_RETURN(e, error, @"Cannot convert JSON data to managed object.", DataUpdateErrorCode, YES, YES);
            
            [LoggingHelper logDebug:methodName message:[NSString stringWithFormat:@"JSON for %@ dict %@", name,
                                                        jsonDictionary]];
            
            // Check if object already exists
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(uuid == %@)", oId];
            NSEntityDescription *description = [NSEntityDescription entityForName:name
                                                           inManagedObjectContext:[self managedObjectContext]];
            [request setEntity:description];
            [request setPredicate:predicate];
            NSArray *objects = [self.managedObjectContext executeFetchRequest:request error:&e];
            CHECK_ERROR_AND_RETURN(e, error, @"Cannot fetch object in managed object context.",
                                   EntityNotFoundErrorCode, YES, YES);
            
            // Update if objects exists or insert if it doesn't (only for not removed object)
            // hack for admin tool
            BOOL isRemoved = [[jsonDictionary objectForKey:@"removed"] boolValue] && ![name isEqualToString:@"FoodProduct"];
            if (objects.count > 0) {
                SynchronizableModel *object = [objects objectAtIndex:0];
                if (isRemoved) {
                    [self.managedObjectContext deleteObject:object];
                } else {
                    if (![DataHelper updateObjectWithJSON:jsonDictionary object:object
                                     managegObjectContext:self.managedObjectContext]) {
                        e = [NSError errorWithDomain:@"Domain" code:DataUpdateErrorCode userInfo:nil];
                        CHECK_ERROR_AND_RETURN(e, error, @"Cannot update object.", DataUpdateErrorCode, YES, YES);
                    }

                    NSLog(@"Updated object %@", object);

                    NSManagedObjectID *currentUserId = AppDelegate.shareDelegate.loggedInUser.objectID;
                    if ([object isKindOfClass:[User class]] && [object.objectID isEqual:currentUserId]) {
                        AppDelegate.shareDelegate.loggedInUser = (User *) object;
                        [[NSNotificationCenter defaultCenter] postNotificationName:CurrentUserUpdateEvent object:nil];
                    }
                }
            } else if (!isRemoved) {
                if (![DataHelper convertJSONToObject:oId jsonValue:jsonDictionary name:name
                                managegObjectContext:self.managedObjectContext]) {
                    e = [NSError errorWithDomain:@"Domain" code:DataUpdateErrorCode userInfo:nil];
                    CHECK_ERROR_AND_RETURN(e, error, @"Cannot insert object.", DataUpdateErrorCode, YES, YES);
                }
            }

            [self endUndoActions];
            if (![self.managedObjectContext save:&e]) {
                CHECK_ERROR_AND_RETURN(e, error, @"Cannot save managed object context.", DataUpdateErrorCode, YES, NO);
            }
        }
        
        [self updateSyncTime:[[NSDate date] timeIntervalSince1970] * 1000];
    }
    
    // clear sync table
    [coreData clearObjectSyncData];

    // fetch media (audio / images) information
    NSArray *dataFiles = [coreData fetchMedias];
    for (NSDictionary *dictFile in dataFiles) {
        NSString *dataFile = [dictFile objectForKey:@"filename"];
        NSData *data = [dictFile objectForKey:@"data"];
        if([dataFile hasSuffix:self.imageFileNameSuffix]
           || [dataFile hasSuffix:self.voiceRecordingFileNameSuffix]) {
            if ([dataFile hasSuffix:self.imageFileNameSuffix] && [UIImage imageWithData:data] == nil) {
                e = [NSError errorWithDomain:@"Domain" code:DataUpdateErrorCode userInfo:nil];
                CHECK_ERROR_AND_RETURN(e, error, @"Not an valid image.", DataUpdateErrorCode, YES, NO);
            }
            
            NSString *localDataFile = [[DataHelper getAbsoulteLocalDirectory:self.localFileSystemDirectory]
                                       stringByAppendingPathComponent:dataFile];
            if (![data writeToFile:localDataFile options:NSDataWritingAtomic error:&e]) {
                CHECK_ERROR_AND_RETURN(e, error, @"Cannot save file to local folder.", DataUpdateErrorCode, YES, NO);
            }
        }
    }
    
    // clear sync table
    [coreData clearMediaSyncData];

    // will merge the local changes to database
    totalChange = 0;
    for (SynchronizableModel *object in postponedObjects) {
        object.synchronized = @NO;
        NSLog(@"Not synchronized %@", object);
        if ([object updateObjects:connection] && [self saveMedia:object]) {
            // success
            [object setSynchronized:@YES];
            totalChange++;
        } else {
            return NO;
        }
    }

    if (totalChange > 0) {
        [self updateSyncTime:[[NSDate date] timeIntervalSince1970] * 1000];
    }

    // Unlock the managedObjectContext
    [[self managedObjectContext] unlock];

    // Update progress
    [self updateProgress:@1.0];
    
    [LoggingHelper logMethodExit:methodName returnValue:@YES];
    
    return YES;
}

- (BOOL)saveMedia:(SynchronizableModel *) object {
    NSString *value = @"";
    if ([object isKindOfClass:[StringWrapper class]]) {
        value = [(StringWrapper *) object value];
    } else if ([object isKindOfClass:[FoodProduct class]] || [object isKindOfClass:[AdhocFoodProduct class]]) {
        value = [(FoodProduct *) object productProfileImage];
    } else if ([object isKindOfClass:[User class]]) {
        value = [(User *) object profileImage];
    }
    
    if ([value hasSuffix:self.imageFileNameSuffix] || [value hasSuffix:self.voiceRecordingFileNameSuffix]) {
        NSString *localPath = [[DataHelper getAbsoulteLocalDirectory:self.localFileSystemDirectory]
                               stringByAppendingPathComponent:value];
        NSData *data = [NSData dataWithContentsOfFile:localPath];
        if (data && data.length > 0) {
            return [[PGCoreData instance] saveMedia:data fileName:value];
        }
    }
    
    return YES;
}

- (BOOL)hasObject:(NSArray *) array object:(SynchronizableModel *) object {
    for (NSDictionary *dict in array) {
        if ([[dict objectForKey:@"id"] isEqualToString:object.uuid]) {
            return YES;
        }
    }
    return NO;
}

@end
