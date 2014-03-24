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
//  AddFoodViewController.h
//  FoodIntakeTracker
//
//  Created by lofzcx 06/12/2013
//

#import <UIKit/UIKit.h>
#import "CustomPickerViewController.h"
#import "CustomTableViewController.h"

/**
 * @class AddFoodViewController
 * controller for add food view
 *
 * Changes in 1.1
 * - Added business logic
 *
 * @author lofzcx, flying2hk, subchap
 * @version 1.1
 * @since 1.0
 */
@interface AddFoodViewController : UIViewController
<CustomPickerViewDelegate, UITextViewDelegate, UITextFieldDelegate, CustomTableViewDelegate,
UIPopoverControllerDelegate>

/* the done button */
@property (weak, nonatomic) IBOutlet UIButton *btnDone;
/* the cancel button */
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
/* the time label */
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
/* the comment text view */
@property (weak, nonatomic) IBOutlet UITextView *txtComment;
/* the food name input */
@property (weak, nonatomic) IBOutlet UITextField *txtFood;
/* the quantity view */
@property (weak, nonatomic) IBOutlet UITextField *txtQuantity;
/* the voice button */
@property (weak, nonatomic) IBOutlet UIButton *btnVoice;
/* the view contains all input elements */
@property (weak, nonatomic) IBOutlet UIView *inputView;
/* the comment instruction label */
@property (weak, nonatomic) IBOutlet UILabel *commentInstructionLabel;
/* the suggestion table view */
@property (strong, nonatomic) SuggestionTableView *suggestionTableView;

/**
 * hide self
 * @param sender the button.
 */
- (IBAction)hidePopUp:(id)sender;

@end
