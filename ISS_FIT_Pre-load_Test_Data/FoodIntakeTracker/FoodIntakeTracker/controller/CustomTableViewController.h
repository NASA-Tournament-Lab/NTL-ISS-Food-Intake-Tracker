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
//  CustomTableViewController.h
//  FoodIntakeTracker
//
//  Created by subchap 08/19/2013
//

#import <UIKit/UIKit.h>

@class BaseCustomTableView;

/**
 * @protocol CustomTableViewDelegate
 * delegate for value selected in table view.
 *
 * @author subchap
 * @version 1.0
 */
@protocol CustomTableViewDelegate <NSObject>

/**
 * tells delegate value is selected in picker view.
 * @param picker the picker view.
 * @param val the selected val.
 */
- (void)tableView:(BaseCustomTableView *)tableView didSelectValue:(NSString *)val;

@end

/**
 * @class BaseCustomTableView
 * base custom Table view. Could be extend to specify view and table data.
 *
 * @author subchap
 * @version 1.0
 */
@interface BaseCustomTableView : UIViewController<UITableViewDataSource, UITableViewDelegate>{
    NSString *selectValue;
}

/* the table view */
@property (nonatomic, weak) IBOutlet UITableView *theTableView;
/* the delegate */
@property (nonatomic, weak) id<CustomTableViewDelegate> delegate;
/* the pop controller presenting the view */
@property (nonatomic, strong) UIPopoverController *popController;

@end

/**
 * @class SuggestionTableView
 * A table view that shows auto-suggestions
 *
 * @author subchap
 * @version 1.0
 */
@interface SuggestionTableView : BaseCustomTableView

/* the content string format*/
@property (nonatomic, strong) NSString *stringFormat;
/* the option count */
@property (nonatomic, unsafe_unretained) NSInteger optionCount;
/* the list of suggestions */
@property (nonatomic, strong) NSArray *suggestions;
@end
