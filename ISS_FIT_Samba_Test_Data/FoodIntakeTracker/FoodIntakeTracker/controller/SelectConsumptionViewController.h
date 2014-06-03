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
//  SelectConsumptionViewController.h
//  FoodIntakeTracker
//
//  Created by lofzcx 06/12/2013
//

#import <UIKit/UIKit.h>
#import "HelpSettingViewController.h"
#import "CustomTableViewController.h"

#define MAXROWS 10000

/**
 * @class SelectConsumptionViewController
 * controller for select consumption view.
 * view food items by category, sorting, fitering.
 *
 * Changes in 1.1
 * - Fix issue for index bar appears twice.
 *
 * Changes in 1.2
 * - Added business logic
 *
 * @author lofzcx, flying2hk, subchap
 * @version 1.2
 * @since 1.0
 */
@interface SelectConsumptionViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,
    UISearchBarDelegate, UIScrollViewDelegate, CustomTableViewDelegate, UIPopoverControllerDelegate>

/* the segment control indicates it is in list view or grid view */
@property (weak, nonatomic) IBOutlet UISegmentedControl *segListGrid;
/* the title label */
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
/* the add button */
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
/* the back button */
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
/* the sort dropdown button */
@property (weak, nonatomic) IBOutlet UILabel *lblSortBy;
/* the sub title label */
@property (weak, nonatomic) IBOutlet UILabel *lblSubTitle;
/* the left category table */
@property (weak, nonatomic) IBOutlet UITableView *leftTable;
/* the right view shwoing table */
@property (weak, nonatomic) IBOutlet UIView *rightView;
/* the search bar */
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
/* the right table view */
@property (weak, nonatomic) IBOutlet UITableView *rightTable;
/* the grid view */
@property (weak, nonatomic) IBOutlet UIView *gridView;
/* the info pop view */
@property (weak, nonatomic) IBOutlet UIView *infoView;
/* the info title label */
@property (weak, nonatomic) IBOutlet UILabel *lblInfoTitle;
/* the sort title label */
@property (weak, nonatomic) IBOutlet UILabel *lblSortTitle;
/* the change button */
@property (weak, nonatomic) IBOutlet UIButton *btnChange;

/* the scroll view that contains foods in grid view */
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
/* the option list view */
@property (weak, nonatomic) IBOutlet SettingListView *optionListView;
/* the selected food items */
@property (strong, nonatomic) NSMutableArray *selectFoods;
/* the suggestion table view */
@property (strong, nonatomic) SuggestionTableView *suggestionTableView;
/**
 * resize the right table view to make the nutirent view unvisible.
 */
- (void)swiperight;

/**
 * resize the right table view to make the nutirent view visible.
 */
- (void)swipeLeft:(UISwipeGestureRecognizer *)ges;

/**
 * show sort by option list pop.
 * @param sender the button.
 */
- (IBAction)showSortList:(id)sender;

/**
 * Change from sort/filter.
 * @param sender the button.
 */
- (IBAction)changeList:(id)sender;

/**
 * hide sort by option list.
 */
- (void)hideSortByOption;

/**
 * show the note info.
 * @param sender the button.
 */
- (IBAction)showInfo:(id)sender;

/**
 * hide the note info.
 * @param sender the button.
 */
- (IBAction)hideInfo:(id)sender;

#pragma mark - others

/**
 * select a food in the table list view.
 * @param sender the button.
 */
- (void)foodSelect:(id)sender;

/**
 * add to contumption and return back to consumption view.
 * @param sender the button.
 */
- (IBAction)addToConsumption:(id)sender;

/**
 * click food photo in the grid view.
 * @param btn the button.
 */
- (void)clickPhoto:(UIButton *)btn;

/**
 * load the grid view by food list.
 */
- (void)loadGridViews;

/**
 * change between list view and grid view.
 * @param sender the segment control.
 */
- (IBAction)listGridValueChanged:(id)sender;

@end
