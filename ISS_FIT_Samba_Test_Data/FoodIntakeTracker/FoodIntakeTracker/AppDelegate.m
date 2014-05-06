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
//  AppDelegate.m
//  FoodIntakeTracker
//
//  Created by lofzcx 06/12/2013
//
//  Updated by pvmagacho on 04/19/2014
//  F2Finish - NASA iPad App Updates
//

#import "AppDelegate.h"
#import "LockServiceImpl.h"
#import "UserServiceImpl.h"
#import "FoodProductServiceImpl.h"
#import "SpeechRecognitionServiceImpl.h"
#import "FoodConsumptionRecordServiceImpl.h"
#import "SynchronizationServiceImpl.h"
#import "DataUpdateServiceImpl.h"
#import "DataHelper.h"
#import "DBHelper.h"
#import "Settings.h"
#import "Helper.h"
#import "LoggingHelper.h"

typedef NS_ENUM(NSInteger, SyncStatus) {
    SyncStatusNone,
    
    SyncStatusStarted,
    SyncStatusFinished,
    SyncStatusError
} NS_ENUM_AVAILABLE_IOS(7_0);

/**
 * the application delegate
 *
 * @author lofzcx
 * @version 1.0
 */
@implementation AppDelegate {
    /*! Indicates whether the data loading is done. */
    BOOL loadingFinished;
    /*! Indicates if there was a server change. */
    BOOL changed;
    /*! Lock for change */
    NSLock *lock;
    /*! Synchronization status */
    SyncStatus status;
}

@synthesize tabBarViewController;

- (TouchWindow *)window
{
    static TouchWindow *customWindow = nil;
    if (!customWindow) customWindow = [[TouchWindow alloc] init];
    
    CGFloat systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(systemVersion < 7) {
        customWindow.frame = [[UIScreen mainScreen] bounds];
    }
    else {
        customWindow.frame = [[UIScreen mainScreen] applicationFrame];
    }
    
    return customWindow;
}

/**
 * following delegate methods is application delegate, overwrite to define action for application loaded, ended,
 * entering background, become active. For this assembly just leave these empty.
 *
 */

