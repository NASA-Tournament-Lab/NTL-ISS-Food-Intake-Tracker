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
//  FoodDetailViewController.h
//  FoodIntakeTracker
//
//  Created by lofzcx 06/12/2013
//

#import <UIKit/UIKit.h>

@class FoodConsumptionRecord;

/**
 * @class FoodDetailViewController
 * controller for detail food view.
 *
 * Changes in 1.1
 * - Added business logic
 *
 * @author lofzcx, flying2hk, subchap
 * @version 1.1
 * @since 1.0
 */
@interface FoodDetailViewController : UIViewController

/* the comment text view */
@property (weak, nonatomic) IBOutlet UITextView *txtComment;
/* the calories value label */
@property (weak, nonatomic) IBOutlet UILabel *lblCalories;
/* the food image */
@property (weak, nonatomic) IBOutlet UIImageView *img;
/* the title label */
@property (weak, nonatomic) IBOutlet UILabel *lbltitle;
/* the cancel button */
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
/* the save button */
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
/* the food name label */
@property (weak, nonatomic) IBOutlet UITextField *txtFoodName;
/* the time label */
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
/* the quantity input */
@property (weak, nonatomic) IBOutlet UITextField *txtQuantity;
/* the sodium value label */
@property (weak, nonatomic) IBOutlet UILabel *lblSodium;
/* the fluid value label */
@property (weak, nonatomic) IBOutlet UILabel *lblFluid;
/* the protein value label */
@property (weak, nonatomic) IBOutlet UILabel *lblProtein;
/* the fat value label */
@property (weak, nonatomic) IBOutlet UILabel *lblFat;
/* the carb value label */
@property (weak, nonatomic) IBOutlet UILabel *lblCarb;
/* the voice button */
@property (weak, nonatomic) IBOutlet UIButton *btnVoice;
/* the voice button */
@property (weak, nonatomic) IBOutlet UIButton *btnVoicePlay;
/* the comment instruction label */
@property (weak, nonatomic) IBOutlet UILabel *commentInstructionLabel;

/* the scroll view */
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
/* Represents the FoodConsumptionRecord in this view. */
@property (strong, nonatomic) FoodConsumptionRecord *foodConsumptionRecord;

/**
 * show hour pikcer when clicking at time.
 * @param sender the button.
 */
- (IBAction)showHourPicker:(id)sender;

/**
 * increase or decrease quantity by 1.
 * @param sender the + or - button.
 */
- (IBAction)changeQuantity:(id)sender;
@end
