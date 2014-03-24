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
//  CustomPickerViewController.m
//  FoodIntakeTracker
//
//  Created by lofzcx 06/12/2013
//

#import "CustomPickerViewController.h"

/**
 * @class BaseCustomPickerView
 * base custom picker. Could be extend to specify view and picker data.
 *
 * @author lofzcx
 * @version 1.0
 */
@implementation BaseCustomPickerView

/**
 * Set the selected value and update the picker.
 * @param val the selected value.
 */
- (void)setSelectedVal:(NSString *)val{
    [self.timePicker selectRow:val.integerValue inComponent:0 animated:NO];
}

/**
 * action for done button click in the view.
 * @param sender the button.
 */
- (IBAction)doneButtonClick:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(Picker:DidSelectedValue:)]){
        [self.delegate Picker:self DidSelectedValue:selectValue];
    }
    [self.popController dismissPopoverAnimated:YES];
}
/**
 * action for cancel button in the view.
 * @param sender the button.
 */
- (IBAction)cancelButtonClick:(id)sender {
    [self.popController dismissPopoverAnimated:YES];
}

#pragma mark - UIPickerView Delegate method.

/**
 * Called by the picker view when it needs the number of components.
 * @param pickerView The picker view requesting the data.
 * @return default is 1. Could be overwrite by subclass.
 */
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

/**
 * Called by the picker view when it needs the number of rows for a specified component.
 * @param pickerView The picker view requesting the data.
 * @param component A zero-indexed number identifying a component of pickerView. 
 * @return default is 0. Could be overwrite by subclass. 
 */
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 0;
}

/**
 * Called by the picker view when it needs the view to use for a given row in a given component.
 * @param pickerView An object representing the picker view requesting the data.
 * @param row A zero-indexed number identifying a row of component. Rows are numbered top-to-bottom.
 * @param component A zero-indexed number identifying a component of pickerView. Components are numbered left-to-right.
 * @param view A view object that was previously used for this row, 
 * but is now hidden and cached by the picker view.
 * @return a center align text label.
 */
- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view{
    
    if([view isKindOfClass:[UILabel class]]){
        ((UILabel *)view).text = [NSString stringWithFormat:@"%.2d", row];
        return view;
    }
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont boldSystemFontOfSize:20];
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    return label;
}
@end

/**
 * @class TimePickerView
 * A picker of number that allow user to select. Default range is 0 - 60.
 *
 * @author lofzcx
 * @version 1.0
 */
@implementation TimePickerView

/**
 * load default values.
 */
-(void)viewDidLoad{
    [super viewDidLoad];
    self.optionCount = 60;
}

/**
 * Overwrite this method to define the content for the label.
 * @param pickerView An object representing the picker view requesting the data.
 * @param row A zero-indexed number identifying a row of component. Rows are numbered top-to-bottom.
 * @param component A zero-indexed number identifying a component of pickerView. Components are numbered left-to-right.
 * @param view A view object that was previously used for this row, 
 * but is now hidden and cached by the picker view.
 * @return a center align text label.
 */
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row
          forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *lbl = (UILabel *)[super pickerView:pickerView viewForRow:row forComponent:component reusingView:view];
    lbl.text = [NSString stringWithFormat:self.stringFormat, row];
    return lbl;
}

/**
 * Overwrite this method to return the option count.
 * @param pickerView The picker view requesting the data.
 * @param component A zero-indexed number identifying a component of pickerView.
 * @return optionCount.
 */
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.optionCount;
}

/**
 * overwrite this method to define done button click action. It set select Value here.
 * @param sender the button.
 */
- (IBAction)doneButtonClick:(id)sender{
    selectValue = [NSString stringWithFormat:self.stringFormat, [self.timePicker selectedRowInComponent:0]];
    [super doneButtonClick:sender];
}
@end

/**
 * @class HourPickerView
 * A picker of hour that allow user to select.
 *
 * @author lofzcx
 * @version 1.0
 */
