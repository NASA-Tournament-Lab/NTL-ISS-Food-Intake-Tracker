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
//  TakePhotoViewController.m
//  FoodIntakeTracker
//
//  Created by lofzcx 06/25/2013
//

#import "TakePhotoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Helper.h"
#import "FoodProductServiceImpl.h"
#import "AppDelegate.h"

@implementation TakePhotoViewController

/**
 * initialize categories array, setting photo image.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    FoodProductServiceImpl *foodProductService = appDelegate.foodProductService;
    NSError *error;
    categories = [NSMutableArray arrayWithArray:[foodProductService getAllProductCategories:&error]];
    if ([Helper displayError:error]) return;
    [self.preview insertSubview:photoImage belowSubview:self.imgCenter];
}

/**
 * release resource by setting nil value.
 */
- (void)viewDidUnload {
    [self setCategoryPickerView:nil];
    [self setCategoryPicker:nil];
    [super viewDidUnload];
}

/**
 * called when help setting page did appear. We set default view here.
 * @param animate If YES, the view is being added to the window using an animation.
 */
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self take:self.takeButton];
}

/**
 * hide the category picker view.
 * @param sender nil or the button.
 */
- (IBAction)hideCategoryPicker:(id)sender {
    [clearCover removeFromSuperview];
    clearCover = nil;
    
    self.categoryPickerView.hidden = YES;
}

/**
 * action for done button in category picker view.
 * @param sender the button.
 */
- (IBAction)pickerDoneButtonClick:(id)sender {
    self.lblFoodCategory.text = [categories objectAtIndex:[self.categoryPicker selectedRowInComponent:0]];
    [self hideCategoryPicker:sender];
}

/**
 * showing the category picker view.
 * @param sender the button.
 */
