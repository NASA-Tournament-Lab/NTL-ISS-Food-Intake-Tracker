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
//  ConsumptionViewController.h
//  FoodIntakeTracker
//
//  Created by lofzcx 06/12/2013
//

#import <UIKit/UIKit.h>
#import "CalendarViewController.h"
#import <AVFoundation/AVFoundation.h>

@class Food;
@class CustomTabBarViewController;
@class BNPieChart;
@class FoodConsumptionRecord;
@class AdhocFoodProduct;

/**
 * @protocol DateListViewDelegate
 * delegate for date changed in the list view
 *
 * Changes in 1.1
 * - Added business logic
 *
 * @author lofzcx, flying2hk, subchap
 * @version 1.1
 * @since 1.0
 */
@protocol DateListViewDelegate <NSObject>

- (void)clickDate:(NSDate *)date;

@end

/**
 * @class DateListView
 * date list view in subheader of consumption view.
 *
 * Changes in 1.1
 * - Added business logic
 *
 * @author lofzcx, flying2hk, subchap
 * @version 1.1
 * @since 1.0
 */
@interface DateListView : UIView{
    /* the active tag index */
    int activeTag;
}
/* the selected current date */
@property (strong, nonatomic) NSDate *currentDate;
/* the delegate */
@property (weak, nonatomic) id<DateListViewDelegate> delegate;

/**
 * handles action for date item button click.
 * @param sender the date item button.
 */
-(void)buttonClick:(id)sender;
@end

/**
 * @class CustomProgressView
 * custom pregress view to meet the design of consumption info bar.
 *
 * @author lofzcx
 * @version 1.0
 */
@interface CustomProgressView : UIView{
    /* the current progress */
    float _currentProgress;
    
    /* original frame */
    CGRect originalFrame;
    CGRect interFrame;
}
/* the background image */
@property (nonatomic, strong) UIImage *backgoundImage;
/* the progress image */
@property (nonatomic, strong) UIImage *progressImage;
/* the color progress equals 1 */
@property (nonatomic, strong) UIColor *fullColor;
/* current value label */
@property (nonatomic, weak) IBOutlet UILabel *lblCurrent;
/* total value label */
@property (nonatomic, weak) IBOutlet UILabel *lblTotal;
/* the percent label */
@property (nonatomic, weak) IBOutlet UILabel *lblPercent;
/* the progress view */
@property (nonatomic, weak) IBOutlet UIView *progressView;
/* the current progress */
@property (nonatomic, unsafe_unretained) float currentProgress;
/* the gmKg flag */
@property (nonatomic, unsafe_unretained) BOOL gmKg;

@end

/**
 * @class ConsumptionViewController
 * view controller for main summary view.
 *
 * Changes in 1.1
 * - Bind action for take Photo/Label/Barcode
 * - update select consumption view with navigation controller.
 *
 * Changes in 1.2
 * - Added business logic
 *
 * Changes in 1.3
 * - Added UIScrollViewDelegate. Save nutrition scrollview position to NSDictionary.
 *
 * @author lofzcx, flying2hk, subchap, pvmagacho
 * @version 1.2
 * @since 1.0
 */
@interface ConsumptionViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate,
    UIGestureRecognizerDelegate, UIPopoverControllerDelegate, AVAudioRecorderDelegate, CalendarViewDelegate, DateListViewDelegate>

/* the tab bar controller */
@property (weak, nonatomic) CustomTabBarViewController *customTabBarController;

/* the header title label */
@property (weak, nonatomic) IBOutlet UILabel *lblHeaderTitle;
/* the header line image */
@property (weak, nonatomic) IBOutlet UIImageView *imgBgHeader;
/* the header line image */
@property (weak, nonatomic) IBOutlet UIImageView *imgHeaderLine;

/* the date list view in sub header */
@property (weak, nonatomic) IBOutlet DateListView *dateListView;