/*!
 * This method tells the delegate that the launch process is almost done and the app is almost ready to run.
 * @param application the delegating application object
 * @param launchOptions the launch options
 * @return NO if the application cannot handle the URL resource, otherwise return YES.
 The return value is ignored if the application is launched as a result of a remote notification.
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    status = SyncStatusNone;
    
    lock = [[NSLock alloc] init];
    [lock setName:@"UpdateLock"];
    
    //http://stackoverflow.com/questions/17678881/how-to-change-status-bar-text-color-in-ios-7
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (![standardUserDefaults objectForKey:@"address_preference"] ||
        ![standardUserDefaults objectForKey:@"user_preference"] ||
        ![standardUserDefaults objectForKey:@"password_preference"]) {
        [self registerDefaultsFromSettingsBundle];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSettingsChange:)
                                                 name:NSUserDefaultsDidChangeNotification object:nil];
    
    // Load configurations and create services
    NSString *configBundle = [[NSBundle mainBundle] pathForResource:@"Configuration" ofType:@"plist"];
    if (configBundle) {
        self.configuration = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:configBundle]];
        [self.configuration setObject:[standardUserDefaults objectForKey:@"address_preference"] forKey:@"SharedFileServerPath"];
        [self.configuration setObject:[standardUserDefaults objectForKey:@"user_preference"] forKey:@"SharedFileServerUsername"];
        [self.configuration setObject:[standardUserDefaults objectForKey:@"password_preference"] forKey:@"SharedFileServerPassword"];
        
        self.shouldAutoLogout = NO;
        loadingFinished = NO;
        
        self.lockService = [[LockServiceImpl alloc] initWithConfiguration:self.configuration];
        self.userService = [[UserServiceImpl alloc] initWithConfiguration:self.configuration
                                                              lockService:self.lockService];
        self.foodProductService = [[FoodProductServiceImpl alloc] init];
        self.speechRecognitionService = [[SpeechRecognitionServiceImpl alloc] initWithConfiguration:self.configuration];
        self.foodConsumptionRecordService = [[FoodConsumptionRecordServiceImpl alloc] initWithConfiguration:self.configuration];
        self.synchronizationService = [[SynchronizationServiceImpl alloc] initWithConfiguration:self.configuration];
        self.dataUpdateService = [[DataUpdateServiceImpl alloc] initWithConfiguration:self.configuration];
        
        self.additionalFilesDirectory = [self.configuration valueForKey:@"LocalFileSystemDirectory"];
        self.tesseractDataPath = [self.configuration valueForKey:@"TesseractDataPath"];
        self.helpData = [self.configuration objectForKey:@"HelpData"];
        self.summaryGenerationFrequency = [self.configuration objectForKey:@"SummaryGenerationFrequency"];
        
        [self performSelector:@selector(initialLoad) withObject:nil afterDelay:0.1];
        
        // Start timers
        self.heartbeatTimer =
        [NSTimer scheduledTimerWithTimeInterval:
         [[self.configuration valueForKey:@"HeartbeatInterval"] intValue]
                                         target:self
                                       selector:@selector(sendHeartbeat)
                                       userInfo:nil
                                        repeats:YES];
        self.summaryGenerationTimer =
        [NSTimer scheduledTimerWithTimeInterval:
         [[self.configuration valueForKey:@"SummaryGenerationInterval"] intValue]
                                         target:self
                                       selector:@selector(generateSummary)
                                       userInfo:nil
                                        repeats:NO];
        /*self.dataSyncUpdateTimer =
        [NSTimer scheduledTimerWithTimeInterval:
         [[self.configuration valueForKey:@"DataSyncUpdateInterval"] intValue]
                                         target:self
                                       selector:@selector(doSyncUpdate)
                                       userInfo:nil
                                        repeats:YES];*/
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doSyncUpdate)
                                                     name:@"DataSyncUpdateInterval" object:nil];
        return YES;
    } else {
        return NO;
    }
    
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of
    // temporary interruptions (such as an incoming phone call or SMS message) or
    // when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates.
    // Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application
    // state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of
    // applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state;
    // here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive.
    // If the application was previously in the background, optionally refresh the user interface.
    if (status == SyncStatusError && !loadingFinished) {
        [self initialLoad];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate.
    // See also applicationDidEnterBackground:.
}

+ (AppDelegate *) shareDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
/*!
 * This method will check if lock can be acquired.
 * @param action the action requested
 * @param sender the sender
 * @return whether the action can be performed
 */
- (BOOL) canPerformAction:(SEL)action withSender:(id)sender {
    if (YES) {
        if (!self.loggedInUser) return YES;
        else return NO;
    } else {
        if (self.loggedInUser) {
            // The error object
            NSError *error;
            // Acquire lock
            [self.lockService acquireLock:self.loggedInUser error:&error];
            if (error) {
                return NO;
            } else {
                return YES;
            }
        } else {
            return NO;
        }
    }
}

/*!
 * This method will send heartbeat if the user is logged in.
 */
- (void) sendHeartbeat {
    if (self.loggedInUser) {
        dispatch_queue_t heartBeatQ = dispatch_queue_create("Send Heart Beat", NULL);
        dispatch_async(heartBeatQ, ^{
            @autoreleasepool {
                //We do not use lock anymore
                //[self.lockService sendLockHeartbeat:self.loggedInUser error:nil];
            }
        });
        dispatch_release(heartBeatQ);
    }
}

/*!
 * This method will generate food consumption summary.
 */
