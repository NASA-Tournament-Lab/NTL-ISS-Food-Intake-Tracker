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
//  SummaryFoodTableCell.h
//  FoodIntakeTracker
//
//  Created by lofzcx 06/12/2013
//
//  Updated by pvmagacho on 05/14/2014
//  F2Finish - NASA iPad App Updates - Round 3
//

#import <UIKit/UIKit.h>
#import "CustomPickerViewController.h"
/**
 * @class SummaryFoodTableCell
 * The table cell in consumption view.
 *
 * Changes in 1.1
 * - Added business logic
 *
 * @author lofzcx, flying2hk, subchap
 * @version 1.1
 * @since 1.0
 */
@interface SummaryFoodTableCell : UITableViewCell<CustomPickerViewDelegate>

/* the check box button */
@property (weak, nonatomic) IBOutlet UIButton *btnCheck;
/* the time label */
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
/* the name label */
@property (weak, nonatomic) IBOutlet UILabel *lblName;
/* the quantity label */
@property (weak, nonatomic) IBOutlet UITextField *lblQuantity;
/* the quantity unit label */
@property (weak, nonatomic) IBOutlet UILabel *lblQuantityUnit;
/* the calories value label */
@property (weak, nonatomic) IBOutlet UILabel *lblCalories;
/* the sodium value label */
@property (weak, nonatomic) IBOutlet UILabel *lblSodium;
/* the fluid value label */
@property (weak, nonatomic) IBOutlet UILabel *lblFluid;
/* the protein value label */
@property (weak, nonatomic) IBOutlet UILabel *lblProtein;
/* the carb value label */
@property (weak, nonatomic) IBOutlet UILabel *lblCarb;
/* the fat value label */
@property (weak, nonatomic) IBOutlet UILabel *lblFat;
/* the comment button */
@property (weak, nonatomic) IBOutlet UIButton *btnComment;
/* the non nutrient button */
@property (weak, nonatomic) IBOutlet UIButton *btnNonNutrient;
/* the nutrient view */
@property (weak, nonatomic) IBOutlet UIView *nutrientView;
/* the nutrient scroll view */
@property (weak, nonatomic) IBOutlet UIScrollView *nutrientScrollView;
/* the delete view */
@property (weak, nonatomic) IBOutlet UIView *deleteView;
/* the delete red line */
@property (weak, nonatomic) IBOutlet UIImageView *redline;
/* the undo button */
@property (weak, nonatomic) IBOutlet UIButton *btnUndo;
/* the done button */
@property (weak, nonatomic) IBOutlet UIButton *btnDone;
/* Represents the FoodConsumptionRecord in this view. */
@property (weak, nonatomic) FoodConsumptionRecord *foodConsumptionRecord;

/**
 * show hour pikcer when clicking at time.
 * @param sender the button.
 */
- (IBAction)showDropDown:(id)sender;

/**
 * show quantity pikcer when clicking at quantity.
 * @param sender the button.
 */
- (IBAction)showQuantityPicker:(id)sender;
/**
 * hide delete view.
 * @param sender the button or nil.
 */
- (void)hideDelete:(id)sender;
@end
