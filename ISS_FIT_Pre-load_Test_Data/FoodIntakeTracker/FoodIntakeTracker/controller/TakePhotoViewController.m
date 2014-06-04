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
//  Updated by pvmagacho on 05/14/2014
//  F2Finish - NASA iPad App Updates - Round 3
//

#import "TakePhotoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Helper.h"
#import "DataHelper.h"
#import "DBHelper.h"
#import "FoodProductServiceImpl.h"
#import "FoodConsumptionRecordServiceImpl.h"
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
    
    [self.scrollView setContentSize:CGSizeMake(560, 54)];
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
    // [self take:self.takeButton];
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
        //picker.cameraViewTransform = CGAffineTransformScale(picker.cameraViewTransform, -1, 1);
    }
    else {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    self.takeButton.hidden = YES;
    self.lblTakeButtonTitle.hidden = YES;
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
        
        StringWrapper *stringWrapper = [[StringWrapper alloc] initWithEntity:[NSEntityDescription
                                                                              entityForName:@"StringWrapper"
                                                                              inManagedObjectContext:
                                                                              foodProductService.managedObjectContext]
                                              insertIntoManagedObjectContext:nil];
        stringWrapper.value = self.lblFoodCategory.text;
        adhocFoodProduct.categories = [NSSet setWithObject:stringWrapper];
        
        NSString *imagePath = [Helper saveImage:UIImageJPEGRepresentation(self.imgFood.image,1.0)];
        adhocFoodProduct.productProfileImage = imagePath;
        
        stringWrapper = [[StringWrapper alloc] initWithEntity:[NSEntityDescription
                                                               entityForName:@"StringWrapper"
                                                               inManagedObjectContext:
                                                               foodProductService.managedObjectContext]
                               insertIntoManagedObjectContext:nil];
        stringWrapper.value = imagePath;
        adhocFoodProduct.images = [NSSet setWithObject:stringWrapper];
        
        [foodProductService addAdhocFoodProduct:appDelegate.loggedInUser product:adhocFoodProduct error:&error];
        if ([Helper displayError:error]) return;
        [resultFoods addObject:adhocFoodProduct];
        [self buildResults];
        [self.btnResults setEnabled:YES];
    } else if (self.resultViewFound.hidden == NO) {
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
    self.resultViewFound.hidden = YES;
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
        
        if ([Helper displayError:error]) {
            return;
        }
        
        adhocFoodProduct.name = self.txtFoodName.text;
        
        StringWrapper *stringWrapper = [[StringWrapper alloc] initWithEntity:[NSEntityDescription
                                                                              entityForName:@"StringWrapper"
                                                                              inManagedObjectContext:
                                                                              foodProductService.managedObjectContext]
                                              insertIntoManagedObjectContext:nil];
        stringWrapper.value = self.lblFoodCategory.text;
        adhocFoodProduct.categories = [NSSet setWithObject:stringWrapper];
        
        CGFloat r = self.imgFood.image.size.width / self.imgFood.image.size.height;
        UIImage *resized = [self resizeImage:self.imgFood.image newSize:CGSizeMake(r * 800, 800)];
        NSString *imagePath = [Helper saveImage:UIImageJPEGRepresentation(resized, 1.0)];
        adhocFoodProduct.productProfileImage = imagePath;
        
        stringWrapper = [[StringWrapper alloc] initWithEntity:[NSEntityDescription
                                                                              entityForName:@"StringWrapper"
                                                                              inManagedObjectContext:
                                                                              foodProductService.managedObjectContext]
                                              insertIntoManagedObjectContext:nil];
        stringWrapper.value = imagePath;
        adhocFoodProduct.images = [NSSet setWithObject:stringWrapper];
        
        [foodProductService addAdhocFoodProduct:appDelegate.loggedInUser product:adhocFoodProduct error:&error];

        if ([Helper displayError:error]) {
            return;
        }
        
        [resultFoods addObject:adhocFoodProduct];
        [self buildResults];
        
        self.btnResults.enabled = YES;
        self.resultView.hidden = YES;
        self.foodAddedPopup.hidden = NO;
    } else if (self.resultViewFound.hidden == NO) {
        AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        FoodProductServiceImpl *foodProductService = appDelegate.foodProductService;

        FoodProduct *foodProduct = [resultFoods objectAtIndex:0];
        CGFloat r = self.imgFood.image.size.width / self.imgFood.image.size.height;
        UIImage *resized = [self resizeImage:self.imgFood.image newSize:CGSizeMake(r * 800, 800)];
        NSString *imagePath = [Helper saveImage:UIImageJPEGRepresentation(resized, 1.0)];

        [[foodProduct managedObjectContext] lock];
        StringWrapper *stringWrapper = [[StringWrapper alloc] initWithEntity:[NSEntityDescription
                                                                              entityForName:@"StringWrapper"
                                                                              inManagedObjectContext:
                                                                              foodProductService.managedObjectContext]
                                              insertIntoManagedObjectContext:foodProduct.managedObjectContext];
        stringWrapper.value = imagePath;
        [foodProduct addImagesObject:stringWrapper];
        
        [[foodProduct managedObjectContext] save:nil];
        [[foodProduct managedObjectContext] unlock];
        
        self.btnResults.enabled = YES;
        self.resultViewFound.hidden = YES;
        self.foodAddedPopup.hidden = NO;
    }
    [self addSelectedFoodsToConsumption];
    
    self.imgFood.image = nil;
    [resultFoods removeAllObjects];
}

