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
//  CustomTabBarViewController.m
//  FoodIntakeTracker
//
//  Created by lofzcx 06/12/2013
//

#import "CustomTabBarViewController.h"
#import "HelpSettingViewController.h"
#import "ConsumptionViewController.h"
#import "UserApplicationDataViewController.h"
#import "ManageUserProfileViewController.h"
#import "AppDelegate.h"
#import "UserServiceImpl.h"
#import "Helper.h"
#import "Settings.h"

@interface CustomTabBarViewController (){
    ConsumptionViewController *consumptionController;
    HelpSettingViewController *helpSettingController;
    UINavigationController *consumptionNav;
    UserApplicationDataViewController *userApplicationData;
    ManageUserProfileViewController *manageUserProfile;
    BOOL admin;
}

@end

@implementation CustomTabBarViewController

/**
 * overwrite this method to load view controllers here and define default values.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIStoryboard*  sb = self.storyboard;
    
    helpSettingController = [sb instantiateViewControllerWithIdentifier:@"HelpSettingView"];
    
    [self.view insertSubview:helpSettingController.view belowSubview:self.tabView];
    helpSettingController.view.frame = CGRectMake(0, 0, 768, 1004);
    helpSettingController.customTabBarController = self;
    
    consumptionController = [sb instantiateViewControllerWithIdentifier:@"ConsumptionView"];
    consumptionController.customTabBarController = self;
    
    consumptionNav = [[UINavigationController alloc] initWithRootViewController:consumptionController];
    [self.view insertSubview:consumptionNav.view belowSubview:self.tabView];
    consumptionNav.view.frame = CGRectMake(0, 0, 768, 1004);
    [consumptionNav setNavigationBarHidden:YES];
    
    [self.btnHelp addTarget:self
                     action:@selector(setHelpSettingActive)
           forControlEvents:UIControlEventTouchUpInside];
    
    [self.btnConsumption addTarget:self
                            action:@selector(setConsumptionActive)
                  forControlEvents:UIControlEventTouchUpInside];
    
    [self.btnData addTarget:self
                            action:@selector(setUserDataActive)
                  forControlEvents:UIControlEventTouchUpInside];
    
    [self.btnProfile addTarget:self
                            action:@selector(setProfileActive)
                  forControlEvents:UIControlEventTouchUpInside];
    
    [self.btnLogout addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    [self setAdmin:admin];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *lastSyncTime = [defaults objectForKey:@"LastSynchronizedTime"];
    if(lastSyncTime != nil) {
        [self updateLastSyncLabel:[NSDate
                                   dateWithTimeIntervalSince1970:[lastSyncTime longLongValue]/1000]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renewAutoLogout)
                                                 name:AutoLogoutRenewEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startAutoLogout)
                                                 name:AutoLogoutStartEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAutoLogout)
                                                 name:AutoLogoutStopEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLastSyncLabel:)
                                                 name:UpdateLastSync object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:AutoLogoutRenewEvent object:nil];
}

/**
 * action for logout button.
 */
