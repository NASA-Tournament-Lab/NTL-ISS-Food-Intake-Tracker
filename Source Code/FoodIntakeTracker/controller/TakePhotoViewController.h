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
//  TakePhotoViewController.h
//  FoodIntakeTracker
//
//  Created by lofzcx 06/25/2013
//
//  Updated by pvmagacho on 05/14/2014
//  F2Finish - NASA iPad App Updates - Round 3
//

#import <UIKit/UIKit.h>
#import "CustomTabBarViewController.h"
#import "TakeBaseViewController.h"

@class Food;

/**
 * controller for take photo view.
 *
 * Changes in 1.1
 * - Added business logic
 *
 * @author lofzcx, flying2hk, subchap
 * @version 1.1
 * @since 1.0
 */
@interface TakePhotoViewController : TakeBaseViewController <UIPickerViewDataSource, UIPickerViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate, UIAlertViewDelegate>{
    NSMutableArray *categories;
}

/* the note label at bottom */
@property (weak, nonatomic) IBOutlet UILabel *lblNoteBottom;
/* the category picker view */
@property (weak, nonatomic) IBOutlet UIView *categoryPickerView;
/* the category picker */
@property (weak, nonatomic) IBOutlet UIPickerView *categoryPicker;
/* the take button */
@property (weak, nonatomic) IBOutlet UIButton *takeButton;
/* Represents the popover controller. */
@property (strong, nonatomic) UIPopoverController *popover;

/* the result view when label is found */
@property (weak, nonatomic) IBOutlet UIView *resultViewFound;
/* the image view of food when label is found */
@property (weak, nonatomic) IBOutlet UIImageView *imgFoodFound;

/* the title label in result view */
@property (weak, nonatomic) IBOutlet UILabel *lblResultTitleFound;
/* the food name label */
@property (weak, nonatomic) IBOutlet UILabel *lblFoodNameFound;
/* the food category label */
@property (weak, nonatomic) IBOutlet UILabel *lblFoodCategoryFound;

/* the calories label */
@property (weak, nonatomic) IBOutlet UILabel *lblCaloriesFound;
/* the sodium label */
@property (weak, nonatomic) IBOutlet UILabel *lblSodiumFound;
/* the fluid label */
@property (weak, nonatomic) IBOutlet UILabel *lblFluidFound;
/* the protein label */
@property (weak, nonatomic) IBOutlet UILabel *lblProteinFound;
/* the carb label */
@property (weak, nonatomic) IBOutlet UILabel *lblCarbFound;
/* the fat label */
@property (weak, nonatomic) IBOutlet UILabel *lblFatFound;

/**
 * hide the category picker view.
 * @param sender nil or the button.
 */
- (IBAction)hideCategoryPicker:(id)sender;

/**
 * action for done button in category picker view.
 * @param sender the button.
 */
- (IBAction)pickerDoneButtonClick:(id)sender;

/**
 * showing the category picker view.
 * @param sender the button.
 */
- (IBAction)showCategoryList:(id)sender;

/**
 * Cancel the photo current is taken.
 * @param sender the button.
 */
- (IBAction)cancelTake:(id)sender;
@end
