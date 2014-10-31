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
//  CustomPickerViewController.h
//  FoodIntakeTracker
//
//  Created by lofzcx 06/12/2013
//

#import <UIKit/UIKit.h>
#import <OpenEars/PocketsphinxController.h>

@class BaseCustomPickerView;

/**
 * @protocol CustomPickerViewDelegate
 * delegate for value selected in picker view.
 *
 * @author lofzcx
 * @version 1.0
 */
@protocol CustomPickerViewDelegate <NSObject>

/**
 * tells delegate value is selected in picker view.
 * @param picker the picker view.
 * @param val the selected val.
 */
- (void)Picker:(BaseCustomPickerView *)picker DidSelectedValue:(NSString *)val;

@end

/**
 * @class BaseCustomPickerView
 * base custom picker. Could be extend to specify view and picker data.
 *
 * @author lofzcx
 * @version 1.0
 */
@interface BaseCustomPickerView : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>{
    NSString *selectValue;
}

/* the UIPikcer view */
@property (nonatomic, weak) IBOutlet UIPickerView *timePicker;
/* the delegate */
@property (nonatomic, weak) id<CustomPickerViewDelegate> delegate;
/* the pop controller presenting the view */
@property (nonatomic, strong) UIPopoverController *popController;

/**
 * Set the selected value and update the picker.
 * @param val the selected value.
 */
- (void)setSelectedVal:(NSString *)val;

/**
 * action for done button click in the view.
 * @param sender the button.
 */
- (IBAction)doneButtonClick:(id)sender;

/**
 * action for cancel button in the view.
 * @param sender the button.
 */
- (IBAction)cancelButtonClick:(id)sender;

@end

/**
 * @class TimePickerView
 * A picker of number that allow user to select. Default range is 0 - 60.
 *
 * @author lofzcx
 * @version 1.0
 */
@interface TimePickerView : BaseCustomPickerView

/* the content string format*/
@property (nonatomic, strong) NSString *stringFormat;
/* the option count */
@property (nonatomic, unsafe_unretained) NSInteger optionCount;
@end


@interface HourPickerView : BaseCustomPickerView

/**
 * get the current time set it as the selected value.
 * @param sender the button.
 */
- (IBAction)currentTimeButtonClick:(id)sender;
@end

/**
 * @class HourPickerView
 * A picker of quantity that allow user to select. like 1 and 0.25, or 2 and 0.75.
 *
 * @author lofzcx
 * @version 1.0
 */
@interface QuantityPickerView : BaseCustomPickerView

@end