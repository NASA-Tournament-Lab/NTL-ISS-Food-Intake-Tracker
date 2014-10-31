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
//  UserApplicationDataViewController.h
//  FoodIntakeTracker
//
//  Created by lofzcx 06/25/2013
//

#import <UIKit/UIKit.h>
#import "CustomTabBarViewController.h"
#import "CustomTableViewController.h"

/**
 * @class UserApplicationDataFoodTableCell
 * Table cell for profile data page's consumption table.
 *
 * Changes in 1.1
 * - Added business logic
 *
 * @author lofzcx, flying2hk, subchap
 * @version 1.1
 * @since 1.0
 */
@interface UserApplicationDataFoodTableCell : UITableViewCell

/* the time label */
@property (weak, nonatomic) IBOutlet UILabel *lblDay;
/* the time label */
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
/* the name label */
@property (weak, nonatomic) IBOutlet UILabel *lblName;
/* the quantity label */
@property (weak, nonatomic) IBOutlet UILabel *lblQuantity;
/* the quantity unit label */
@property (weak, nonatomic) IBOutlet UILabel *lblQuantityUnit;
/* the comment button */
@property (weak, nonatomic) IBOutlet UIButton *btnComment;
/* the food item */
@property (strong, nonatomic) FoodConsumptionRecord *foodConsumptionRecord;

@end

/**
 * @class UserApplicationDataViewController
 * controller for Profile data page view.
 *
 * Changes in 1.1
 * - Added business logic
 *
 * @author lofzcx, flying2hk, subchap
 * @version 1.1
 * @since 1.0
 */
@interface UserApplicationDataViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, CustomTableViewDelegate,
UIPopoverControllerDelegate> {
    /* Represents the food consumption records for selected user. */
    NSMutableArray *foodConsumptionRecords;

    /* Represents the users. */
    NSMutableArray *users;
}

/* the tab bar controller */
@property (weak, nonatomic) CustomTabBarViewController *customTabBarController;
/* the profile and consumption segment control */
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
/* the profile title label */
@property (weak, nonatomic) IBOutlet UILabel *lblSegLeftTitle;
/* the consumption title label */
@property (weak, nonatomic) IBOutlet UILabel *lblSegRightTitle;
/* the head title label */
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
/* the selected user name */
@property (weak, nonatomic) IBOutlet UILabel *lblSelectedUserName;
/* the selected user photo image view */
@property (weak, nonatomic) IBOutlet UIImageView *imgSelectedUserPhoto;
/* the search bar */
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
/* the user list table */
@property (weak, nonatomic) IBOutlet UITableView *userListTable;
/* the left part of the view */
@property (weak, nonatomic) IBOutlet UIView *leftView;

/* the profile view */
@property (weak, nonatomic) IBOutlet UIView *profileView;
/* the profile photo */
@property (weak, nonatomic) IBOutlet UIImageView *imgProfilePhoto;
/* the profile table */
@property (weak, nonatomic) IBOutlet UIView *profileTable;
/* the profile firstname label */
@property (weak, nonatomic) IBOutlet UILabel *lblProfileFirstName;
/* the profile lastname label */
@property (weak, nonatomic) IBOutlet UILabel *lblProfileLastName;

/* the consumption view */
@property (weak, nonatomic) IBOutlet UIView *consumptionView;
/* the cosnumption table */
@property (weak, nonatomic) IBOutlet UITableView *consumptionTable;

/* the comment view */
@property (weak, nonatomic) IBOutlet UIView *commentView;
/* the comment text view */
@property (weak, nonatomic) IBOutlet UITextView *commentText;
/* the suggestion table view */
@property (strong, nonatomic) SuggestionTableView *suggestionTableView;

/**
 * return back to summary view.
 * @param sender the button.
 */
- (IBAction)viewSummary:(id)sender;

/**
 * hide the comment popup
 */
- (void)hideFoodComment;
/**
 * show the comment popup and set comment text.
 * @param sender the button.
 */
- (void)showFoodComment:(id)sender;
/**
 * change between profile and consumption view.
 * @param sender the segment control.
 */
- (IBAction)segmentValueChanged:(id)sender;
@end
