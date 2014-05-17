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
//  PhotoListViewController.m
//  FoodIntakeTracker
//
//  Created by lofzcx 06/25/2013
//
//  Updated by pvmagacho on 05/07/2014
//  F2Finish - NASA iPad App Updates
//

#import "PhotoListViewController.h"
#import "Helper.h"
#import "AppDelegate.h"
#import "FoodProductServiceImpl.h"
#import <QuartzCore/QuartzCore.h>
#import "FoodConsumptionRecordServiceImpl.h"
#import "ConsumptionViewController.h"

@interface PhotoListViewController (){
    /* the foods */
    NSMutableArray *foodItems;
    /* the selected foods */
    NSMutableArray *selectFoods;
    /* sort by options */
    NSMutableArray *sortByOptionArray;
}

@end

@implementation PhotoListViewController
/**
 * Called when view will be presented.
 * Update tab bar selected tab to nil here.
 * @param animated If YES, the view is being added to the window using an animation.
 */
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.customTabBarController.tabView.hidden = NO;
    self.customTabBarController.imgConsumption.image = [UIImage imageNamed:@"icon-consumption"];
    [self.customTabBarController.btnConsumption setImage:nil forState:UIControlStateNormal];
    self.customTabBarController.activeTab = 0;
}

/**
 * This method will initialize the view.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self.searchBar.subviews objectAtIndex:0] setHidden:YES];
    [[self.searchBar.subviews objectAtIndex:0] removeFromSuperview];
    for (UIView *subview in self.searchBar.subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [subview removeFromSuperview];
            break;
        }
    }
    
    selectFoods = [[NSMutableArray alloc] init];
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    FoodProductServiceImpl *foodProductService = appDelegate.foodProductService;
    NSError *error;
    
    FoodProductFilter *filter = [foodProductService buildFoodProductFilter:&error];
    if ([Helper displayError:error]) return;
    filter.adhocOnly = @YES;
    foodItems = [NSMutableArray arrayWithArray:[foodProductService
                                                filterFoodProducts:appDelegate.loggedInUser
                                                filter:filter
                                                error:&error]];
    
    [self buildPhotos];
    
    self.lblDeletePopupTitle.font = [UIFont fontWithName:@"Bebas" size:20];
    self.lblTitle.font = [UIFont fontWithName:@"Bebas" size:24];
    
    sortByOptionArray = [NSMutableArray arrayWithObjects:
                         @"Alphabetically (A to Z)",
                         @"Alphabetically (Z to A)",
                         @"Nutrient Content (kcal)",
                         @"Nutrient Content (sodium)",
                         @"Nutrient Content (liquid)",
                         @"Nutrient Content (protein)",
                         @"Nutrient Content (carb)",
                         @"Nutrient Content (fat)",
                         @"Frequency (High To Low)",
                         @"Frequency (Low To High)",
                         nil];
    
    
    self.sortByListView.delegate = self;
    self.sortByListView.options = sortByOptionArray;
    self.sortByListView.selectIndex = 0;
}

/**
 * click food photo in the grid view.
 * @param btn the button.
 */
- (void)clickPhoto:(UIButton *)btn{
    int row = btn.tag;
    FoodProduct *item = [foodItems objectAtIndex:row];
    if([selectFoods containsObject:item]){
        [selectFoods removeObject:item];
        UIView *v = [btn.superview viewWithTag:10];
        [v removeFromSuperview];
    }
    else{
        [selectFoods addObject:item];
        
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(151, 24, 29, 29)];
        img.image = [UIImage imageNamed:@"btn-checkmark.png"];
        img.tag = 10;
        [btn.superview addSubview:img];
    }
    if(selectFoods.count == 0){
        [self.btnAdd setEnabled:NO];
        [self.btnDelete setEnabled:NO];
    }
    else{
        [self.btnAdd setEnabled:YES];
        [self.btnDelete setEnabled:YES];
    }
}

/**
 * fill the scrollview with the food items.
 */
- (void)buildPhotos{
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:self.scrollView.frame];
    scroll.contentSize = CGSizeMake(768, 220 * ceil(foodItems.count / 4.0));
    for(int i = 0; i < foodItems.count; i++){
        FoodProduct *item = [foodItems objectAtIndex:i];
        int x = (i % 4) * 190;
        int y = (i / 4) * 220;
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(x, y, 190, 220)];
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(17, 17, 170, 170)];
        img.layer.borderColor = [UIColor colorWithRed:0.54 green:0.79 blue:1 alpha:1].CGColor;
        img.layer.borderWidth = 1;
        img.image = [Helper loadImage:item.productProfileImage];
        [v addSubview:img];
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(17, 192, 179, 21)];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:15];
        lbl.text = item.name;
        lbl.textColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1];
        [v addSubview:lbl];
        UIButton *btn = [[UIButton alloc] initWithFrame:img.frame];
        btn.tag = i;
        [btn addTarget:self action:@selector(clickPhoto:) forControlEvents:UIControlEventTouchUpInside];
        [v addSubview:btn];
        if([selectFoods containsObject:item]){
            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(151, 24, 29, 29)];
            img.image = [UIImage imageNamed:@"btn-checkmark.png"];
            img.tag = 10;
            [v addSubview:img];
        }
        [scroll addSubview:v];
    }
    [self.scrollView.superview insertSubview:scroll belowSubview:self.scrollView];
    [self.scrollView removeFromSuperview];
    self.scrollView = scroll;
}