@implementation HourPickerView

/**
 * Overwrite this method to define the content for the label. It is 00:00 to 23:00
 * @param pickerView An object representing the picker view requesting the data.
 * @param row A zero-indexed number identifying a row of component. Rows are numbered top-to-bottom.
 * @param component A zero-indexed number identifying a component of pickerView. 
 * @param view A view object that was previously used for this row.
 * @return a center align text label.
 */
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row
          forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *lbl = (UILabel *)[super pickerView:pickerView viewForRow:row forComponent:component reusingView:view];
    lbl.text = [NSString stringWithFormat:@"%.2d:00", row];
    return lbl;
}

/**
 * Overwrite this method to return the option count.
 * @param pickerView The picker view requesting the data.
 * @param component A zero-indexed number identifying a component of pickerView.
 * @return 24 as there are only 24 hours a day.
 */
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 24;
}

/**
 * overwrite this method to define done button click action. It set select Value here.
 * @param sender the button.
 */
- (IBAction)doneButtonClick:(id)sender{
    selectValue = [NSString stringWithFormat:@"%.2d:00", [self.timePicker selectedRowInComponent:0]];
    [super doneButtonClick:sender];
}

/**
 * get the current time set it as the selected value.
 * @param sender the button.
 */
- (IBAction)currentTimeButtonClick:(id)sender{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    format.dateFormat = @"HH:mm";
    selectValue = [format stringFromDate:[NSDate date]];
    [super doneButtonClick:nil];
}

@end

/**
 * @class HourPickerView
 * A picker of quantity that allow user to select. like 1 and 0.25, or 2 and 0.75.
 *
 * @author lofzcx
 * @version 1.0
 */
@implementation QuantityPickerView

/**
 * Overwrite this method as it needs 2 component here.
 * @param pickerView The picker view requesting the data.
 * @return the component number (2).
 */
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}

/**
 * define width for each component here.
 * @param pickerView The picker view requesting this information.
 * @param component A zero-indexed number identifying a component of the picker view. 
 */
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    if(component == 0){
        return 62;
    }
    else{
        return 166;
    }
}
/**
 * Overwrite this method to return the row count for each component.
 * @param pickerView The picker view requesting the data.
 * @param component A zero-indexed number identifying a component of pickerView.
 * @return 10 for first component and 4 for second one.
 */
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if(component == 0){
        return 10;
    }
    else{
        return 4;
    }
}
/**
 * Overwrite this method to define the content for the label. 
 * @param pickerView An object representing the picker view requesting the data.
 * @param row A zero-indexed number identifying a row of component. Rows are numbered top-to-bottom.
 * @param component A zero-indexed number identifying a component of pickerView. 
 * @param view A view object that was previously used for this row, 
 * @return a center align text label.
 */
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row
          forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *lbl = (UILabel *)[super pickerView:pickerView viewForRow:row forComponent:component reusingView:view];
    if(component == 0){
        lbl.text = [NSString stringWithFormat:@"%.2d", row];
    }
    else{
        lbl.text = [NSString stringWithFormat:@"%.2f Package", row * 0.25];
    }
    return lbl;
}
/**
 * overwrite this method to parse from val and set the picker.
 * @param val the setting value.
 */
- (void)setSelectedVal:(NSString *)val{
    int v1 = val.intValue;
    int v2 = (val.floatValue - val.intValue) / 0.25;
    [self.timePicker selectRow:v1 inComponent:0 animated:NO];
    [self.timePicker selectRow:v2 inComponent:1 animated:NO];
}

/**
 * overwrite this method to define done button click action. It sets select Value here.
 * @param sender the button.
 */
- (IBAction)doneButtonClick:(id)sender {
    float val = [self.timePicker selectedRowInComponent:0] + [self.timePicker selectedRowInComponent:1] * 0.25;
    selectValue = [NSString stringWithFormat:@"%.2f", val];
    [super doneButtonClick:sender];
}

@end
