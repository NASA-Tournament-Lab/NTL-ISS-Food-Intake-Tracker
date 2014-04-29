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
//  DBHelper.m
//  Hercules Personal Content DVR
//
//  Created by namanhams on 3/9/13.
//

#import "DBHelper.h"
#import "DataHelper.h"
#import "NSError+Extension.h"
#import "AppDelegate.h"

@implementation DBHelper

static NSPersistentStoreCoordinator *persistentStoreCoordinator = nil;

static NSMutableDictionary *mocs = nil;
static NSMutableDictionary *mocThreads = nil;
static int counter;
static dispatch_queue_t serialQueue;

+ (void) initialize {
    
    serialQueue = dispatch_queue_create("SerialQueue", DISPATCH_QUEUE_SERIAL);

    mocs = [[NSMutableDictionary alloc] init];
    mocThreads = [[NSMutableDictionary alloc] init];
    counter = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mergeChanges:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(threadWillExit:)
                                                 name:NSThreadWillExitNotification
                                               object:nil];
}

+ (NSManagedObjectContext *) currentThreadMoc {
    static NSString *key = @"Moc";
    NSThread *currentThread = [NSThread currentThread];
    NSMutableDictionary *threadDictionary = [currentThread threadDictionary];
    if(! [threadDictionary valueForKey:key]) {
        NSManagedObjectContext *moc = [self createNewMoc];
        [threadDictionary setValue:moc forKey:key];
    }
    
    return [threadDictionary valueForKey:key];
}

+ (NSManagedObjectContext*) createNewMoc {
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        NSManagedObjectContext *newManagedObjectContext = [NSManagedObjectContext new];
        [newManagedObjectContext setPersistentStoreCoordinator: coordinator];
        [newManagedObjectContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
        
        NSThread *currentThread = [NSThread currentThread];
        __block NSString *name = [currentThread name];
        if([name length] == 0) {
            dispatch_async(serialQueue, ^{
                name = [NSString stringWithFormat:@"%d", ++counter];
                [mocs setValue:newManagedObjectContext forKey:name];
                [mocThreads setValue:currentThread forKey:name];
                [currentThread setName:name];
            });
        }
        else {
            dispatch_async(serialQueue, ^{
                [mocs setValue:newManagedObjectContext forKey:name];
                [mocThreads setValue:currentThread forKey:name];
            });
        }
        
        
//        NSLog(@"Create new moc on thread %@", name);
		return newManagedObjectContext;
    }
	return nil;
}

+ (void) threadWillExit:(NSNotification *)notification
{
    NSThread *exitingThread = [notification object];
    
    [self destroyManagedObjectContextForThreadName:[exitingThread name]];
}

+ (void) destroyManagedObjectContextForThreadName:(NSString *)name
{
    dispatch_async(serialQueue, ^{
        if (name != nil && [mocs objectForKey:name] != nil) {
            [mocs removeObjectForKey:name];
            [mocThreads removeObjectForKey:name];
        }
    });
}

+ (void) saveMoc {
    NSError *error = nil;
    if(! [[self currentThreadMoc] save:&error]) 
        [error showAllDetails];
}

+ (void) mergeChanges:(NSNotification *)notif {
    
    NSManagedObjectContext *mocThatSendNotification = [notif object];
    
    NSThread *mainThread = [NSThread mainThread];
    NSString *mainThreadName = [mainThread name];
    NSManagedObjectContext *mainThreadMoc = [mocs valueForKey:mainThreadName];
    
    if(mocThatSendNotification == mainThreadMoc) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"Merge changes back to main thread");
        
        @try {
            [mainThreadMoc mergeChangesFromContextDidSaveNotification:notif];
        }
        @catch (NSException *exception) {
            NSLog(@"****    [DbHelper mergeChanges:] exception: %@", exception);
        }
        @finally {
            
        }
    });
    
}

#pragma mark Setup


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths lastObject];
        NSString* persistentStorePath = [documentsDirectory stringByAppendingPathComponent:@"NasaIssFit.sqlite"];
        NSError *error = nil;
        
        NSString *configBundle = [[NSBundle mainBundle] pathForResource:@"Configuration" ofType:@"plist"];
        NSDictionary *configuration = [NSDictionary dictionaryWithContentsOfFile:configBundle];

        // create pre-load data
        if([configuration[@"CreatePreloadApplicationData"] boolValue]) {
            // clean local storage if necessary
            if([[NSFileManager defaultManager] fileExistsAtPath:persistentStorePath]) {
                [[NSFileManager defaultManager] removeItemAtPath:persistentStorePath error:&error];
            }
            
            NSString *localFileSystemFolder = [DataHelper
                                               getAbsoulteLocalDirectory:configuration[@"LocalFileSystemDirectory"]];
            NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:localFileSystemFolder error:&error];
            for (NSString *file in files) {
                [[NSFileManager defaultManager] removeItemAtPath:file error:&error];
            }
            
        }
        // load pre-load data
        else  if(![[NSFileManager defaultManager] fileExistsAtPath:persistentStorePath]) {
            
            NSBundle *bundle = [NSBundle bundleForClass:[self class]];
            NSString *localFolder = [bundle pathForResource:@"application_data/data" ofType:@""];
            NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:localFolder error:&error];
            NSString *localFileSystemFolder = [DataHelper
                                               getAbsoulteLocalDirectory:[AppDelegate shareDelegate].configuration[@"LocalFileSystemDirectory"]];
            for (NSString *file in files) {
                NSString *destFilePath = [localFileSystemFolder stringByAppendingPathComponent:file.lastPathComponent];
                [[NSFileManager defaultManager] copyItemAtPath:[localFolder stringByAppendingPathComponent:file]
                                                        toPath:destFilePath error:&error];
            }
            
            NSString *sqlFile = [bundle pathForResource:@"application_data/NasaIssFit.sqlite" ofType:@""];
            [[NSFileManager defaultManager] copyItemAtPath:sqlFile
                                                    toPath:persistentStorePath error:&error];
            
            
        }
        
        NSURL *storeUrl = [NSURL fileURLWithPath:persistentStorePath];
        persistentStoreCoordinator =
        [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[NSManagedObjectModel mergedModelFromBundles:nil]];
        
        NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES};
        
        NSPersistentStore *persistentStore =
        [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                 configuration:nil
                                                           URL:storeUrl
                                                       options:options
                                                         error:&error];
        if (persistentStore == nil) {
            NSLog(@"Store Configuration Failure\n%@",
                  ([error localizedDescription] != nil) ?
                  [error localizedDescription] : @"Unknown Error");
        }
    });
	
    return persistentStoreCoordinator;
}

@end