/**
 * release resource by setting nil value.
 */
- (void)viewDidUnload {
    [self setLblTitle:nil];
    [self setBtnDelete:nil];
    [self setBtnAdd:nil];
    [self setScrollView:nil];
    [self setLblSortBy:nil];
    [self setSearchBar:nil];
    [self setLblDeletePopupTitle:nil];
    [self setDeletePopup:nil];
    [self setSortByListView:nil];
    [super viewDidUnload];
}
/**
 * show the delete confirm panel.
 * @param sender the button.
 */
- (IBAction)showDeletePanel:(id)sender {
    UIButton *btn = [[UIButton alloc] initWithFrame:self.view.frame];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(hideDeletePopup:) forControlEvents:UIControlEventTouchUpInside];
    clearCover = btn;
    
    self.deletePopup.hidden = NO;
    [self.view bringSubviewToFront:self.deletePopup];
    [self.btnAdd setEnabled:NO];
    [self.btnDelete setSelected:YES];
}
/**
 * add foods to consumption.
 * @param sender the button.
 */
- (IBAction)addToConsumption:(id)sender {
    if ([selectFoods count] == 0) {
        return;
    }
    
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    FoodConsumptionRecordServiceImpl *recordService = appDelegate.foodConsumptionRecordService;
    NSError *error;
    ConsumptionViewController *consumptionViewController = [self.customTabBarController getConsumptionViewController];
    for (FoodProduct *product in selectFoods) {
        FoodConsumptionRecord *record = [recordService buildFoodConsumptionRecord:&error];
        record.quantity = @1;
        record.sodium = product.sodium;
        record.energy = product.energy;
        record.fluid = product.fluid;
        record.protein = product.protein;
        record.carb = product.carb;
        record.fat = product.fat;
        record.timestamp = [self.customTabBarController currentSelectedDate];
        [recordService addFoodConsumptionRecord:appDelegate.loggedInUser record:record error:&error];
        record.foodProduct = product;
        [recordService saveFoodConsumptionRecord:record error:&error];
        
        if ([Helper displayError:error]) return;
        [consumptionViewController.foodConsumptionRecords addObject:record];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DataSyncUpdateInterval" object:[self.customTabBarController currentSelectedDate]];

    [selectFoods removeAllObjects];
    [consumptionViewController updateProgress];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.customTabBarController setConsumptionActive];
}
/**
 * return back to take photo view.
 * @param sender the button.
 */
- (IBAction)returnBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
/**
 * This method will delete adhoc food product.
 * @param sender the button.
 */
- (IBAction)hideDeletePopup:(id)sender {
    [clearCover removeFromSuperview];
    clearCover = nil;
    
    self.deletePopup.hidden = YES;
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    FoodProductServiceImpl *foodProductService = appDelegate.foodProductService;
    NSError *error;
    for (AdhocFoodProduct *product in selectFoods) {
        [foodProductService deleteAdhocFoodProduct:product error:&error];
        if ([Helper displayError:error]) return;
    }
}

/**
 * action for delete button click in delete panel. Remove photos and reload list view.
 * @param sender the button.
 */
- (IBAction)deletePhotos:(id)sender {
    
    for(FoodProduct *item in selectFoods){
        [foodItems removeObject:item];
    }
    [selectFoods removeAllObjects];
    [self.btnDelete setEnabled:NO];
    [self.btnAdd setEnabled:NO];
    
    [self buildPhotos];
    [self hideDeletePopup:nil];
}

/**
 * show sort by list view.
 * @param sender the button.
 */
- (IBAction)showSortByList:(id)sender{
    UIButton *btn = [[UIButton alloc] initWithFrame:self.view.frame];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(hideSortByList:) forControlEvents:UIControlEventTouchUpInside];
    clearCover = btn;
    
    self.sortByListView.hidden = NO;
    [self.view bringSubviewToFront:self.sortByListView];
}

/**
 * hide sort by list view.
 * @param sender the button.
 */
- (IBAction)hideSortByList:(id)sender{
    self.sortByListView.hidden = YES;
    [clearCover removeFromSuperview];
    clearCover = nil;
}
#pragma mark - SettingListViewDelegate
/**
 * called when value is selected in sort by option list.
 * @param index the selected index.
 */
