//
//  PhotoListViewController.h
//  FoodIntakeTracker
//
//  Created by lofzcx 06/25/2013
//  Copyright (c) 2013 Topcoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTabBarViewController.h"
#import "HelpSettingViewController.h"
#import "CustomTableViewController.h"

/**
 * @class PhotoListViewController
 * photo list view controller. Mange photos for photo taken.
 *
 * Changes in 1.1
 * - Added business logic
 *
 * @author lofzcx, flying2hk, subchap
 * @version 1.1
 * @since 1.0
 */
@interface PhotoListViewController : UIViewController<UISearchBarDelegate, SettingListViewDelegate, CustomTableViewDelegate, UIPopoverControllerDelegate>{
    /* clear background layer */
    UIView *clearCover;
}

/* the tab bar controller */
@property (weak, nonatomic) CustomTabBarViewController *customTabBarController;

/* the title label */
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
/* the delete button */
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;
/* the add to consumption button */
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
/* the photos list scrollview */
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
/* the sort by value label */
@property (weak, nonatomic) IBOutlet UILabel *lblSortBy;
/* the search bar */
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
/* the delete popup title label */
@property (weak, nonatomic) IBOutlet UILabel *lblDeletePopupTitle;
/* the delete popup view */
@property (weak, nonatomic) IBOutlet UIView *deletePopup;
/* the sortby option list view */
@property (weak, nonatomic) IBOutlet SettingListView *sortByListView;
/* the suggestion table view */
@property (strong, nonatomic) SuggestionTableView *suggestionTableView;

/**
 * click food photo in the grid view.
 * @param btn the button.
 */
- (void)clickPhoto:(UIButton *)btn;

/**
 * fill the scrollview with the food items.
 */
- (void)buildPhotos;

/**
 * show the delete confirm panel.
 * @param sender the button.
 */
- (IBAction)showDeletePanel:(id)sender;

/**
 * add foods to consumption.
 * @param sender the button.
 */
- (IBAction)addToConsumption:(id)sender;

/**
 * return back to take photo view.
 * @param sender the button.
 */
- (IBAction)returnBack:(id)sender;

/**
 * hide delete panel.
 * @param sender the button.
 */
- (IBAction)hideDeletePopup:(id)sender;

/**
 * action for delete button click in delete panel. Remove photos and reload list view.
 * @param sender the button.
 */
- (IBAction)deletePhotos:(id)sender;

/**
 * show sort by list view.
 * @param sender the button.
 */
- (IBAction)showSortByList:(id)sender;

/**
 * hide sort by list view.
 * @param sender the button.
 */
- (IBAction)hideSortByList:(id)sender;
@end
