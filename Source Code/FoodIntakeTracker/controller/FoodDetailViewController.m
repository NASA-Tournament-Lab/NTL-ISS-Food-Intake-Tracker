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
//  FoodDetailViewController.m
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

#import "FoodDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CustomPickerViewController.h"
#import "PopoverBackgroundView.h"
#import "AppDelegate.h"
#import "FoodConsumptionRecordServiceImpl.h"
#import "Helper.h"
#import "Settings.h"

@interface FoodDetailViewController ()<CustomPickerViewDelegate>

@end

@implementation FoodDetailViewController

@synthesize foodConsumptionRecord;

/**
 * bind the food value after view load.
 */
- (void)viewDidLoad{
    [super viewDidLoad];
    self.txtFoodName.text = self.foodConsumptionRecord.foodProduct.name;
    self.txtFoodName.userInteractionEnabled = [self.foodConsumptionRecord.foodProduct isKindOfClass:[AdhocFoodProduct class]];
    self.txtFoodName.delegate = self;
    self.lbltitle.font = [UIFont fontWithName:@"Bebas" size:24];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:@"#.##"];
        
    self.txtQuantity.text = [numberFormatter stringFromNumber:self.foodConsumptionRecord.quantity];
    self.txtQuantity.userInteractionEnabled = NO;
    
    self.lblCalories.text = [NSString stringWithFormat:@"%@", self.foodConsumptionRecord.foodProduct.energy];
    self.lblSodium.text = [NSString stringWithFormat:@"%@", self.foodConsumptionRecord.foodProduct.sodium];
    self.lblFluid.text = [numberFormatter stringFromNumber:self.foodConsumptionRecord.foodProduct.fluid];
    self.lblProtein.text = [NSString stringWithFormat:@"%@", self.foodConsumptionRecord.foodProduct.protein];
    self.lblCarb.text = [NSString stringWithFormat:@"%@", self.foodConsumptionRecord.foodProduct.carb];
    self.lblFat.text = [NSString stringWithFormat:@"%@", self.foodConsumptionRecord.foodProduct.fat];
   
    self.txtComment.text = self.foodConsumptionRecord.comment;
    
    self.img.layer.borderColor = [UIColor colorWithRed:0.54 green:0.79 blue:1 alpha:1].CGColor;
    self.img.image = [Helper loadImage:self.foodConsumptionRecord.foodProduct.foodImage.filename];
    self.img.layer.borderWidth = 1;
    self.img.contentMode = UIViewContentModeScaleAspectFit;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit |
                                                         NSMinuteCalendarUnit)
                                               fromDate:self.foodConsumptionRecord.timestamp];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    self.lblTime.text = [NSString stringWithFormat:@"%.2d:%.2d", (int) hour, (int) minute];
    self.scrollView.contentSize = CGSizeMake(554, 54);
    [self.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    self.commentInstructionLabel.text = @"";
    [[NSNotificationCenter defaultCenter] postNotificationName:AutoLogoutRenewEvent object:nil];
    
    self.btnVoicePlay.enabled = ([self.foodConsumptionRecord.voiceRecordings count] > 0);

    self.btnSave.enabled = NO;
}

/**
 * release view resources after view unload by setting value nil.
 */
- (void)viewDidUnload {
    [self setTxtComment:nil];
    [self setLblCalories:nil];
    [self setImg:nil];
    [self setLbltitle:nil];
    [self setBtnCancel:nil];
    [self setLblTime:nil];
    [self setTxtQuantity:nil];
    [self setLblSodium:nil];
    [self setLblFluid:nil];
    [self setLblProtein:nil];
    [self setLblCarb:nil];
    [self setLblFat:nil];
    [super viewDidUnload];
}

/**
 * show hour pikcer when clicking at time.
 * @param sender the button.
 */
- (IBAction)showHourPicker:(id)sender{
    if ([self.foodConsumptionRecord.foodProduct.removed boolValue]) {
        return;
    }
    UIButton *btn = (UIButton *)sender;
    HourPickerView *timePicker = [self.storyboard instantiateViewControllerWithIdentifier:@"HourPickerView"];
    timePicker.delegate = self;
    UIPopoverController *popController = [[UIPopoverController alloc] initWithContentViewController:timePicker];
    popController.popoverBackgroundViewClass = [PopoverBackgroundView class];
    popController.popoverContentSize = CGSizeMake(290, 267);
    timePicker.popController = popController;
    [timePicker setSelectedVal:self.lblTime.text];
    CGRect popoverRect = CGRectMake(btn.bounds.origin.x, btn.bounds.origin.y, 290, 33);
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
    [picker setSelectedVal:[NSString stringWithFormat:@"%.2f", self.txtQuantity.text.floatValue]];
    CGRect popoverRect = CGRectMake(btn.bounds.origin.x, btn.bounds.origin.y, 1, 30);
    [popController presentPopoverFromRect:popoverRect
                                   inView:btn
                 permittedArrowDirections:UIPopoverArrowDirectionUp
                                 animated:NO];
}

/**
 * custom picker deletegate method.
 * change the text label for time if value changed.
 * @param picker the picker view.
 * @param value the selected value.
 */
- (void)Picker:(BaseCustomPickerView *)picker DidSelectedValue:(NSString *)val{
    if([picker isKindOfClass:[HourPickerView class]]){
        if (!self.btnSave.enabled) {
            self.btnSave.enabled = ![self.lblTime.text isEqualToString:val];
        }
        self.lblTime.text = val;
    } else {
        if (!self.btnSave.enabled) {
            self.btnSave.enabled = self.txtQuantity.text.floatValue != val.floatValue;
        }
        self.txtQuantity.text = val;
    }
}

/**
 * increase or decrease quantity by 1.
 * @param sender the + or - button.
 */
- (IBAction)changeQuantity:(id)sender{
    if ([self.foodConsumptionRecord.foodProduct.removed boolValue]) {
        return;
    }
    UIButton *btn = (UIButton *)sender;
    float quantity = self.txtQuantity.text.floatValue;
    if(btn.tag == 0){
        quantity--;
    }
    else{
        quantity++;
    }
    if(quantity < 0){
        quantity = 0;
    }
    else if (quantity > 10) {
        quantity = 10;
    }
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:@"#.##"];
    self.txtQuantity.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:quantity]];

    self.btnSave.enabled = YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.btnSave.enabled = ![self.foodConsumptionRecord.foodProduct.name isEqualToString:textField.text];
    return YES;
}

@end
