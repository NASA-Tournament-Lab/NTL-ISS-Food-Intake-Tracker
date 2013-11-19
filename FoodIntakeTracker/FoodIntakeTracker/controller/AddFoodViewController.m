//
//  AddFoodViewController.m
//  FoodIntakeTracker
//
//  Created by lofzcx 06/12/2013
//  Copyright (c) 2013 Topcoder. All rights reserved.
//

#import "AddFoodViewController.h"
#import "PopoverBackgroundView.h"
#import <QuartzCore/QuartzCore.h>
#import "FoodProductServiceImpl.h"
#import "AppDelegate.h"
#import "Settings.h"
#import "Helper.h"

@interface AddFoodViewController (){
    /* is first time input quantity */
    BOOL isFirstTimeInputQuantity;
    /* is first time input na */
    BOOL isFirstTimeInputName;
    /* is first time input comment */
    BOOL isFirstTimeInputComment;
}

@end

@implementation AddFoodViewController
/**
 * set some default value after view load.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    isFirstTimeInputQuantity = YES;
    isFirstTimeInputName = YES;
    isFirstTimeInputComment = YES;
    self.inputView.layer.cornerRadius = 5;
    self.inputView.layer.masksToBounds = YES;
    self.commentInstructionLabel.text = @"";
    NSDateFormatter *defaultFormatter = [Helper defaultFormatter];
    [defaultFormatter setDateFormat:@"HH:mm"];
    self.timeLabel.text = [defaultFormatter stringFromDate:[NSDate date]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self.txtFood];
    [[NSNotificationCenter defaultCenter] postNotificationName:AutoLogoutRenewEvent object:nil];
}

/**
 * clear resource by setting nil when view unload.
 */
- (void)viewDidUnload {
    [self setBtnDone:nil];
    [self setBtnCancel:nil];
    [self setTimeLabel:nil];
    [self setBtnVoice:nil];
    [self setTxtComment:nil];
    [self setTxtFood:nil];
    [self setTxtQuantity:nil];
    [self setInputView:nil];
    [super viewDidUnload];
}

/**
 * hide self
 * @param sender the button.
 */
- (IBAction)hidePopUp:(id)sender {
    [self.view removeFromSuperview];
}

/**
 * show hour pikcer when clicking at time.
 * @param sender the button.
 */
- (IBAction)showDropDown:(id)sender {
    UIButton *btn = (UIButton *)sender;
    HourPickerView *timePicker = [self.storyboard instantiateViewControllerWithIdentifier:@"HourPickerView"];
    timePicker.delegate = self;
    UIPopoverController *popController = [[UIPopoverController alloc] initWithContentViewController:timePicker];
    popController.popoverBackgroundViewClass = [PopoverBackgroundView class];
    popController.popoverContentSize = CGSizeMake(290, 267);
    timePicker.popController = popController;
    [timePicker setSelectedVal:self.timeLabel.text];
    CGRect popoverRect = CGRectMake(btn.bounds.origin.x, btn.bounds.origin.y, 290, 33);
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
    self.timeLabel.text = val;
}

#pragma mark TextView and TextField Delegate Methods
/**
 * clear value if is first time to edit.
 * @param The text view in which editing began.
 */
- (void)textViewDidBeginEditing:(UITextView *)textView{
    if(isFirstTimeInputComment){
        isFirstTimeInputComment = NO;
        textView.text = @"";
    }
}
/**
 * clear value if is first time to edit.
 * @param The text Field in which editing began.
 */
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if(isFirstTimeInputName && textField == self.txtFood){
        textField.text = @"";
        isFirstTimeInputName = NO;
        
    }
    else if(isFirstTimeInputQuantity && textField == self.txtQuantity){
        textField.text = @"";
        isFirstTimeInputQuantity = NO;
    }
}

/**
 * Called when the text field text is modified
 * @param textField the text Field.
 */
- (void)textFieldDidChange:(NSNotification *)notification {
    UITextField *textField = notification.object;
    if (textField == self.txtFood) {
        if (!self.suggestionTableView) {
            self.suggestionTableView = [self.storyboard instantiateViewControllerWithIdentifier:@"AutoSuggestionView"];
            self.suggestionTableView.delegate = self;
            UIPopoverController *popController =
            [[UIPopoverController alloc] initWithContentViewController:self.suggestionTableView];
            popController.popoverContentSize = CGSizeMake(290, 267);
            popController.delegate = self;
            self.suggestionTableView.popController = popController;
            [popController presentPopoverFromRect:textField.frame
                                           inView:textField.superview
                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                         animated:YES];
        }
        
        AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        FoodProductServiceImpl *foodProductService = appDelegate.foodProductService;
        NSError *error = nil;
        FoodProductFilter *filter = [foodProductService buildFoodProductFilter:&error];
        filter.sortOption = @2;
        NSString *searchText = textField.text;
        filter.name = searchText;
        NSArray *result = [foodProductService filterFoodProducts:appDelegate.loggedInUser filter:filter error:&error];
        if (self.suggestionTableView) {
            NSMutableArray *suggestions = [NSMutableArray array];
            for (int i = 0; i < result.count; i++) {
                AdhocFoodProduct *product = result[i];
                NSString *productName = [product.name uppercaseString];
                if ([searchText isEqualToString:@""] || [productName rangeOfString:[searchText uppercaseString]].location == 0) {
                    [suggestions addObject:product.name];
                }
            }
            self.suggestionTableView.suggestions = suggestions;
            [self.suggestionTableView.theTableView reloadData];
        }
    }
}

/**
 * Called when the text field text has finished editing
 * @param textField the text Field.
 */
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.txtFood) {
        if (self.suggestionTableView) {
            [self.suggestionTableView.popController dismissPopoverAnimated:YES];
            self.suggestionTableView = nil;
        }
    }
}

/*!
 * This method will be called when the return button on the text field is tapped.
 * @param textField the textField
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.txtQuantity]) {
        [self.txtFood becomeFirstResponder];
    }
    else if ([textField isEqual:self.txtFood]) {
        [self.txtComment becomeFirstResponder];
    }
    return YES;
}

/**
 * tells delegate value is selected in table view.
 * @param picker the picker view.
 * @param val the selected val.
 */
- (void)tableView:(BaseCustomTableView *)tableView didSelectValue:(NSString *)val {
    self.txtFood.text = val;
    [self.txtFood resignFirstResponder];
}
@end
