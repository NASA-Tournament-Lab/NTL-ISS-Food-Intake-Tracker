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
//  TakeBarcodeViewController.m
//  FoodIntakeTracker
//
//  Created by lofzcx 06/25/2013
//

#import "TakeBarcodeViewController.h"
#import "TakePhotoViewController.h"
#import "Helper.h"
#import "DataHelper.h"

#import <MultiFormatReader.h>
#import "AppDelegate.h"
#import "FoodProductServiceImpl.h"

@implementation TakeBarcodeViewController

/**
 * hide serach bar background here.
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
    [self take:nil];
}
/**
 * release resource by setting nil value.
 */
- (void)viewDidUnload {
    [self setLblNoteBottom:nil];
    [self setImgPhoto:nil];
    [self setScanLine:nil];
    [self setSearchBar:nil];
    [self setImgBG:nil];
    [self setImgBracket:nil];
    [super viewDidUnload];
}

/**
 * show clear barcode after a delay of 1.
 * @param animated If YES, the view is being added to the window using an animation.
 */
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self performSelector:@selector(showClearBarcode) withObject:nil afterDelay:0.0];
}

/**
 * show clear Barcode and update scan line, bracket, note label at top.
 */
- (void)showClearBarcode{
    self.imgPhoto.image = [UIImage imageNamed:@"icon-barcode-b.png"];
    self.imgBracket.image = [UIImage imageNamed:@"icon-bracket-blue.png"];
    self.scanLine.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:1];
}

/**
 * action for cancel button in progress view.
 * @param sender the button.
 */
- (IBAction)cancelProcessing:(id)sender {
    [updateProcessTimer invalidate];
    updateProcessTimer = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showClearBarcode) object:nil];
    self.processView.hidden = YES;
    [self takeAnotherPhoto:nil];
}

/**
 * This method will take picture.
 * @param sender the button.
 */
- (IBAction)take:(id)sender{
    [self.btnTake setEnabled:NO];
    [self.lblTakeButtonTitle setTextColor:[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1]];
    
    self.imgBG.hidden = YES;
    self.imgBracket.hidden = YES;
    self.scanLine.hidden = YES;
    self.lblNoteBottom.hidden = YES;
    self.prgProcess.progress = 0;
    //self.processView.hidden = NO;
    //[self.view bringSubviewToFront:self.processView];
    
    ZXingWidgetController *widController = [[ZXingWidgetController alloc] initWithDelegate:self
                                                                                showCancel:YES
                                                                                  OneDMode:NO
                                                                               showLicense:NO];
    
    
    NSMutableSet *readers = [[NSMutableSet alloc ] init];
    
    MultiFormatReader* reader = [[MultiFormatReader alloc] init];
    [readers addObject:reader];
    
    widController.readers = readers;
    
    [self presentModalViewController:widController animated:YES];
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
 * This method will filter by food product
 * @param searchBar the searchBar.
 */
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    FoodProductServiceImpl *foodProductService = appDelegate.foodProductService;
    NSError *error;
    
    FoodProduct* foodProduct = [foodProductService getFoodProductByBarcode:appDelegate.loggedInUser
                                                                   barcode:searchBar.text
                                                                     error:&error];
    if ([Helper displayError:error]) return;
    
    [resultFoods addObject:foodProduct];
    
    self.resultView.hidden = NO;
    self.imgFood.image = [Helper loadImage:foodProduct.productProfileImage];
    self.lblFoodName.text = foodProduct.name;
    self.lblFoodCategory.text = [DataHelper convertStringWrapperNSSetToNSString:foodProduct.categories withSeparator:@", "];
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
    self.lblTakeButtonTitle.text = @"Scan Another Barcode";
    [self.lblTakeButtonTitle setTextColor:[UIColor colorWithRed:0.2 green:0.43 blue:0.62 alpha:1]];
    [self.btnResults setEnabled:YES];
    
    [self dismissModalViewControllerAnimated:NO];
    [self.searchBar resignFirstResponder];
}

#pragma mark - ZXingDelegate methods
/*!
 * This method will be called when the barcode is recognized.
 * @param controller the ZXingWidgetController
 * @param result the result barcode
 */
- (void)zxingController:(ZXingWidgetController *)controller didScanResult:(NSString *)result {
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    FoodProductServiceImpl *foodProductService = appDelegate.foodProductService;
    NSError *error;
    
    NSLog(@"Barcode scan results: %@", result);
    
    FoodProduct* foodProduct = [foodProductService getFoodProductByBarcode:appDelegate.loggedInUser
                                                                   barcode:result
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
        self.imgFood.image = [Helper loadImage:foodProduct.productProfileImage];
        self.lblFoodName.text = foodProduct.name;
<<<<<<< HEAD
        self.lblFoodCategory.text = [DataHelper convertStringWrapperNSSetToNSString:foodProduct.categories withSeparator:@", "];
=======
        self.lblFoodCategory.text = foodProduct.category;
>>>>>>> 7d183cd79eaceb537437987a93602b139f9bedb0
        self.lblCalories.text = [NSString stringWithFormat:@"%@",foodProduct.energy];
        self.lblSodium.text = [NSString stringWithFormat:@"%@",foodProduct.sodium];
        self.lblFluid.text = [NSString stringWithFormat:@"%@",foodProduct.fluid];
        self.lblProtein.text = [NSString stringWithFormat:@"%@",foodProduct.protein];
        self.lblCarb.text = [NSString stringWithFormat:@"%@",foodProduct.carb];
        self.lblFat.text = [NSString stringWithFormat:@"%@",foodProduct.fat];

        [self buildResults];
        
        [self.view bringSubviewToFront:self.resultView];
        self.lblTakeButtonTitle.text = @"Scan Another Barcode";
        [self.lblTakeButtonTitle setTextColor:[UIColor colorWithRed:0.2 green:0.43 blue:0.62 alpha:1]];
        [self.btnResults setEnabled:YES];
    }
    
    [self.btnTake setEnabled:YES];
    [self dismissModalViewControllerAnimated:NO];
}

/*!
 * This method will be called when the scanning is cancelled.
 * @param controller the ZXingWidgetController
 */
- (void)zxingControllerDidCancel:(ZXingWidgetController *)controller {
    [self dismissModalViewControllerAnimated:NO];
    [self.btnTake setEnabled:YES];
}

@end
