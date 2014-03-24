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
//  HelpSettingViewController.h
//  FoodIntakeTracker
//
//  Created by lofzcx 05/03/2013
//

#import <UIKit/UIKit.h>
#import "CustomPickerViewController.h"

@class CustomTabBarViewController;
/**
 * login setting view in setting page.
 *
 * Changes in 1.1
 * - Added business logic
 *
 * @author lofzcx, flying2hk, subchap
 * @version 1.1
 * @since 1.0
 */
@interface SettingLoginView : UIView<UITableViewDataSource, UITableViewDelegate>{
}

/* the default logout setting list view */
@property (weak, nonatomic) IBOutlet UITableView *defaultLogout;
/* option: is photo login allowed */
@property (nonatomic, unsafe_unretained) BOOL photoLogin;
/* option: is credential login allowed */
@property (nonatomic, unsafe_unretained) BOOL credentialLogin;
/* the selected logout option index */
@property (nonatomic, unsafe_unretained) NSInteger logoutIndex;

@end

/**
 * delegate for setting list view. user when user select an option
 *
 * Changes in 1.1
 * - Added business logic
 *
 * @author lofzcx, flying2hk, subchap
 * @version 1.1
 * @since 1.0
 */
@protocol SettingListViewDelegate <NSObject>

/**
 * called when user select an option in the list view.
 */
- (void)listviewDidSelect:(int)index;

@end


/**
 * A table list view showing for user the select.
 *
 * Changes in 1.1
 * - Added business logic
 *
 * @author lofzcx, flying2hk, subchap
 * @version 1.1
 * @since 1.0
 */
@interface SettingListView : UIView<UITableViewDataSource, UITableViewDelegate>{
    
}

/* the list table view */
@property (weak, nonatomic) IBOutlet UITableView *listTable;
/* the options showing in the view */
@property (strong, nonatomic) NSMutableArray *options;
/* the selected index */
@property (nonatomic, unsafe_unretained) NSInteger selectIndex;
/* the delegate */
@property (weak, nonatomic) id<SettingListViewDelegate> delegate;

@end

/**
 * View controller for Help Setting page.
 * Use to manage user action in Help Ssetting Page.
 *
 * Changes in 1.1
 * - Added business logic
 *
 * @author lofzcx, flying2hk, subchap
 * @version 1.1
 * @since 1.0
 */
@interface HelpSettingViewController : UIViewController<CustomPickerViewDelegate, SettingListViewDelegate>

/* the tab bar controller */
@property (weak, nonatomic) CustomTabBarViewController *customTabBarController;
/* the header title label */
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
/* the left title label for segment */
@property (weak, nonatomic) IBOutlet UILabel *lblSegLeft;
/* the right title label for segment */
@property (weak, nonatomic) IBOutlet UILabel *lblSegRight;
/* the segment controller. It indicates what the current page is, help page or setting page */
@property (weak, nonatomic) IBOutlet UISegmentedControl *segHelpSetting;
/* the navigation table in the help page */
@property (weak, nonatomic) IBOutlet UITableView *helpItemList;
/* the navigation table in the setting page */
@property (weak, nonatomic) IBOutlet UITableView *settingItemList;

/* the login setting view */
@property (weak, nonatomic) IBOutlet SettingLoginView *settingLogin;
/* the filter setting view */
@property (weak, nonatomic) IBOutlet SettingListView *settingFilter;

/* detail view of help item */
@property (weak, nonatomic) IBOutlet UIWebView *helpDetailView;

/**
 * action for changing between help page and setting page 
 * @param sender the object sending message.
 */
- (IBAction)segmentValueChanged:(id)sender;

@end
