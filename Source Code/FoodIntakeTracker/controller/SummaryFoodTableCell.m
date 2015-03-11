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
//  SummaryFoodTableCell.m
//  FoodIntakeTracker
//
//  Created by lofzcx 06/12/2013
//
//  Updated by pvmagacho on 05/07/2014
//  F2Finish - NASA iPad App Updates
//
//  Updated by pvmagacho on 05/14/2014
//  F2Finish - NASA iPad App Updates - Round 3
//

#import "SummaryFoodTableCell.h"
#import "CustomPickerViewController.h"
#import "PopoverBackgroundView.h"
#import "Settings.h"
#import "AppDelegate.h"
#import "Helper.h"
#import "FoodConsumptionRecordServiceImpl.h"

@implementation SummaryFoodTableCell

/**
 * custom picker deletegate method.
 * change the text label for time or quantity if value changed.
 * @param picker the picker view.
 * @param value the selected value.
 */
- (void)Picker:(BaseCustomPickerView *)picker DidSelectedValue:(NSString *)val{
    if([picker isKindOfClass:[HourPickerView class]]){
        self.lblTime.text = val;
        int hour = [[[val componentsSeparatedByString:@":"] objectAtIndex:0] integerValue];
        int minute = [[[val componentsSeparatedByString:@":"] objectAtIndex:1] integerValue];
        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        gregorian.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        NSDateComponents *info = [gregorian components:(NSYearCalendarUnit |
                                                        NSMonthCalendarUnit |
                                                        NSDayCalendarUnit |
                                                        NSWeekdayCalendarUnit |
                                                        NSHourCalendarUnit |
                                                        NSMinuteCalendarUnit)
                                              fromDate:self.foodConsumptionRecord.timestamp];
        [info setMinute:minute];
        [info setHour:hour];
        self.foodConsumptionRecord.timestamp = [gregorian dateFromComponents:info];
        [[NSNotificationCenter defaultCenter] postNotificationName:ConsumptionUpdatedEvent
                                                            object:self.foodConsumptionRecord];
    }
    else{
        NSNumber *quantity = [NSNumber numberWithFloat:val.floatValue];
        self.foodConsumptionRecord.quantity = quantity;
        [[NSNotificationCenter defaultCenter] postNotificationName:ConsumptionUpdatedEvent
                                                            object:self.foodConsumptionRecord];
        [self setNeedsDisplay];
    }
    // Save the record
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    FoodConsumptionRecordServiceImpl *recordService = appDelegate.foodConsumptionRecordService;
    NSError *error = nil;
    [recordService saveFoodConsumptionRecord:self.foodConsumptionRecord error:&error];
    if ([Helper displayError:error]) return;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DataSyncUpdateInterval" object:self.foodConsumptionRecord.timestamp];    
}

/**
 * show hour pikcer when clicking at time.
 * @param sender the button.
 */
- (IBAction)showDropDown:(id)sender {
    if ([self.foodConsumptionRecord.foodProduct.removed boolValue]) {
        return;
    }
    UIButton *btn = (UIButton *)sender;
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    HourPickerView *timePicker = [sb instantiateViewControllerWithIdentifier:@"HourPickerView"];
    timePicker.delegate = self;
    UIPopoverController *popController = [[UIPopoverController alloc] initWithContentViewController:timePicker];
    popController.popoverBackgroundViewClass = [PopoverBackgroundView class];
    popController.popoverContentSize = CGSizeMake(290, 267);
    timePicker.popController = popController;
    [timePicker setSelectedVal:self.lblTime.text];
    CGRect popoverRect = CGRectMake(btn.bounds.origin.x, btn.bounds.origin.y, 240, 23);
    [popController presentPopoverFromRect:popoverRect
                                   inView:btn
                 permittedArrowDirections:UIPopoverArrowDirectionUp
                                 animated:NO];
}

/**
 * show quantity pikcer when clicking at quantity.
 * @param sender the button.
 */