- (IBAction)showCategoryList:(id)sender {
    
    UIButton *btn = [[UIButton alloc] initWithFrame:self.view.frame];
    [btn addTarget:self action:@selector(hideCategoryPicker:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    clearCover = btn;
    
    [self.txtFoodName resignFirstResponder];
    
    self.categoryPickerView.hidden = NO;
    [self.view bringSubviewToFront:self.categoryPickerView];
}

/**
 * action for take photo button clicking.
 * @param sender the button.
 */
- (IBAction)take:(id)sender{
    UIButton *button = (UIButton *)sender;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        picker.cameraViewTransform = CGAffineTransformScale(picker.cameraViewTransform, -1, 1);
    }
    else {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    self.popover = [[UIPopoverController alloc] initWithContentViewController:picker];
    self.popover.delegate = self;
    [self.popover presentPopoverFromRect:button.frame
                                  inView:button.superview
                permittedArrowDirections:UIPopoverArrowDirectionAny
                                animated:YES];
}

/**
 * action for take another photo button clicking.
 * @param sender the button.
 */
- (IBAction)takeAnotherPhoto:(id)sender {
    if(self.resultView.hidden == NO){
        [self.txtFoodName resignFirstResponder];
        self.txtFoodName.text = [self.txtFoodName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        FoodProductServiceImpl *foodProductService = appDelegate.foodProductService;
        NSError *error;
        
        if([self.lblFoodCategory.text isEqualToString:@"Select Food Category"] || self.txtFoodName.text.length == 0){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Please enter food name and select food category"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        AdhocFoodProduct *adhocFoodProduct = [foodProductService buildAdhocFoodProduct:&error];
        if ([Helper displayError:error]) return;
        adhocFoodProduct.name = self.txtFoodName.text;
        adhocFoodProduct.category = self.lblFoodCategory.text;
        NSString *imagePath = [Helper saveImage:UIImageJPEGRepresentation(self.imgFood.image,1.0)];
        adhocFoodProduct.productProfileImage = imagePath;
        [foodProductService addAdhocFoodProduct:appDelegate.loggedInUser product:adhocFoodProduct error:&error];
        if ([Helper displayError:error]) return;
        [resultFoods addObject:adhocFoodProduct];
        [self buildResults];
        [self.btnResults setEnabled:YES];
    }
    
    [self.preview insertSubview:photoImage belowSubview:self.imgCenter];
    self.imgCenter.hidden = NO;
    self.lblTakeButtonTitle.text = @"Take Photo";
    
    [clearCover removeFromSuperview];
    clearCover = nil;
    self.resultView.hidden = YES;
    self.foodAddedPopup.hidden = YES;
    self.resultsView.hidden = YES;
    self.btnAdd.hidden = YES;
    [self.btnResults setSelected:NO];
    
    // Take picture
    [self take:self.btnTake];
}

/**
 * action for add to consumption button clicking.
 * @param sender the button.
 */
- (IBAction)addToConsumption:(id)sender {
    if(self.resultView.hidden == NO){
        [self.txtFoodName resignFirstResponder];
        // Validate the food name
        self.txtFoodName.text = [self.txtFoodName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if([self.lblFoodCategory.text isEqualToString:@"Select Food Category"] || self.txtFoodName.text.length == 0){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Please enter food name and select food category"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        FoodProductServiceImpl *foodProductService = appDelegate.foodProductService;
        NSError *error;
        AdhocFoodProduct *adhocFoodProduct = [foodProductService buildAdhocFoodProduct:&error];
        if ([Helper displayError:error]) return;
        adhocFoodProduct.name = self.txtFoodName.text;
        adhocFoodProduct.category = self.lblFoodCategory.text;
        NSString *imagePath = [Helper saveImage:UIImageJPEGRepresentation(self.imgFood.image,1.0)];
        adhocFoodProduct.productProfileImage = imagePath;
        [foodProductService addAdhocFoodProduct:appDelegate.loggedInUser product:adhocFoodProduct error:&error];
        if ([Helper displayError:error]) return;
        [resultFoods addObject:adhocFoodProduct];
        [self buildResults];
        [self.btnResults setEnabled:YES];
        self.resultView.hidden = YES;
    }
    self.foodAddedPopup.hidden = NO;
    [self addSelectedFoodsToConsumption];
}

/**
 * Cancel the photo current is taken.
 * @param sender the button.
 */
- (IBAction)cancelTake:(id)sender{
    self.imgCenter.hidden = NO;
    self.lblTakeButtonTitle.text = @"Take Photo";
    [self.txtFoodName resignFirstResponder];
    
    [clearCover removeFromSuperview];
    clearCover = nil;
    self.resultView.hidden = YES;
    self.foodAddedPopup.hidden = YES;
    self.btnAdd.hidden = YES;
    self.resultsView.hidden = YES;
    [self.btnResults setSelected:NO];
}

#pragma mark - Picker delegate
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
    return categories.count;
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
        ((UILabel *)view).text = [categories objectAtIndex:row];
        return view;
    }
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont boldSystemFontOfSize:20];
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.text = [categories objectAtIndex:row];
    return label;
}

/*!
 * This method will be called when the picture is taken.
 * @param picker the UIImagePickerController
 * @param info the information
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    photoImage.image = chosenImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [photoImage removeFromSuperview];
    self.txtFoodName.text = @"";
    self.lblFoodCategory.text = @"Select Food Category";
    self.imgFood.image = chosenImage;
    self.resultView.hidden = NO;
    [self.categoryPicker selectRow:0 inComponent:0 animated:NO];
    self.imgCenter.hidden = YES;
    [self.view bringSubviewToFront:self.resultView];
    self.lblTakeButtonTitle.text = @"Take Another Photo";
    self.resultsView.hidden = YES;
    [self.btnResults setSelected:NO];
    
    [self.popover dismissPopoverAnimated:YES];
}

/*!
 * This method will be called when the picture taking is cancelled.
 * @param picker the UIImagePickerController
 */
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.popover dismissPopoverAnimated:YES];
}

@end