/* the month label in sub header */
@property (weak, nonatomic) IBOutlet UILabel *lblMonth;
/* the year label in sub header */
@property (weak, nonatomic) IBOutlet UILabel *lblYear;
/* the month button to show calendar view */
@property (weak, nonatomic) IBOutlet UIButton *btnMonth;

/* the food table view */
@property (weak, nonatomic) IBOutlet UITableView *foodTableView;
/* delete button */
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;
/* copy button */
@property (weak, nonatomic) IBOutlet UIButton *btnCopy;
/* paste button */
@property (weak, nonatomic) IBOutlet UIButton *btnPaste;
/* select button. showing select consumption view */
@property (weak, nonatomic) IBOutlet UIButton *btnSelect;
/* voice button. showing voice search view */
@property (weak, nonatomic) IBOutlet UIButton *btnVoice;
/* photo button */
@property (weak, nonatomic) IBOutlet UIButton *btnPhoto;
/* add button */
@property (weak, nonatomic) IBOutlet UIButton *btnAddFood;
/* calories progress in footer */
@property (weak, nonatomic) IBOutlet CustomProgressView *caloriesProgess;
/* sodium progress in footer */
@property (weak, nonatomic) IBOutlet CustomProgressView *sodiumProgress;
/* fluid progress in footer */
@property (weak, nonatomic) IBOutlet CustomProgressView *fluidProgress;
/* protein progress in footer */
@property (weak, nonatomic) IBOutlet CustomProgressView *proteinProgess;
/* carb progress in footer */
@property (weak, nonatomic) IBOutlet CustomProgressView *carbProgress;
/* fat progress in footer */
@property (weak, nonatomic) IBOutlet CustomProgressView *fatProgress;
/* current protein value */
@property (weak, nonatomic) IBOutlet UILabel *curProteinValue;
/* protein progress view in footer */
@property (weak, nonatomic) IBOutlet UIView *proteinProgessView;
/* carb progress view in footer */
@property (weak, nonatomic) IBOutlet UIView *carbProgressView;
/* fat progress viewin footer */
@property (weak, nonatomic) IBOutlet UIView *fatProgressView;

/* title label in footer */
@property (weak, nonatomic) IBOutlet UILabel *lblFooterTitle;
/* note label in footer */
@property (weak, nonatomic) IBOutlet UILabel *lblFooterNote;

/* delete pop view */
@property (weak, nonatomic) IBOutlet UIView *deletePopup;
/* title label in delete pop view */
@property (weak, nonatomic) IBOutlet UILabel *lblDeletePopupTitle;

/* copy pop view */
@property (weak, nonatomic) IBOutlet UIView *consumptionCopyPopup;
/* title label in delete pop view */
@property (weak, nonatomic) IBOutlet UILabel *lblCopyPopupTitle;

/* paste pop view */
@property (weak, nonatomic) IBOutlet UIView *pastePopup;
/* title label in paste pop view */
@property (weak, nonatomic) IBOutlet UILabel *lblPastePopupTitle;

/* option pop view */
@property (weak, nonatomic) IBOutlet UIView *optionPopup;
/* The bottom scroll view */
@property (weak, nonatomic) IBOutlet UIScrollView *bottomScrollView;

/* Represents the FoodConsumptionRecords. */
@property (strong, nonatomic) NSMutableArray *foodConsumptionRecords;

/* Represent the FoodConsumptionRecord to add. */
@property (strong, nonatomic) FoodConsumptionRecord *foodConsumptionRecordToAdd;

/* Represent the AdhocFoodProduct to add. */
@property (strong, nonatomic) AdhocFoodProduct *adhocFoodProductToAdd;

/* Represents the language model paths for general English. */
@property (strong, nonatomic) NSDictionary *lmPaths;

/* Represents the comment UITextView to update for comment dictation. */
@property (strong, nonatomic) UITextView *commentToUpdate;

/* Represents the second progress view. */
@property (strong, nonatomic) IBOutlet UIView *progressView2;