- (void) generateSummary {
    dispatch_queue_t generateSummaryQ = dispatch_queue_create("Generate Summary", NULL);
    dispatch_async(generateSummaryQ, ^{
        @autoreleasepool {
            NSError *error = nil;
            NSArray *users = [self.userService filterUsers:@"" error:&error];
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDate *startDate;
            NSDate *endDate;
            if ([self.summaryGenerationFrequency isEqualToString:@"Weekly"]) {
                // Start date should be first day of last week, end date should be last day of last week.
                //NSDateComponents *comps = [NSDateComponents new];
                //comps.week = -1;
                NSDate *date = [NSDate date];
                NSDateComponents *components = [calendar components:NSYearCalendarUnit|
                                                NSWeekCalendarUnit
                                                           fromDate:date];
                components.weekday = 1;
                components.hour = 0;
                components.minute = 0;
                components.second = 0;
                startDate = [calendar dateFromComponents:components];
                components.weekday = 7;
                endDate = [calendar dateFromComponents:components];
            } else if ([self.summaryGenerationFrequency isEqualToString:@"Daily"]) {
                //NSDateComponents *comps = [NSDateComponents new];
                //comps.day = -1;
                NSDate *date = [NSDate date];
                NSDateComponents *components = [calendar components:NSYearCalendarUnit|
                                                NSDayCalendarUnit
                                                           fromDate:date];
                components.hour = 0;
                components.minute = 0;
                components.second = 0;
                startDate = [calendar dateFromComponents:components];
                
                components.hour = 23;
                components.minute = 59;
                components.second = 59;
                endDate = [calendar dateFromComponents:components];
            } else {
                // Monthly
                // Similarly, start date should be first day of last month, end date should be last day of last month
                //NSDateComponents *comps = [NSDateComponents new];
                //comps.month = -1;
                NSDate *date = [NSDate date];
                NSDateComponents *components = [calendar components:NSYearCalendarUnit|
                                                NSMonthCalendarUnit
                                                           fromDate:date];
                components.day = 1;
                components.hour = 0;
                components.minute = 0;
                components.second = 0;
                startDate = [calendar dateFromComponents:components];
                
                NSRange days = [calendar rangeOfUnit:NSDayCalendarUnit
                                              inUnit:NSMonthCalendarUnit
                                             forDate:date];
                components.day = days.length;
                endDate = [calendar dateFromComponents:components];
            }
            
            for (User *user in users) {
                [self.foodConsumptionRecordService generateSummary:user
                                                         startDate:startDate
                                                           endDate:endDate
                                                             error:&error];
            }
        }
    });
    dispatch_release(generateSummaryQ);
}

/*!
 * This method will generate a full food consumption summary.
 */
- (void) generateFullSummary {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"FullSummaryReady"]) {
        return;
    }
    
    dispatch_queue_t generateSummaryQ = dispatch_queue_create("Generate Full Summary", NULL);
    dispatch_async(generateSummaryQ, ^{
        @autoreleasepool {
            NSError *error = nil;
            NSArray *users = [self.userService filterUsers:@"" error:&error];
            
            for (User *user in users) {
                [self.foodConsumptionRecordService generateSummary:user
                                                         startDate:[NSDate dateWithTimeIntervalSince1970:0]
                                                           endDate:[NSDate date]
                                                             error:&error];
                if (error) {
                    [LoggingHelper logError:@"generateFullSummary" error:error];
                    return;
                }
            }
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FullSummaryReady"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    });
    dispatch_release(generateSummaryQ);
}

/*!
 * This method will do data sync/update.
 */
- (void) doSyncUpdate {
    // Skip the sync/update if the initial load is still in progress.
    if (loadingFinished) {
        dispatch_queue_t dataSyncUpdateQ = dispatch_queue_create("Data Sync Update", NULL);
        dispatch_async(dataSyncUpdateQ, ^{
            @autoreleasepool {
                NSError *error = nil;
                [self.dataUpdateService update:&error];
                if (!error) {
                    [self.synchronizationService synchronize:&error];
                    
                    [NSThread sleepForTimeInterval:0.5];
                    [self generateSummary];
                }
            }
        });
        dispatch_release(dataSyncUpdateQ);
    }
}

#pragma mark - Test Code

// Check if the app is started for the first time. If so, do some initializations.
- (void) initialLoad {
    status = SyncStatusStarted;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
        loadingFinished = YES;
        NSDictionary *loadingEndParam = @{@"success": [NSNumber numberWithBool:YES]};
        [[NSNotificationCenter defaultCenter] postNotificationName:InitialLoadingEndEvent
                                                            object:loadingEndParam];
        
        status = SyncStatusFinished;
        
        [self generateFullSummary];
        
        return;
    }
    
    loadingFinished = NO;
    __block BOOL syncSuccessful = YES;
    
    if (changed) {
        [[NSNotificationCenter defaultCenter] postNotificationName:LoadingNewBeginEvent object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:InitialLoadingBeginEvent object:nil];
    }
    
    dispatch_queue_t initialLoadQ = dispatch_queue_create("InitialLoad", NULL);
    dispatch_async(initialLoadQ, ^{
        @autoreleasepool {
            
            NSLog(@"Lock before update");
            [lock lock];
            
            NSError *error = nil;
            syncSuccessful = [self.dataUpdateService update:&error force:YES];
            [LoggingHelper logError:@"initialLoad" error:error];
            if (syncSuccessful) {
                syncSuccessful = [self.synchronizationService synchronize:&error];
                [LoggingHelper logError:@"initialLoad" error:error];
                
                if (syncSuccessful) {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [self generateFullSummary];
                }
            }
            
            if ([self.dataUpdateService cancelUpdate]) {
                [self.dataUpdateService setCancelUpdate:NO];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    loadingFinished = syncSuccessful;
                    NSDictionary *loadingEndParam = @{@"success": [NSNumber numberWithBool:syncSuccessful]};
                    [[NSNotificationCenter defaultCenter] postNotificationName:InitialLoadingEndEvent
                                                                            object:loadingEndParam];
                    
                    status = syncSuccessful ? SyncStatusFinished : SyncStatusError;
                });
            }
            
            NSLog(@"Unlock after update");
            [lock unlock];
        }
    });
    dispatch_release(initialLoadQ);
}

