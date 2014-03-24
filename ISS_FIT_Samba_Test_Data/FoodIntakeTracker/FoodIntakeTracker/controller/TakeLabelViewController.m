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
//  TakeLabelViewController.m
//  FoodIntakeTracker
//
//  Created by lofzcx 06/25/2013
//

#import "TakeLabelViewController.h"
#import "TakePhotoViewController.h"
#import "Helper.h"
#import "AppDelegate.h"
#import "FoodProductServiceImpl.h"

@implementation TakeLabelViewController

/**
 * This method will initialize the view.
 */
- (void)viewDidLoad{
    [super viewDidLoad];
    [[self.searchBar.subviews objectAtIndex:0] setHidden:YES];
    [[self.searchBar.subviews objectAtIndex:0] removeFromSuperview];
    [self.scrollView setContentSize:CGSizeMake(560, 54)];
    for (UIView *subview in self.searchBar.subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [subview removeFromSuperview];
            break;
        }
    }
}

/**
 * release resource by setting nil value.
 */
- (void)viewDidUnload {
    [self setLblNoteBottom:nil];
    [self setImgPhoto:nil];
    [self setSearchBar:nil];
    [self setImgBG:nil];
    [super viewDidUnload];
}

/**
 * show clear label after a delay of 1.
 * @param animated If YES, the view is being added to the window using an animation.
 */
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self take:self.takeButton];
}

/**
 * show clear label and update scan line, bracket, note label at top.
 */
- (void)showClearLabel{
}

/**
 * action for cancel button in progress view.
 * @param sender the button.
 */
- (IBAction)cancelProcessing:(id)sender {
    [updateProcessTimer invalidate];
    updateProcessTimer = nil;
    self.processView.hidden = YES;
    self.lblNoteBottom.hidden = NO;
    
    [self.btnTake setEnabled:YES];
    [self.lblTakeButtonTitle setTextColor:[UIColor colorWithRed:0.2 green:0.43 blue:0.62 alpha:1]];
    
    self.lblTakeButtonTitle.text = @"Scan Label";
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showClearLabel) object:nil];
    
    [self performSelector:@selector(showClearLabel) withObject:nil afterDelay:1];
    
}

/**
 * This method will take picture.
 * @param sender the button.
 */
- (IBAction)take:(id)sender{
    UIButton *button = (UIButton *)sender;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
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
 * This method will take another picture.
 * @param sender the button.
 */
- (IBAction)takeAnotherPhoto:(id)sender {
    self.resultView.hidden = YES;
    [self.foodAddedPopup setHidden:YES];
}

/**
 * This method will add food to consumption.
 * @param sender the button.
 */
- (IBAction)addToConsumption:(id)sender {
    [self addSelectedFoodsToConsumption];
    self.resultView.hidden = YES;
    [self.foodAddedPopup setHidden:NO];
}

#pragma mark - UISearchBarDelegate methods
/**
 * This method will filter by food product name.
 * @param searchBar the searchBar.
 */
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    FoodProductServiceImpl *foodProductService = appDelegate.foodProductService;
    NSError *error;
    FoodProduct* foodProduct = [foodProductService getFoodProductByName:appDelegate.loggedInUser
                                                                   name:searchBar.text
                                                                  error:&error];
    if ([Helper displayError:error]) return;
    [resultFoods addObject:foodProduct];
    
    self.resultView.hidden = NO;
    self.imgFood.image = [UIImage imageNamed:foodProduct.productProfileImage];
    self.lblFoodName.text = foodProduct.name;
    self.lblFoodCategory.text = foodProduct.category;
    self.lblCalories.text = [NSString stringWithFormat:@"%@",foodProduct.energy];
    self.lblSodium.text = [NSString stringWithFormat:@"%@",foodProduct.sodium];
    self.lblFluid.text = [NSString stringWithFormat:@"%@",foodProduct.fluid];
    self.lblProtein.text = [NSString stringWithFormat:@"%@",foodProduct.protein];
    self.lblCarb.text = [NSString stringWithFormat:@"%@",foodProduct.carb];
    self.lblFat.text = [NSString stringWithFormat:@"%@",foodProduct.fat];
    [self.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self buildResults];
    
    [self.view bringSubviewToFront:self.resultView];
    [self.btnTake setEnabled:YES];
    self.lblTakeButtonTitle.text = @"Scan Another Label";
    [self.lblTakeButtonTitle setTextColor:[UIColor colorWithRed:0.2 green:0.43 blue:0.62 alpha:1]];
    [self.btnResults setEnabled:YES];
    [searchBar resignFirstResponder];
    [self dismissModalViewControllerAnimated:NO];
}

/**
 * This method will be called when the picture is taken.
 * @param picker the UIImagePickerController
 * @param info the information
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    photoImage.image = chosenImage;
    self.processView.hidden = NO;
    self.prgProcess.progress = 0.0;
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    tesseract = [[Tesseract alloc] initWithDataPath:appDelegate.tesseractDataPath language:@"eng"];
    [tesseract setImage:chosenImage];
    self.prgProcess.progress = 0.5;
    BOOL succeeded = [tesseract recognize];
    self.prgProcess.progress = 1.0;
    if (succeeded) {
        self.processView.hidden = YES;
        NSString *label = [tesseract recognizedText];
        // Remove trailing characters
        if (label.length > 0 && [[label substringFromIndex:MAX(label.length - 2, 0)] isEqualToString:@"\n\n"]) {
            label = [label substringToIndex:MAX(label.length - 2, 0)];
        }
        
        AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        FoodProductServiceImpl *foodProductService = appDelegate.foodProductService;
        NSError *error;
        FoodProduct *foodProduct = [foodProductService getFoodProductByName:appDelegate.loggedInUser
                                                                       name:label
                                                                      error:&error];
        if (error) {
            if ([error code] == EntityNotFoundErrorCode) {
                [Helper showAlert:@"Not Found" message:error.userInfo[NSLocalizedDescriptionKey]];
            }
            else {
                [Helper displayError:error];
                return;
            }
        }
        else {
            [resultFoods addObject:foodProduct];
            self.resultView.hidden = NO;
            self.imgFood.image = [UIImage imageNamed:foodProduct.productProfileImage];
            self.lblFoodName.text = foodProduct.name;
            [self buildResults];
            
            [self.view bringSubviewToFront:self.resultView];
            [self.btnTake setEnabled:YES];
            self.lblTakeButtonTitle.text = @"Scan Another Label";
            [self.lblTakeButtonTitle setTextColor:[UIColor colorWithRed:0.2 green:0.43 blue:0.62 alpha:1]];
            [self.btnResults setEnabled:YES];
        }

        [self.popover dismissPopoverAnimated:YES];
    }
    [tesseract clear];
}
/**
 * This method will be called when the picture taking is cancelled.
 * @param picker the UIImagePickerController
 */
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.popover dismissPopoverAnimated:YES];
    self.processView.hidden = NO;
}
@end