- (void)logout{
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    UserServiceImpl *userService = appDelegate.userService;
    if (appDelegate.loggedInUser) {
        NSError *error;
        [userService logoutUser:appDelegate.loggedInUser error:&error];
        appDelegate.loggedInUser = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 * set the consumption view as active view.
 */
- (void)setConsumptionActive{
    if(self.activeTab == 1){
        return;
    }
    
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    if (!appDelegate.loggedInUser) {
        [Helper showAlert:@"Error" message:@"Please login to perform this functionality."];
        return;
    }
    appDelegate.tabBarViewController = self;
    
    self.activeTab = 1;
    
    [self.view bringSubviewToFront:consumptionNav.view];
    [self.view bringSubviewToFront:self.tabView];
    
    [consumptionNav popToRootViewControllerAnimated:YES];
    
    consumptionNav.view.hidden = NO;
    helpSettingController.view.hidden = YES;
    userApplicationData.view.hidden = YES;
    manageUserProfile.view.hidden = YES;
    
    [self.btnHelp setImage:nil forState:UIControlStateNormal];
    [self.btnProfile setImage:nil forState:UIControlStateNormal];
    [self.btnData setImage:nil forState:UIControlStateNormal];
    [self.btnConsumption setImage:[UIImage imageNamed:@"icon-tab-active.png"] forState:UIControlStateNormal];
    
    self.imgConsumption.image = [UIImage imageNamed:@"icon-consumption-active.png"];
    self.imgHelp.image = [UIImage imageNamed:@"icon-help-setting.png"];
    self.imgData.image = [UIImage imageNamed:@"icon-data.png"];
    self.imgProfile.image = [UIImage imageNamed:@"icon-profile.png"];
    
    [consumptionController viewWillAppear:YES];
}

/**
 * Get the currently selected date
 * @return the date
 */
- (NSDate *)currentSelectedDate{
    return consumptionController.dateListView.currentDate;
}

/**
 * Get the consumption view controller
 * @return the consumption view controller
 */
- (ConsumptionViewController *)getConsumptionViewController{
    return consumptionController;
}

/**
 * set the help setting view as active view.
 */
- (void)setHelpSettingActive{
    if(self.activeTab == 4){
        return;
    }
    self.activeTab = 4;
    
    [self.view bringSubviewToFront:helpSettingController.view];
    [self.view bringSubviewToFront:self.tabView];
    
    consumptionNav.view.hidden = YES;
    helpSettingController.view.hidden = NO;
    userApplicationData.view.hidden = YES;
    manageUserProfile.view.hidden = YES;
    
    [self.btnConsumption setImage:nil forState:UIControlStateNormal];
    [self.btnProfile setImage:nil forState:UIControlStateNormal];
    [self.btnData setImage:nil forState:UIControlStateNormal];
    [self.btnHelp setImage:[UIImage imageNamed:@"icon-tab-active.png"] forState:UIControlStateNormal];
    
    self.imgConsumption.image = [UIImage imageNamed:@"icon-consumption.png"];
    self.imgHelp.image = [UIImage imageNamed:@"icon-help-setting-active.png"];
    self.imgData.image = [UIImage imageNamed:@"icon-data.png"];
    self.imgProfile.image = [UIImage imageNamed:@"icon-profile.png"];
    
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    if (!appDelegate.loggedInUser) {
        // Not logged in
        self.lblLogout.text = @"Login";
    }
    else {
        self.lblLogout.text = @"Logout";
    }
    [helpSettingController viewWillAppear:YES];
}

/**
 * set user data view as active view.
 */
- (void)setUserDataActive{
    if(self.activeTab == 3){
        return;
    }
    
    self.activeTab = 3;
    
    [self.view bringSubviewToFront:userApplicationData.view];
    [self.view bringSubviewToFront:self.tabView];
    
    consumptionNav.view.hidden = YES;
    helpSettingController.view.hidden = YES;
    userApplicationData.view.hidden = NO;
    manageUserProfile.view.hidden = YES;
    
    [self.btnConsumption setImage:nil forState:UIControlStateNormal];
    [self.btnHelp setImage:nil forState:UIControlStateNormal];
    [self.btnProfile setImage:nil forState:UIControlStateNormal];
    [self.btnData setImage:[UIImage imageNamed:@"icon-tab-active.png"] forState:UIControlStateNormal];
    
    self.imgConsumption.image = [UIImage imageNamed:@"icon-consumption.png"];
    self.imgHelp.image = [UIImage imageNamed:@"icon-help-setting.png"];
    self.imgData.image = [UIImage imageNamed:@"icon-data.png"];
    self.imgProfile.image = [UIImage imageNamed:@"icon-profile-active.png"];
    
    [userApplicationData viewWillAppear:YES];
}

/**
 * set profile view as active view
 */
- (void)setProfileActive{
    
    if(self.activeTab == 2){
        return;
    }
    self.activeTab = 2;
    
    [self.view bringSubviewToFront:manageUserProfile.view];
    [self.view bringSubviewToFront:self.tabView];
    
    consumptionNav.view.hidden = YES;
    helpSettingController.view.hidden = YES;
    userApplicationData.view.hidden = YES;
    manageUserProfile.view.hidden = NO;
    
    [self.btnConsumption setImage:nil forState:UIControlStateNormal];
    [self.btnHelp setImage:nil forState:UIControlStateNormal];
    [self.btnData setImage:nil forState:UIControlStateNormal];
    [self.btnProfile setImage:[UIImage imageNamed:@"icon-tab-active.png"] forState:UIControlStateNormal];
    
    self.imgConsumption.image = [UIImage imageNamed:@"icon-consumption.png"];
    self.imgHelp.image = [UIImage imageNamed:@"icon-help-setting.png"];
    self.imgData.image = [UIImage imageNamed:@"icon-data-active.png"];
    self.imgProfile.image = [UIImage imageNamed:@"icon-profile.png"];
    
    [manageUserProfile viewWillAppear:YES];
}

/**
 * add control for show and hide data and profile tab by user's role (Admin or not)
 */
- (void)setAdmin:(BOOL)isAdmin{
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    admin = isAdmin;
    if(userApplicationData == nil && isAdmin){
        userApplicationData = [self.storyboard instantiateViewControllerWithIdentifier:@"UserApplicationDataView"];
        [self.view insertSubview:userApplicationData.view atIndex:0];
        userApplicationData.view.frame = CGRectMake(0, 0, 768, 1004);
        userApplicationData.customTabBarController = self;
    }
    if (manageUserProfile == nil && appDelegate.loggedInUser) {
        manageUserProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"ManageUserProfileView"];
        [self.view insertSubview:manageUserProfile.view atIndex:0];
        manageUserProfile.view.frame = CGRectMake(0, 0, 768, 1004);
        manageUserProfile.customTabBarController = self;
    }

    if(isAdmin){
        int sizeW = 120 * 4 + 97;
        int startX = 768 / 2 - (sizeW / 2);
        for(int i = 0; i < 5; i++){
            UIView *v = [self.tabView viewWithTag:100 + i];
            v.hidden = NO;
            v.frame = CGRectMake(startX, 0, 97, 72);
            startX += 120;
        }
    }
    else{
        int nViews = 3;
        if (!appDelegate.loggedInUser) {
            nViews = 2;
        }
        int sizeW = 120 * nViews + 97;
        if (!appDelegate.loggedInUser) sizeW = 120 + 97;
        int startX = 768 / 2 - (sizeW / 2);
        for(int i = 0; i < 5; i++){
            UIView *v = [self.tabView viewWithTag:100 + i];
            if(i == 1){
                v.hidden = YES;
                continue;
            }
            if (!appDelegate.loggedInUser && (i == 0 || i == 2)) {
                v.hidden = YES;
                continue;
            }
            
            v.frame = CGRectMake(startX, 0, 97, 72);
            startX += 120;
        }
    }
}

/**
 * Check if the login is admin or not.
 * @return YES for admin login. Othterwise NO.
 */
- (BOOL)isAdmin{
    return admin;
}

/*!
 * This method will renew auto logout.
 */
- (void) renewAutoLogout {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoLogout) object:nil];
    [self performSelector:@selector(autoLogout) withObject:nil afterDelay:300];
}