#pragma mark - NSUserDefaults

- (void)registerDefaultsFromSettingsBundle {
    // this function writes default settings as settings
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
            NSLog(@"writing as default %@ to the key %@",[prefSpecification objectForKey:@"DefaultValue"],key);
        }
    }
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*!
 * Handle change in ISS Fit settings.
 */
- (void)handleSettingsChange:(NSNotification *) notif {
    if (changed) {
        return;
    }
    
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (![self.configuration[@"SharedFileServerPath"] isEqualToString:[standardUserDefaults objectForKey:@"address_preference"]] ||
        ![self.configuration[@"SharedFileServerUsername"] isEqualToString:[standardUserDefaults objectForKey:@"user_preference"]] ||
        ![self.configuration[@"SharedFileServerPassword"] isEqualToString:[standardUserDefaults objectForKey:@"password_preference"]]) {
        changed = YES;
        
        [self.dataUpdateService setCancelUpdate:YES];
        
        [self.tabBarViewController logout];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:BackupBeginEvent object:nil];
        
        [self performSelectorInBackground:@selector(resetData) withObject:nil];
    }
}

/*!
 * Reset stored data in application.
 */
- (void)resetData {
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSError *error = nil;
    if (loadingFinished) {
        [NSThread sleepForTimeInterval:1];
        
        [self.synchronizationService backup:&error];
    }
    
    if (error) {
        return;
    }
    
    NSLog(@"Lock before reset");
    [lock lock];
    [DBHelper resetPersistentStore];
    NSLog(@"UnLock after reset");
    [lock unlock];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"HasLaunchedOnce"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"LastSynchronizedTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.configuration setObject:[standardUserDefaults objectForKey:@"address_preference"] forKey:@"SharedFileServerPath"];
    [self.configuration setObject:[standardUserDefaults objectForKey:@"user_preference"] forKey:@"SharedFileServerUsername"];
    [self.configuration setObject:[standardUserDefaults objectForKey:@"password_preference"] forKey:@"SharedFileServerPassword"];
    
    self.lockService = [[LockServiceImpl alloc] initWithConfiguration:self.configuration];
    self.userService = [[UserServiceImpl alloc] initWithConfiguration:self.configuration
                                                          lockService:self.lockService];
    self.foodProductService = [[FoodProductServiceImpl alloc] init];
    self.speechRecognitionService = [[SpeechRecognitionServiceImpl alloc] initWithConfiguration:self.configuration];
    self.foodConsumptionRecordService = [[FoodConsumptionRecordServiceImpl alloc] initWithConfiguration:self.configuration];
    self.synchronizationService = [[SynchronizationServiceImpl alloc] initWithConfiguration:self.configuration];
    self.dataUpdateService = [[DataUpdateServiceImpl alloc] initWithConfiguration:self.configuration];
    
    [self initialLoad];
    
    changed = NO;
}

@end
