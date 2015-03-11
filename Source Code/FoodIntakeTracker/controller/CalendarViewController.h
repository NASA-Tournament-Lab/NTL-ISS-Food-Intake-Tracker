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
//  CalendarViewController.h
//  FoodIntakeTracker
//
//  Created by lofzcx 06/12/2013
//

#import <UIKit/UIKit.h>

/**
 * @protocol CalendarViewDelegate
 * Used to catch calendar value selected event.
 */
@protocol CalendarViewDelegate <NSObject>

/**
 * tells the delegate that a date is selected.
 * @param date the selected date.
 */
- (void)calendarDidSelect:(NSDate *)date;

@end

/**
 * @class CalendarListView
 * The list view for days in a month.
 *
 * @author lofzcx
 * @version 1.0
 */
@interface CalendarListView : UIView{
    /* an array contains days of pre-month in current month page */
    NSMutableArray *prevMonth;
    /* an arrya contains days for current month */
    NSMutableArray *curMonth;
    /* an array contains days of next-month in current month page */
    NSMutableArray *nextMonth;
    
    /* the month info containing year, month */
    NSDateComponents *monthInfo;
}

/* a NSDate object indicates the current month */
@property (nonatomic, strong) NSDate *month;
/* a NSDate objcet indicates the selected date */
@property (nonatomic, strong) NSDate *selectedDate;
/* the total number of rows */
@property (nonatomic, unsafe_unretained) NSInteger totalRows;

/**
 * update the days in prev month, current month and next month.
 * It will only update the array when different month is set.
 */
- (void)updateDateArray;

/**
 * get the selected date by the position in the list view.
 * @param pos the position in the view.
 * @return nil if invalid pos. otherwise a NSDate object contains the selected date.
 */
- (NSDate *)selectItemInPos:(CGPoint)pos;
@end

/**
 * @class CalendarListView
 * The list view for days in a month.
 *
 * @author lofzcx
 * @version 1.0
 */
@interface CalendarViewController : UIViewController{
    
}
/* the calendar list view */
@property (nonatomic, weak) IBOutlet CalendarListView *listView;
/* the calendar grid background image */
@property (nonatomic, weak) IBOutlet UIImageView *bgCalendarGrid;
/* the calendar background image */
@property (nonatomic, weak) IBOutlet UIImageView *bgCalendar;
/* the today button */
@property (nonatomic, weak) IBOutlet UIButton *btnToday;
/* the month label */
@property (nonatomic, weak) IBOutlet UILabel *monthLabel;
/* the delegate */
@property (nonatomic, weak) id<CalendarViewDelegate> delegate;
/* the pop over controller */
@property (nonatomic, strong) UIPopoverController *popController;
/* the selected date */
@property (nonatomic, strong) NSDate *selectedDate;

/**
 * setting the current month value.
 * @param month the current month.
 */
- (void)setMonth:(NSDate *)month;

/**
 * go to next month list.
 * @param sender the button.
 */
- (IBAction)nextMonth:(id)sender;

/**
 * go to previous month list.
 * @param sender the button.
 */
- (IBAction)prevMonth:(id)sender;

/**
 * action on tap the list view. Check the position and get the selected date.
 * @param ges the tap gesture indicates the position.
 */
- (void)tap:(UITapGestureRecognizer *)ges;

/**
 * move the list view to the month of today and set today as active.
 * @param sender the button
 */
- (IBAction)today:(id)sender;
@end
