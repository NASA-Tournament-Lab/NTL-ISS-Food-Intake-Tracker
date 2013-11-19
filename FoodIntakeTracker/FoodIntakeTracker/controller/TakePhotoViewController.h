//
//  TakePhotoViewController.h
//  FoodIntakeTracker
//
//  Created by lofzcx 06/25/2013
//  Copyright (c) 2013 Topcoder. All rights reserved.
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
@interface TakePhotoViewController : TakeBaseViewController <UIPickerViewDataSource, UIPickerViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate>{
    NSMutableArray *categories;
}

/* the tab bar controller */
@property (weak, nonatomic) CustomTabBarViewController *customTabBarController;
/* the category picker view */
@property (weak, nonatomic) IBOutlet UIView *categoryPickerView;
/* the category picker */
@property (weak, nonatomic) IBOutlet UIPickerView *categoryPicker;
/* the take button */
@property (weak, nonatomic) IBOutlet UIButton *takeButton;
/* Represents the popover controller. */
@property (strong, nonatomic) UIPopoverController *popover;

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
