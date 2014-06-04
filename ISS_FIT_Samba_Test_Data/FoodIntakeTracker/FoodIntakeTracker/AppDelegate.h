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
#import "LockService.h"
#import "FoodProductService.h"
#import "SpeechRecognitionService.h"
#import "FoodConsumptionRecordService.h"
#import "DataUpdateService.h"
#import "SynchronizationService.h"
#import "TouchWindow.h"
#import "CustomTabBarViewController.h"

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
@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

/* the window */
@property (strong, nonatomic) TouchWindow *window;


/*!
 @discussion Represents Tesseract data path.
 */
@property (strong, nonatomic) NSString *tesseractDataPath;

/*!
 @discussion Represents the local file system directory to save additional files (images, voice recordings).
 */
@property (strong, nonatomic) NSString *additionalFilesDirectory;

/*!
 @discussion Represents the UserService used in the application.
 */
@property (strong, nonatomic) id<UserService> userService;

/*!
 @discussion Represents the LockService used in the application.
 */
@property (strong, nonatomic) id<LockService> lockService;

/*!
 @discussion Represents the FoodProductService used in the application.
 */
@property (strong, nonatomic) id<FoodProductService> foodProductService;

/*!
 @discussion Represents the SpeechRecognitionService used in the application.
 */
@property (strong, nonatomic) id<SpeechRecognitionService> speechRecognitionService;

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
 @discussion Represents the timer for sending heartbeat.
 */
@property (strong, nonatomic) NSTimer *heartbeatTimer;

/*!
 @discussion Represents the timer for generating summary.
 */
@property (strong, nonatomic) NSTimer *summaryGenerationTimer;

/*!
 @discussion Represents the timer for checking for data sync/update.
 */
@property (strong, nonatomic) NSTimer *dataSyncUpdateTimer;

/*!
 @discussion Represents the summary generation frequency. Can be "Weekly", "Monthly".
 */
@property (strong, nonatomic) NSString *summaryGenerationFrequency;

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

@property (nonatomic, strong) NSMutableArray *mediaFiles;


+ (AppDelegate *) shareDelegate;

/*
 * This method will check if lock can be acquired.
 * @param action the action requested
 * @param sender the sender
 * @return whether the action can be performed
 */
- (BOOL) canPerformAction:(SEL)action withSender:(id)sender;

/*
 * This method will send heartbeat if the user is logged in.
 */
- (void) sendHeartbeat;

/*
 * This method will generate food consumption summary.
 */
//- (void) generateSummary;

/*
 * This method will do data sync/update.
 */
//- (void) doSyncUpdate;

@end