/**
 * Cancel the photo current is taken.
 * @param sender the button.
 */
- (IBAction)cancelTake:(id)sender{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cancel" message:@"Would like to cancel photo?" delegate:self
                                              cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [alertView show];
}

/**
 * action for cancel button in progress view.
 * @param sender the button.
 */
- (IBAction)cancelProcessing:(id)sender {
    [updateProcessTimer invalidate];
    updateProcessTimer = nil;
    self.processView.hidden = YES;
    
    [self.btnTake setEnabled:YES];
    self.lblTakeButtonTitle.text = @"Take Photo";
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showClearLabel) object:nil];
    
    [self performSelector:@selector(showClearLabel) withObject:nil afterDelay:1];
    
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
    
    [self.popover dismissPopoverAnimated:YES];
    
    if ([self recognize:chosenImage]) {
        return;
    }
    
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
}

-(BOOL) recognize:(UIImage *)image {
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.4]];
    
    self.processView.hidden = NO;
    self.prgProcess.progress = 0.0;
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.4]];
    
    tesseract = [[Tesseract alloc] initWithDataPath:appDelegate.tesseractDataPath language:@"eng"];
    [tesseract setImage:image];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.4]];
    self.prgProcess.progress = 0.5;
    BOOL succeeded = [tesseract recognize];
    self.prgProcess.progress = 1.0;
    if (succeeded) {
        NSString *label = [tesseract recognizedText];
        // Remove trailing characters
        if (label.length > 0 && [[label substringFromIndex:MAX(label.length - 2, 0)] isEqualToString:@"\n\n"]) {
            label = [label substringToIndex:MAX(label.length - 2, 0)];
        }
        
        AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        FoodProductServiceImpl *foodProductService = appDelegate.foodProductService;
        NSError *error;
        FoodProductFilter *filter = [foodProductService buildFoodProductFilter:&error];
        filter.name = label;
        NSArray *results = [foodProductService filterFoodProducts:appDelegate.loggedInUser filter:filter error:&error];
        
        if (error || results.count == 0) {
            /* if ([error code] == EntityNotFoundErrorCode) {
                [Helper showAlert:@"Not Found" message:error.userInfo[NSLocalizedDescriptionKey]];
            } else {
                [Helper displayError:error];
            } */
            succeeded = NO;
        } else {
            FoodProduct *foodProduct = [results objectAtIndex:0];
            self.resultViewFound.hidden = NO;
            self.imgFoodFound.image = [UIImage imageNamed:foodProduct.productProfileImage];
            self.imgFood.image = image;
            self.lblFoodNameFound.text = foodProduct.name;
            self.lblFoodCategoryFound.text = @"";
            if (foodProduct.categories.count > 0) {
                self.lblFoodCategoryFound.text = [DataHelper convertStringWrapperNSSetToNSString:foodProduct.categories withSeparator:@", "];
            }
            self.lblCaloriesFound.text = [NSString stringWithFormat:@"%@",foodProduct.energy];
            self.lblSodiumFound.text = [NSString stringWithFormat:@"%@",foodProduct.sodium];
            self.lblFluidFound.text = [NSString stringWithFormat:@"%@",foodProduct.fluid];
            self.lblProteinFound.text = [NSString stringWithFormat:@"%@",foodProduct.protein];
            self.lblCarbFound.text = [NSString stringWithFormat:@"%@",foodProduct.carb];
            self.lblFatFound.text = [NSString stringWithFormat:@"%@",foodProduct.fat];
            [self.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            
            [resultFoods addObject:foodProduct];
            
            [self buildResults];
            
            [self.view bringSubviewToFront:self.resultViewFound];
            [self.btnTake setEnabled:YES];
            self.lblTakeButtonTitle.text = @"Take Photo";
            [self.lblTakeButtonTitle setTextColor:[UIColor colorWithRed:0.2 green:0.43 blue:0.62 alpha:1]];
            [self.btnResults setEnabled:YES];
        }
    }
    self.processView.hidden = YES;
    
    [tesseract clear];
    return succeeded;
}

/*!
 * This method will be called when the picture taking is cancelled.
 * @param picker the UIImagePickerController
 */
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self cancelTake:nil];
}

#pragma mark - PopoverControllerDelegate

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    [self cancelTake:nil];

    return NO;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    self.takeButton.hidden = NO;
    self.lblTakeButtonTitle.hidden = NO;
}

#pragma mark - AlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {       
        [self.popover dismissPopoverAnimated:YES];
        
        self.imgCenter.hidden = NO;
        self.takeButton.hidden = NO;
        self.lblTakeButtonTitle.hidden = NO;
        self.lblTakeButtonTitle.text = @"Take Photo";
        [self.txtFoodName resignFirstResponder];
        
        [clearCover removeFromSuperview];
        clearCover = nil;
        self.resultView.hidden = YES;
        self.resultViewFound.hidden = YES;
        self.foodAddedPopup.hidden = YES;
        self.btnAdd.hidden = YES;
        self.resultsView.hidden = YES;
        [self.btnResults setSelected:NO];
    }
}

- (UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end

