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
//  CustomTabBarViewController.h
//  FoodIntakeTracker
//
//  Created by lofzcx 06/12/2013
//
#import <UIKit/UIKit.h>

@class ConsumptionViewController;

/**
 * Custom the tab bar controller for Consumption and Help page.
 *
 * Changes in 1.1
 * - add controller for data and profile tab.
 * - add control for show and hide data and profile tab by user's role (Admin or not)
 * - wrap the consumption with navigation controller.
 *
 * Changes in 1.2
 * - Added business logic
 *
 * @author lofzcx, flying2hk, subchap
 * @version 1.2
 * @since 1.0
 */
@interface CustomTabBarViewController : UIViewController<UIGestureRecognizerDelegate>

/* the help action link button */
@property (weak, nonatomic) IBOutlet UIButton *btnHelp;
/* the consumption link button */
@property (weak, nonatomic) IBOutlet UIButton *btnConsumption;
/* the image view for help tab */
@property (weak, nonatomic) IBOutlet UIImageView *imgHelp;
/* the image view for consumption tab */
@property (weak, nonatomic) IBOutlet UIImageView *imgConsumption;
/* the logout link button */
@property (weak, nonatomic) IBOutlet UIButton *btnLogout;
/* the bottom tab view */
@property (weak, nonatomic) IBOutlet UIView *tabView;

/* the help action link button */
@property (weak, nonatomic) IBOutlet UIButton *btnData;
/* the consumption link button */
@property (weak, nonatomic) IBOutlet UIButton *btnProfile;
/* the image view for help tab */
@property (weak, nonatomic) IBOutlet UIImageView *imgData;
/* the image view for consumption tab */
@property (weak, nonatomic) IBOutlet UIImageView *imgProfile;

/* the current select tab index */
@property (unsafe_unretained, nonatomic) NSInteger activeTab;

/* login user last name */
@property (strong, nonatomic) NSString *userLastName;
/* login user first name */
@property (strong, nonatomic) NSString *userFirstName;
/* the consumption logout label */
@property (weak, nonatomic) IBOutlet UILabel *lblLogout;

/* login user first name */
@property (strong, nonatomic) IBOutlet UILabel *lastSyncLabel;

/* disable tabbar */
@property (nonatomic, assign) BOOL disabledTab;

/**
 * add control for show and hide data and profile tab by user's role (Admin or not)
 */
- (void)setAdmin:(BOOL)isAdmin;

/**
 * Check if the login is admin or not.
 * @return YES for admin login. Othterwise NO.
 */
- (BOOL)isAdmin;

/**
 * set the consumption view as active view.
 */
- (void)setConsumptionActive;

/**
 * set the help setting view as active view.
 */
- (void)setHelpSettingActive;

/**
 * action for logout button.
 */
- (void)logout;

/**
 * set user data view as active view.
 */
- (void)setUserDataActive;

/**
 * set profile view as active view
 */
- (void)setProfileActive;

/**
 * Get the currently selected date
 * @return the date
 */
- (NSDate *)currentSelectedDate;

/**
 * Get the consumption view controller
 * @return the consumption view controller
 */
- (ConsumptionViewController *)getConsumptionViewController;

@end