/*!
 * This method will renew auto logout.
 */
- (void) startAutoLogout {
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    appDelegate.shouldAutoLogout = YES;
    [self renewAutoLogout];
}

/*!
 * This method will renew auto logout.
 */
- (void) stopAutoLogout {
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    appDelegate.shouldAutoLogout = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoLogout) object:nil];
}

/*!
 * This method will auto logout.
 */
- (void) autoLogout {
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    if (appDelegate.shouldAutoLogout) {
        [self logout];
    }
}

/*!
 * Update last sync label.
 */
- (void)updateLastSyncLabel:(id) value {
    NSDate *date = nil;
    if ([value isKindOfClass:[NSDate class]]) {
        date = (NSDate *) value;
    } else {
        date = [(NSNotification *)value object];
    }
    if (date) {
        NSDateFormatter *f = [[NSDateFormatter alloc] init];
        [f setDateStyle:NSDateFormatterLongStyle];
        [f setTimeStyle:NSDateFormatterMediumStyle];
        
        @synchronized(self) {
            unichar chr[1] = {'\n'};
            NSString *singleCR = [NSString stringWithCharacters:(const unichar *)chr length:1];
            NSString *text = [NSString stringWithFormat:@"Last synced in:%@%@", singleCR,
                              [f stringFromDate:date]];
            [self.lastSyncLabel performSelectorOnMainThread:@selector(setText:)
                                                 withObject:text waitUntilDone:YES];
            f = nil;
        }
    }
}

@end