- (void)listviewDidSelect:(int)index{
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    FoodProductServiceImpl *foodProductService = appDelegate.foodProductService;
    NSError *error;
    FoodProductFilter *filter = [foodProductService buildFoodProductFilter:&error];
    if ([Helper displayError:error]) return;
    filter.adhocOnly = @YES;
    int sortOption = 0;
    switch (index) {
        case 0:
            sortOption = A_TO_Z;
            break;
        case 1:
            sortOption = Z_TO_A;
            break;
        case 2:
            sortOption = ENERGY_HIGH_TO_LOW;
            break;
        case 3:
            sortOption = SODIUM_HIGH_TO_LOW;
            break;
        case 4:
            sortOption = FLUID_HIGH_TO_LOW;
            break;
        case 5:
            sortOption = PROTEIN_HIGH_TO_LOW;
            break;
        case 6:
            sortOption = CARB_HIGH_TO_LOW;
            break;
        case 7:
            sortOption = FAT_HIGH_TO_LOW;
            break;
        case 8:
            sortOption = FREQUENCY_HIGH_TO_LOW;
            break;
        case 9:
            sortOption = FREQUENCY_LOW_TO_HIGH;
            break;
    }
    
    filter.sortOption = [NSNumber numberWithInt:sortOption];
    foodItems = [NSMutableArray arrayWithArray:[foodProductService filterFoodProducts:appDelegate.loggedInUser
                                                                               filter:filter
                                                                                error:&error]];
    if ([Helper displayError:error]) return;
    [self buildPhotos];
    [self hideSortByList:nil];
    self.lblSortBy.text = [sortByOptionArray objectAtIndex:self.sortByListView.selectIndex];
}

#pragma mark - UISearchBarDelegate methods
/**
 * called when keyboard search button pressed. Perform filtering here. Just leave empty now.
 * @param searchBar the searchBar.
 */
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

/**
 * show a clear cover. When clicking the cover will hide the search bar.
 * @param searchBar the searchBar.
 */
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    UIButton *btn = [[UIButton alloc] initWithFrame:self.view.frame];
    [self.view addSubview:btn];
    [btn addTarget:self.searchBar
            action:@selector(resignFirstResponder)
  forControlEvents:UIControlEventTouchUpInside];
    clearCover = btn;
}

/**
 * hide the clear cover.
 * @param searchBar the searchBar.
 */
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [clearCover removeFromSuperview];
    clearCover = nil;
    
    if (self.suggestionTableView) {
        [self.suggestionTableView.popController dismissPopoverAnimated:YES];
        self.suggestionTableView = nil;
    }
}

/**
 * called when keyboard search text is changed. Perform filtering here.
 * @param searchBar the searchBar.
 */
- (void)searchBar:(UISearchBar *)bar textDidChange:(NSString *)searchText {
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    FoodProductServiceImpl *foodProductService = appDelegate.foodProductService;
    NSError *error;
    FoodProductFilter *filter = [foodProductService buildFoodProductFilter:&error];
    filter.adhocOnly = @YES;
    filter.name = searchText;
    foodItems = [NSMutableArray arrayWithArray:[foodProductService filterFoodProducts:appDelegate.loggedInUser
                                                                               filter:filter
                                                                                error:&error]];
    if ([Helper displayError:error]) return;
    [self buildPhotos];
    
    if (!self.suggestionTableView) {
        self.suggestionTableView = [self.storyboard instantiateViewControllerWithIdentifier:@"AutoSuggestionView"];
        self.suggestionTableView.delegate = self;
        UIPopoverController *popController =
        [[UIPopoverController alloc] initWithContentViewController:self.suggestionTableView];
        popController.popoverContentSize = CGSizeMake(290, 267);
        popController.delegate = self;
        self.suggestionTableView.popController = popController;
        [popController presentPopoverFromRect:self.searchBar.frame
                                       inView:self.searchBar.superview
                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                     animated:YES];
    }
    
    if (self.suggestionTableView) {
        NSMutableArray *suggestions = [NSMutableArray array];
        for (int i = 0; i < foodItems.count; i++) {
            AdhocFoodProduct *product = foodItems[i];
            NSString *productName = [product.name uppercaseString];
            if ([searchText isEqualToString:@""] || [productName rangeOfString:[searchText uppercaseString]].location == 0) {
                [suggestions addObject:product.name];
            }
        }
        self.suggestionTableView.suggestions = suggestions;
        [self.suggestionTableView.theTableView reloadData];
    }
}

/**
 * tells delegate value is selected in table view.
 * @param picker the picker view.
 * @param val the selected val.
 */
- (void)tableView:(BaseCustomTableView *)tableView didSelectValue:(NSString *)val {
    self.searchBar.text = val;
    [self searchBar:self.searchBar textDidChange:val];
    [self.searchBar resignFirstResponder];
}

@end