/* Represents the label showing protein percentage. */
@property (strong, nonatomic) IBOutlet UILabel *proteinPercentageLabel;

/* Represents the label showing carb percentage. */
@property (strong, nonatomic) IBOutlet UILabel *carbPercentageLabel;

/* Represents the label showing fat percentage. */
@property (strong, nonatomic) IBOutlet UILabel *fatPercentageLabel;

/* Represnts the page control */
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

/* Represents the pie chart. */
@property (strong, nonatomic) BNPieChart *pieChart;

/**
 * called when view will appear. just load foods here.
 */
- (void)updateView;

/**
 * update progress in the footer info bar.
 */
- (void)updateProgress;

/**
 * load food items by specify date. (Just random some hard code value here)
 * @param date The date of foods want to load.
 */
- (void)loadFoodItemsForDate:(NSDate *)date;

/**
 * action for check box button click. Add item to array or remove it. Update button status.
 * @param sender the check box button.
 */
- (void)foodSelect:(id)sender;

/**
 * handle action for save button in add food view. Save food to list and reload table.
 */
- (void)addFoodDoneButtonClick;

/**
 * handle action for cancel button in add food view. Just hide the add food view.
 */
- (void)addFoodCancelButtonClick;

/**
 * handle action for add button click. Pop add food view and bind button action.
 * @param sender the button.
 */
- (IBAction)showAddFoodPopover:(id)sender;

/**
 * hide food detail view.
 */
- (void)hideFoodDetail;

/**
 * handle action for save button in detail view. save values in food detail and reload data.
 */
- (void)saveFoodDetail;

/**
 * This method will show food consumption record details.
 * @param record the FoodConsumptionRecord.
 */
- (void)showFoodDetails:(FoodConsumptionRecord *)record;

/**
 * handle action for date click in date list view.
 * @param date the selected date.
 */
- (void)clickDate:(NSDate *)date;

/**
 * CalendarViewDelegate method. Called when select a date in calendar view.
 * @param date the selected data.
 */
- (void)calendarDidSelect:(NSDate *)date;

/**
 * handle action for month button click. Showing calendar pop over.
 * @param sender the button.
 */
- (IBAction)showMonthPopover:(id)sender;

/**
 * handle action for copy button.
 * @param sender the button.
 */
- (IBAction)copySelected:(id)sender;

/**
 * handle action for paste button.
 * @param sender the button.
 */
- (IBAction)pasteSelected:(id)sender;

/**
 * handle action for delete button. Just pop over delete confirm dialog.
 * @param sender the button.
 */
- (IBAction)showDeletePop:(id)sender;

/**
 * handle action for hiding delete confirm dialog.
 * @param sender the button.
 */
- (IBAction)hideDeletePop:(id)sender;

/**
 * handle action delete confirmed button. Remove item here and reload table.
 * @param sender the button.
 */
- (IBAction)deleteSelected:(id)sender;

/**
 * handle action for delete a single row.
 * @param sender the button.
 */
- (void)deleteItem:(id)sender;

/**
 * handle action for photo button click. Showing photo option pop.
 * @param sender the button.
 */
- (IBAction)showOptionPopup:(id)sender;

/**
 * hide photo option pop.
 * @param sender the button.
 */
- (IBAction)hideOptionPopup:(id)sender;

/**
 * handle action for voice button. Showing voice search view.
 * @param sender the button.
 */
- (IBAction)showVoice:(id)sender;

/**
 * hide voice search pop.
 * @param sender the button.
 */
- (void)hideVoice:(id)sender;

/**
 * hide the select consumption view.
 * @param sender the button or nil.
 */
- (void)hideSelectConsumption:(id)sender;

/**
 * handle action for showing select consumption view.
 * @param sender the button.
 */
- (IBAction)showSelectConsumption:(id)sender;

/**
 *
 */
- (IBAction)pageControlDidChange:(id)sender;

@end
