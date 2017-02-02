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
//  AppDelegate.h
//  FoodIntakeTracker
//
//  Created by lofzcx 06/12/2013
//
//  Updated by pvmagacho on 04/19/2014
//  F2Finish - NASA iPad App Updates
//
//  Updated by pvmagacho on 05/14/2014
//  F2Finish - NASA iPad App Updates - Round 3
//

#import <UIKit/UIKit.h>
#import "UserService.h"
#import "FoodProductService.h"
#import "FoodConsumptionRecordService.h"
#import "DataUpdateService.h"
#import "SynchronizationService.h"
#import "TouchWindow.h"
#import "CustomTabBarViewController.h"

/*! Dispatch queues */
static dispatch_queue_t dataSyncUpdateQ;

/**
 * the application delegate
 *
 * Changes in 1.1
 * - Added business logic
 *
 * @author lofzcx, flying2hk, subchap, pvmagacho
 * @version 1.2
 * @since 1.0
 */
@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate, UITextFieldDelegate>

/* the window */
@property (strong, nonatomic) TouchWindow *window;

/*!
 @discussion Represents the local file system directory to save additional files (images, voice recordings).
 */
@property (strong, nonatomic) NSString *additionalFilesDirectory;

/*!
 @discussion Represents the UserService used in the application.
 */
@property (strong, nonatomic) id<UserService> userService;

/*!
 @discussion Represents the FoodProductService used in the application.
 */
@property (strong, nonatomic) id<FoodProductService> foodProductService;

/*!
 @discussion Represents the FoodConsumptionRecordService used in the application.
 */
@property (strong, nonatomic) id<FoodConsumptionRecordService> foodConsumptionRecordService;

/*!
 @discussion Represents the SynchronizationService used in the application.
 */
@property (strong, nonatomic) id<SynchronizationService> synchronizationService;

/*!
 @discussion Represents the DataUpdateService used in the application.
 */
@property (strong, nonatomic) id<DataUpdateService> dataUpdateService;

/*!
 @discussion Represents the logged in user.
 */
@property (strong, nonatomic) User *loggedInUser;

/*!
 @discussion Represents help data. Keys of the dictionary are help item titles, 
 values are the HTML file names in the bundle.
 */
@property (strong, nonatomic) NSDictionary *helpData;

/*!
 @discussion Represents the timer for generating summary.
 */
@property (strong, nonatomic) NSTimer *summaryGenerationTimer;

/*!
 @discussion Represents the timer for checking for data sync/update.
 */
@property (strong, nonatomic) NSTimer *dataSyncUpdateTimer;

/*!
 @discussion Represents configuration data.  */
@property (strong, nonatomic) NSMutableDictionary *configuration;

/*!
 @discussion Represents whether the app should auto-logout.
 */
@property (assign, nonatomic) BOOL shouldAutoLogout;

/*!
 @discussion The navigation controller.
 */
@property (nonatomic,strong) CustomTabBarViewController *tabBarViewController;

/*!
 * This method will do data sync/update.
 */
- (void) doSyncUpdateWithBlock:(void (^) (BOOL) ) block;

/*!
 @discussion Remove user lock.
 */
- (void)removeUserLock;

/*!
 @discussion Check if user lock exists.
 * @param user the user to check.
 * @return true if lock was acquired or if user is already locked for this device, false otherwise.
 */
- (BOOL)checkLock:(User *)user;

/*!
 @discussion Try to acquire a user lock.
 * @param user the user to set new lock.
 * @return true if lock was acquired or if user is already locked for this device, false otherwise.
 */
- (NSInteger)acquireLock:(User *)user;

+ (AppDelegate *) shareDelegate;

@end