- (IBAction)showQuantityPicker:(id)sender{
    if ([self.foodConsumptionRecord.foodProduct.removed boolValue]) {
        return;
    }
    UIButton *btn = (UIButton *)sender;
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    QuantityPickerView *picker = [sb instantiateViewControllerWithIdentifier:@"QuantityPickerView"];
    picker.delegate = self;
    UIPopoverController *popController = [[UIPopoverController alloc] initWithContentViewController:picker];
    popController.popoverBackgroundViewClass = [PopoverBackgroundView class];
    popController.popoverContentSize = CGSizeMake(240, 267);
    picker.popController = popController;
    [picker setSelectedVal:[NSString stringWithFormat:@"%.2f", self.foodConsumptionRecord.quantity.floatValue]];
    CGRect popoverRect = CGRectMake(btn.bounds.origin.x, btn.bounds.origin.y, 1, 30);
    [popController presentPopoverFromRect:popoverRect
                                   inView:btn
                 permittedArrowDirections:UIPopoverArrowDirectionUp
                                 animated:NO];
}

/**
 * overwrite this method to layout the quantity label and quantity unit label.
 * @param rect the view frame.
 */
- (void)drawRect:(CGRect)rect{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:@"#.##"];
    self.lblQuantity.text = [numberFormatter stringFromNumber:self.foodConsumptionRecord.quantity];
    /*CGSize size2 = self.lblQuantityUnit.frame.size;
    CGSize size1 = [self.lblQuantity.text sizeWithFont:self.lblQuantity.font];
    float centerX = 140;
    float startX = centerX - (size1.width + size2.width) / 2;
    self.lblQuantity.frame = CGRectMake(startX, 17, size1.width, size2.height);
    self.lblQuantityUnit.frame = CGRectMake(startX + size1.width, 17, size2.width, size2.height);*/
    self.nutrientScrollView.contentSize = CGSizeMake(self.nutrientView.frame.size.width,
                                                     self.nutrientScrollView.frame.size.height);
}

/**
 * hide delete view.
 * @param sender the button or nil.
 */
- (void)hideDelete:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSArray *subViews = btn.superview.subviews;
    UIView *v = [subViews objectAtIndex:subViews.count - 2];
    if([v isKindOfClass:[UIButton class]]){
        [v removeFromSuperview];
    }
    v = [subViews objectAtIndex:subViews.count - 1];
    if([v isKindOfClass:[UIButton class]]){
        [v removeFromSuperview];
    }
    // F2Finish change
    [self setEditing:NO animated:YES];
}

/**
 * overwrite this method to show or hide delete view when enter or leave edit mode.
 * @param eiding the editing stautus.
 * @param animated YES to animate the appearance or disappearance of the insertion/deletion control and 
 * the reordering control, NO to make the transition immediate.
 */
- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
    
    CGSize size = [self.lblName.text sizeWithAttributes:@{ NSFontAttributeName : self.lblName.font}];
    if (size.width > self.lblName.frame.size.width) {
        size.width = self.lblName.frame.size.width;
    }
    int x = self.lblName.frame.origin.x;
    int w = self.lblName.frame.size.width;
    self.redline.frame = CGRectMake(x + (w - size.width) / 2, 27, size.width, 2);
    
    
    if (editing) {
        self.deleteView.hidden = NO;
        // F2Finish change - iOS7 added a new superview to UITableViewCell.
        UITableView *table = (UITableView *)self.superview;
        if (![table isKindOfClass:[UITableView class]]) {
            table = (UITableView *)table.superview;
        }
        CGRect frame1 = table.frame;
        CGRect frame2 = self.frame;
        CGPoint pos = table.contentOffset;
        int y = frame2.origin.y - pos.y + frame1.origin.y;
        int x = frame1.origin.x;
        UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(x,
                                                                    frame1.origin.y,
                                                                    frame1.size.width,
                                                                    y - frame1.origin.y)];
        
        UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(x,
                                                                    y + 55,
                                                                    frame1.size.width,
                                                                    frame1.origin.y + frame1.size.height)];
        [table.superview addSubview:btn1];
        [table.superview addSubview:btn2];
        [btn1 addTarget:self action:@selector(hideDelete:) forControlEvents:UIControlEventTouchDown];
        [btn2 addTarget:self action:@selector(hideDelete:) forControlEvents:UIControlEventTouchDown];
    } else {
        // F2Finish change - iOS7 added a new superview to UITableViewCell.
        NSArray *subViews = self.superview.superview.subviews;
        UIView *v = [subViews objectAtIndex:subViews.count - 2];
        if([v isKindOfClass:[UIButton class]]){
            [v removeFromSuperview];
        }
        v = [subViews objectAtIndex:subViews.count - 1];
        if([v isKindOfClass:[UIButton class]]){
            [v removeFromSuperview];
        }
        self.deleteView.hidden = YES;
    }
}
@end
