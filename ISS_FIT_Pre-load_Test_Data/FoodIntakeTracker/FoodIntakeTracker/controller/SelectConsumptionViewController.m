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
//  SelectConsumptionViewController.m
//  FoodIntakeTracker
//
//  Created by lofzcx 06/12/2013
//
//  Updated by pvmagacho on 05/14/2014
//  F2Finish - NASA iPad App Updates - Round 3
//

#import "SelectConsumptionViewController.h"
#import "Helper.h"
#import "SelectFoodCell.h"
#import "CustomIndexBar.h"
#import <QuartzCore/QuartzCore.h>
#import "FoodProductServiceImpl.h"
#import "AppDelegate.h"
#import "UserServiceImpl.h"
#import "DataHelper.h"
#import "Settings.h"
#import "DBHelper.h"

@interface SelectConsumptionViewController ()<SettingListViewDelegate, CustomIndexBarDelegate,
    UISearchBarDelegate>{
    /* categories dictionary */
    NSDictionary *categories;
    /* categories keys */
    NSArray *categoriesKeys;
    /* the select index path for category table */
    int selectCategoryIndex[5];
    
    /* all foods */
    NSMutableArray *foodList;
    /* food by name with 'A', 'B', ... */
    NSMutableDictionary *foodDict;
    /* food keys default 'A', 'B', ... */
    NSMutableArray *foodKeys;
    
    /* cover for pop up */
    UIView *clearCover;
    
    /* left cover button */
    UIButton *leftCoverButton;
    
    /* sort option array */
    NSMutableArray *sortByOptionArray;
        
    /* is only view calories */
    BOOL viewCaloriesOnly;
    /* is only view sodium */
    BOOL viewSodiumOnly;
    /* is only view fluid */
    BOOL viewFluidOnly;
    /* is only view protein */
    BOOL viewProteinOnly;
    /* is only view carb */
    BOOL viewCarbOnly;
    /* is only view fat */
    BOOL viewFatOnly;
    /* the sort by select index */
    int selectIndex;
    
    /* the custom index bar */
    CustomIndexBar *indexBar;
    
    /* the start visible index */
    int visibleStart;
    /* the end visible index */
    int visibleEnd;
}

@end

@implementation SelectConsumptionViewController

/**
 * initilize the arrays, fonts and some other values after view loaded.
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
    self.lblTitle.font = [UIFont fontWithName:@"Bebas" size:24];
    self.lblSubTitle.font = [UIFont fontWithName:@"Bebas" size:17];
    self.lblInfoTitle.font = [UIFont fontWithName:@"Bebas" size:20];
    
    self.btnChange.hidden = YES;
    
    foodKeys = [NSMutableArray array];
    foodList = [NSMutableArray array];
    foodDict = [NSMutableDictionary dictionary];
    self.selectFoods = [NSMutableArray array];
    
    [self.segListGrid setDividerImage:[UIImage imageNamed:@"seg-list-active.png"]
                  forLeftSegmentState:UIControlStateSelected
                    rightSegmentState:UIControlStateNormal
                           barMetrics:UIBarMetricsDefault];
    
    [self.segListGrid setDividerImage:[UIImage imageNamed:@"seg-grid-active.png"]
                  forLeftSegmentState:UIControlStateNormal
                    rightSegmentState:UIControlStateSelected
                           barMetrics:UIBarMetricsDefault];
    
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    FoodProductServiceImpl *foodProductService = appDelegate.foodProductService;
    NSError *error;
    categories = [NSDictionary dictionaryWithObjectsAndKeys:
                  [NSArray arrayWithObjects:@"All Food", nil],
                  @"All",
                  [foodProductService getAllProductCategories:&error],
                  @"Food by Category",
                  [foodProductService getAllProductOrigins:&error],
                  @"Food by Country",
                  [NSArray arrayWithObjects:@"All", @"This Week", @"This Month", nil],
                  @"My Favorite Foods",
                  [NSArray arrayWithObjects:@"Vitamins / Supplements", nil],
                  @"Vitamins / Supplements",
                  nil];
    categoriesKeys = [NSArray arrayWithObjects:@"All", @"Food by Category",
                      @"Food by Country", @"My Favorite Foods", @"Vitamins / Supplements", nil];
    
    sortByOptionArray = [NSMutableArray arrayWithObjects:
                         @"Alphabetically (A to Z)",
                         @"Alphabetically (Z to A)",
                         @"Nutrient Content (energy)",
                         @"Nutrient Content (sodium)",
                         @"Nutrient Content (liquid)",
                         @"Nutrient Content (protein)",
                         @"Nutrient Content (carb)",
                         @"Nutrient Content (fat)",
                         @"Frequency (High To Low)",
                         @"Frequency (Low To High)",
                         nil];
    
    self.optionListView.delegate = self;
    self.optionListView.options = sortByOptionArray;
    self.optionListView.selectIndex = 0;
    
    memset(selectCategoryIndex, -1, sizeof(selectCategoryIndex));
    
    UISwipeGestureRecognizer *ges = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(swipeLeft:)];
    ges.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.rightTable addGestureRecognizer:ges];
    ges = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiperight)];
    ges.direction = UISwipeGestureRecognizerDirectionRight;
    [self.rightTable addGestureRecognizer:ges];
    
    // Set last used food product filter if needed
    if (appDelegate.loggedInUser.useLastUsedFoodProductFilter.boolValue && appDelegate.loggedInUser.lastUsedFoodProductFilter) {
        if ([appDelegate.loggedInUser.lastUsedFoodProductFilter.categories count] > 0) {
            StringWrapper *foodProductCategory =
            [[appDelegate.loggedInUser.lastUsedFoodProductFilter.categories allObjects] objectAtIndex:0];
            NSArray *categoriesList = (NSArray *)[categories objectForKey:@"Food by Category"];
            int foodProductCategoryIndex = [categoriesList indexOfObject:foodProductCategory.value];
            if (foodProductCategoryIndex < categoriesList.count) {
                selectCategoryIndex[1] = foodProductCategoryIndex;
            }
        }
        if ([appDelegate.loggedInUser.lastUsedFoodProductFilter.origins count] > 0) {
            StringWrapper *foodProductOrigin =
            [[appDelegate.loggedInUser.lastUsedFoodProductFilter.origins allObjects] objectAtIndex:0];
            NSArray *origins = (NSArray *)[categories objectForKey:@"Food by Country"];
            int foodProductOriginIndex = [origins indexOfObject:foodProductOrigin.value];
            if (foodProductOriginIndex < origins.count) {
                selectCategoryIndex[2] = foodProductOriginIndex;
            }
        }
        int favoriteWithinTimePeriod =
        [appDelegate.loggedInUser.lastUsedFoodProductFilter.favoriteWithinTimePeriod intValue];
        if (favoriteWithinTimePeriod == 7) {
            selectCategoryIndex[3] = 1;
        } else if (favoriteWithinTimePeriod == 30) {
            selectCategoryIndex[3] = 2;
        }
        self.optionListView.selectIndex =
        [self getSortOptionFromFilter:appDelegate.loggedInUser.lastUsedFoodProductFilter.sortOption.intValue];
    }
    else {
        selectCategoryIndex[0] = 0;
    }

    [self loadFoods];
    [self listviewDidSelect:self.optionListView.selectIndex];
    [[NSNotificationCenter defaultCenter] postNotificationName:AutoLogoutRenewEvent object:nil];
}

/**
 * loadd foods. Just generate some random value here.
 */
- (void)loadFoods{
    // Clear selected foods
    //[self.selectFoods removeAllObjects];
    if(self.selectFoods.count == 0){
        [self.btnAdd setEnabled:NO];
    }
    else{
        [self.btnAdd setEnabled:YES];
    }
    
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    FoodProductServiceImpl *foodProductService = appDelegate.foodProductService;
    UserServiceImpl *userService = appDelegate.userService;
    NSError *error;
    
    FoodProductFilter *filter = nil;
    NSManagedObjectContext *context = nil;
    if (appDelegate.loggedInUser.useLastUsedFoodProductFilter.boolValue &&
        appDelegate.loggedInUser.lastUsedFoodProductFilter) {
        filter = appDelegate.loggedInUser.lastUsedFoodProductFilter;
        context = [DBHelper currentThreadMoc];
    } else {
        filter = [foodProductService buildFoodProductFilter:&error];
        filter.sortOption = [self getSortOptionFromListView:self.optionListView.selectIndex];
        if ([Helper displayError:error]) return;
    }
    
    filter.name = self.searchBar.text;
    filter.categories = [NSSet set];
    filter.origins = [NSSet set];
    filter.favoriteWithinTimePeriod = @0;
    
    if (selectCategoryIndex[1] != -1) {
        NSString *foodProductCategory = [(NSArray *)[categories objectForKey:@"Food by Category"]
                                         objectAtIndex:selectCategoryIndex[1]];
        filter.categories = [DataHelper convertNSStringToNSSet:foodProductCategory withEntityDescription:
                              [NSEntityDescription entityForName:@"StringWrapper"
                                          inManagedObjectContext:[DBHelper currentThreadMoc]]
                                         inManagedObjectContext:context withSeparator:@";"];
    }
    if (selectCategoryIndex[2] != -1) {
        NSString *foodOrigin = [(NSArray *)[categories objectForKey:@"Food by Country"]
                                objectAtIndex:selectCategoryIndex[2]];
        filter.origins = [DataHelper convertNSStringToNSSet:foodOrigin withEntityDescription:
        [NSEntityDescription entityForName:@"StringWrapper"
                     inManagedObjectContext:[DBHelper currentThreadMoc]]
                    inManagedObjectContext:context withSeparator:@";"];
    }
    if (selectCategoryIndex[3] != -1) {
        if (selectCategoryIndex[3] == 1) {
            filter.favoriteWithinTimePeriod = @7;
        } else if (selectCategoryIndex[3] == 2) {
            filter.favoriteWithinTimePeriod = @30;
        }
    }
    if (selectCategoryIndex[4] != -1) {
        filter.categories = [DataHelper convertNSStringToNSSet:@"Vitamins / Supplements" withEntityDescription:
                             [NSEntityDescription entityForName:@"StringWrapper"
                                         inManagedObjectContext:[DBHelper currentThreadMoc]]
                                        inManagedObjectContext:context withSeparator:@";"];
    }
    
    // Save last used food product filter
    if (appDelegate.loggedInUser.useLastUsedFoodProductFilter && appDelegate.loggedInUser.lastUsedFoodProductFilter) {
        [userService saveUser:appDelegate.loggedInUser error:&error];
        if ([Helper displayError:error]) return;
    }
    
    // Filter the food products
    NSArray *result = [foodProductService filterFoodProducts:appDelegate.loggedInUser filter:filter error:&error];
    if ([Helper displayError:error]) return;
    [foodKeys removeAllObjects];
    [foodDict removeAllObjects];
    [foodList removeAllObjects];
    
    for(int i = 0; i < 26; i++){
        NSString *key = [NSString stringWithFormat:@"%c", (char)(65 + i)];
        [foodKeys addObject:key];
        NSMutableArray *foodProducts = [[NSMutableArray alloc] init];
        [foodDict setValue:foodProducts forKey:key];
    }
    
    for(FoodProduct *foodProduct in result) {
        NSString *key = [foodProduct.name substringToIndex:1];
        if (key && ![key isEqualToString:@""]) {
            key = [key uppercaseString];
            [foodList addObject:foodProduct];
            NSMutableArray *foodProducts = foodDict[key];
            [foodProducts addObject:foodProduct];
        }
    }
    
    for(int i = [foodKeys count] - 1; i >= 0; i--){
        NSString *key = foodKeys[i];
        NSMutableArray *foodProducts = foodDict[key];
        if (foodProducts.count == 0) {
            [foodDict removeObjectForKey:key];
            [foodKeys removeObject:key];
        }
    }
    
    [indexBar removeFromSuperview];
    indexBar = [[CustomIndexBar alloc] initWithFrame:CGRectMake(429,
                                                                68.0,
                                                                20.0,
                                                                self.rightView.frame.size.height-78)];
    [indexBar setIndexes:foodKeys];
    indexBar.delegate = self;
    if (filter.sortOption.intValue != A_TO_Z && filter.sortOption.intValue != Z_TO_A) {
        indexBar.hidden = YES;
    }
    [self.rightView addSubview:indexBar];
    visibleStart = visibleEnd = 0;
    [self.rightTable reloadData];
    
    [self listGridValueChanged:nil];
}

/**
 * Set the sort option
 * @param selection The sort selection.
 * @return the sort option
 */
- (int) getSortOptionFromFilter:(int)selection {
    int sortOption = 0;
    switch (selection) {
        case A_TO_Z:
            sortOption = 0;
            break;
        case Z_TO_A:
            sortOption = 1;
            break;
        case ENERGY_HIGH_TO_LOW:
            sortOption = 2;
            break;
        case SODIUM_HIGH_TO_LOW:
            sortOption = 3;
            break;
        case FLUID_HIGH_TO_LOW:
            sortOption = 4;
            break;
        case PROTEIN_HIGH_TO_LOW:
            sortOption = 5;
            break;
        case CARB_HIGH_TO_LOW:
            sortOption = 6;
            break;
        case FAT_HIGH_TO_LOW:
            sortOption = 7;
            break;
        case FREQUENCY_HIGH_TO_LOW:
            sortOption = 8;
            break;
        case FREQUENCY_LOW_TO_HIGH:
            sortOption = 9;
            break;
    }
    return sortOption;
}

/**
 * Get the sort option from list view
 * @return The sort option.
 */
- (NSNumber *) getSortOptionFromListView:(int)listSelection {
    int selection = 0;
    switch (listSelection) {
        case 0:
            selection = A_TO_Z;
            break;
        case 1:
            selection = Z_TO_A;
            break;
        case 2:
            selection = ENERGY_HIGH_TO_LOW;
            break;
        case 3:
            selection = SODIUM_HIGH_TO_LOW;
            break;
        case 4:
            selection = FLUID_HIGH_TO_LOW;
            break;
        case 5:
            selection = PROTEIN_HIGH_TO_LOW;
            break;
        case 6:
            selection = CARB_HIGH_TO_LOW;
            break;
        case 7:
            selection = FAT_HIGH_TO_LOW;
            break;
        case 8:
            selection = FREQUENCY_HIGH_TO_LOW;
            break;
        case 9:
            selection = FREQUENCY_LOW_TO_HIGH;
            break;
    }
    return [NSNumber numberWithInt:selection];
}

#pragma mark - swipe
/**
 * animation delegate method. Called when animation ends. Remove some hidden view here.
 * @param animationID An NSString containing the identifier.
 * @param finished An NSNumber object containing a Boolean value.
 * The value is YES if the animation ran to completion before it stopped or NO if it did not.
 * @param context This is the context data passed to the beginAnimations:context: method.
 */
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    if([animationID isEqualToString:@"swipeRight"]){
        [leftCoverButton removeFromSuperview];
        leftCoverButton = nil;
    }
    else if([animationID isEqualToString:@"swipeLeft"]){
        self.rightView.layer.shadowOffset = CGSizeMake(-5, 3);
        self.rightView.layer.shadowOpacity = 0.6;
        self.rightView.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3].CGColor;
    }
}
/**
 * resize the right table view to make the nutirent view unvisible.
 */
- (void)swiperight{
    if(self.rightView.frame.size.width == 454){
        return;
    }
    
    self.rightView.layer.shadowOffset = CGSizeMake(0, -3);
    self.rightView.layer.shadowOpacity = 0;
    self.rightView.layer.shadowColor = nil;
    
    [UIView beginAnimations:@"swipeRight" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    self.rightView.frame = CGRectMake(314, 98, 454, 835);
    indexBar.frame = CGRectMake(429, 68.0, 20.0, 757);
    leftCoverButton.alpha = 0;
    
    [UIView commitAnimations];
}

/**
 * resize the right table view to make the nutirent view visible.
 */
- (void)swipeLeft:(UISwipeGestureRecognizer *)ges{
    if(self.rightView.frame.size.width == 630){
        return;
    }
    UIButton *btn = [[UIButton alloc] initWithFrame:self.leftTable.frame];
    [self.leftTable.superview addSubview:btn];
    [btn addTarget:self action:@selector(swiperight) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor blackColor];
    btn.alpha = 0;
    leftCoverButton = btn;
    [UIView beginAnimations:@"swipeLeft" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    btn.alpha = 0.1;
    
    self.rightView.frame = CGRectMake(138, 98, 630, 835);
    indexBar.frame = CGRectMake(605, 68.0, 20.0, 757);
    [UIView commitAnimations];
}

#pragma mark - sort by
/**
 * show sort by option list pop.
 * @param sender the button.
 */
- (IBAction)showSortList:(id)sender {
    UIButton *btn = [[UIButton alloc] initWithFrame:self.view.frame];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(hideSortByOption) forControlEvents:UIControlEventTouchUpInside];
    clearCover = btn;
    
    CGRect frame = self.optionListView.frame;
    self.optionListView.frame = CGRectMake(self.rightView.frame.origin.x + 42,
                                           frame.origin.y,
                                           frame.size.width,
                                           frame.size.height);
    self.optionListView.hidden = NO;
    [self.view bringSubviewToFront:self.optionListView];
}

/**
 * Change from sort/filter.
 * @param sender the button.
 */
- (IBAction)changeList:(id)sender {
    UIButton *btn = (UIButton *) sender;
    btn.selected = !btn.selected;
    self.lblSortTitle.text = btn.selected ? @"Filter By:" : @"Sort By:";
    
    NSArray *array = [[NSArray arrayWithObject:@"None"] arrayByAddingObjectsFromArray:[categories objectForKey:@"Food by Category"]];
    
    self.optionListView.delegate = self;
    self.optionListView.selectIndex = btn.selected ? 0 : selectIndex;
    self.optionListView.options = btn.selected ? [NSMutableArray arrayWithArray:array] : sortByOptionArray;
    self.lblSortBy.text = [self.optionListView.options objectAtIndex:self.optionListView.selectIndex];
    [self.optionListView.listTable reloadData];
    
    if (!btn.selected) {
        selectCategoryIndex[1] = -1;
        [self loadFoods];
    }
}

/**
 * hide sort by option list.
 */
- (void)hideSortByOption{
    self.optionListView.hidden = YES;
    [clearCover removeFromSuperview];
    clearCover = nil;
}

/**
 * called when value is selected in sort by option list.
 * @param index the selected index.
 */
- (void)listviewDidSelect:(int)aIndex{
    int index = aIndex;
    if (self.btnChange.selected) {
        self.lblSortBy.text = [self.optionListView.options objectAtIndex:index];
        [self hideSortByOption];
        
        selectCategoryIndex[1] = index > 0 ? index - 1 : -1;
        [self loadFoods];
        
        index = 0;
    } else {
        AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        appDelegate.loggedInUser.lastUsedFoodProductFilter.sortOption = [self getSortOptionFromListView:index];

        self.lblSortBy.text = [self.optionListView.options objectAtIndex:index];
        [self hideSortByOption];
        if (selectCategoryIndex[1] >= 0) {
            selectCategoryIndex[1] = -1;
            [self loadFoods];
        }
    }

    selectIndex = index;
    if(index == 2){
        viewCaloriesOnly = YES;
        viewFluidOnly = NO;
        viewSodiumOnly = NO;
        viewProteinOnly = NO;
        viewCarbOnly = NO;
        viewFatOnly = NO;
        
        [foodList sortUsingComparator:^(FoodProduct *obj1, FoodProduct *obj2){
            if (obj1.energy.floatValue > obj2.energy.floatValue) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            
            if (obj1.energy.floatValue < obj2.energy.floatValue) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
    }
    else if(index == 3){
        viewCaloriesOnly = NO;
        viewFluidOnly = NO;
        viewSodiumOnly = YES;
        viewProteinOnly = NO;
        viewCarbOnly = NO;
        viewFatOnly = NO;
        [foodList sortUsingComparator:^(FoodProduct *obj1, FoodProduct *obj2){
            if (obj1.sodium.floatValue > obj2.sodium.floatValue) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            
            if (obj1.sodium.floatValue < obj2.sodium.floatValue) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
        
    }
    else if(index == 4){
        viewCaloriesOnly = NO;
        viewFluidOnly = YES;
        viewSodiumOnly = NO;
        viewProteinOnly = NO;
        viewCarbOnly = NO;
        viewFatOnly = NO;
        [foodList sortUsingComparator:^(FoodProduct *obj1, FoodProduct *obj2){
            if (obj1.fluid.floatValue > obj2.fluid.floatValue) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            
            if (obj1.fluid.floatValue < obj2.fluid.floatValue) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
        
    }
    else if(index == 5){
        viewCaloriesOnly = NO;
        viewFluidOnly = NO;
        viewSodiumOnly = NO;
        viewProteinOnly = YES;
        viewCarbOnly = NO;
        viewFatOnly = NO;
        [foodList sortUsingComparator:^(FoodProduct *obj1, FoodProduct *obj2){
            if (obj1.protein.floatValue > obj2.protein.floatValue) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            
            if (obj1.protein.floatValue < obj2.protein.floatValue) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
        
    }
    else if(index == 6){
        viewCaloriesOnly = NO;
        viewFluidOnly = NO;
        viewSodiumOnly = NO;
        viewProteinOnly = NO;
        viewCarbOnly = YES;
        viewFatOnly = NO;
        [foodList sortUsingComparator:^(FoodProduct *obj1, FoodProduct *obj2){
            if (obj1.carb.floatValue > obj2.carb.floatValue) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            
            if (obj1.carb.floatValue < obj2.carb.floatValue) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
        
    }
    else if(index == 7){
        viewCaloriesOnly = NO;
        viewFluidOnly = NO;
        viewSodiumOnly = NO;
        viewProteinOnly = NO;
        viewCarbOnly = NO;
        viewFatOnly = YES;
        [foodList sortUsingComparator:^(FoodProduct *obj1, FoodProduct *obj2){
            if (obj1.fat.floatValue > obj2.fat.floatValue) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            
            if (obj1.fat.floatValue < obj2.fat.floatValue) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
        
    }
    else{
        viewCaloriesOnly = NO;
        viewFluidOnly = NO;
        viewSodiumOnly = NO;
        viewProteinOnly = NO;
        viewCarbOnly = NO;
        viewFatOnly = NO;
    }
    
    if(selectIndex >= 2){
        indexBar.hidden = YES;
    }
    else{
        indexBar.hidden = NO;
    }
    
    //check A-Z or Z-A
    if(selectIndex == 1){
        [foodKeys sortUsingComparator:^(NSString *obj1, NSString *obj2){
            return [obj2 compare:obj1];
        }];
        for(NSString *key in foodKeys){
            NSMutableArray *arr = [foodDict valueForKey:key];
            [arr sortUsingComparator:^(FoodProduct *obj1, FoodProduct *obj2){
                return [obj2.name compare:obj1.name];
            }];
        }
        [indexBar setIndexes:foodKeys];
    }
    else if(selectIndex == 0){
        [foodKeys sortUsingComparator:^(NSString *obj1, NSString *obj2){
            return [obj1 compare:obj2];
        }];
        for(NSString *key in foodKeys){
            NSMutableArray *arr = [foodDict valueForKey:key];
            [arr sortUsingComparator:^(FoodProduct *obj1, FoodProduct *obj2){
                return [obj1.name compare:obj2.name];
            }];
        }
        [indexBar setIndexes:foodKeys];
    }
    
    if(self.rightView.hidden == NO){
        visibleStart = visibleEnd = 0;
        [self.rightTable reloadData];
        [self.rightTable scrollRectToVisible:CGRectMake(0, 0, 100, 10) animated:NO];
    }
    else{
        [self loadGridViews];
    }
    
    if (selectIndex == 8 || selectIndex == 9) {
        [self loadFoods];
    }
}

#pragma mark - note
/**
 * show the note info.
 * @param sender the button.
 */
- (IBAction)showInfo:(id)sender {
    UIButton *btn = [[UIButton alloc] initWithFrame:self.view.frame];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(hideInfo:) forControlEvents:UIControlEventTouchUpInside];
    clearCover = btn;
    
    self.infoView.hidden = NO;
    [self.view bringSubviewToFront:self.infoView];
}

/**
 * hide the note info.
 * @param sender the button.
 */
- (IBAction)hideInfo:(id)sender {
    self.infoView.hidden = YES;
    [self.searchBar resignFirstResponder];
    [clearCover removeFromSuperview];
    clearCover = nil;
}

#pragma mark - others

/**
 * select a food in the table list view.
 * @param sender the button.
 */
- (void)foodSelect:(id)sender{
    UIButton *btn = (UIButton *)sender;
    int row = btn.tag % MAXROWS;
    int section = btn.tag / MAXROWS;
    FoodProduct *item = nil;
    if(selectIndex < 2){
        item = [[foodDict valueForKey:[foodKeys objectAtIndex:section]]
                objectAtIndex:row];
    }
    else{
        item = [foodList objectAtIndex:row];
    }
    
    if([self.selectFoods containsObject:item]){
        [self.selectFoods removeObject:item];
    }
    else{
        [self.selectFoods addObject:item];
    }
    if(self.selectFoods.count == 0){
        [self.btnAdd setEnabled:NO];
    }
    else{
        [self.btnAdd setEnabled:YES];
    }
    [self.rightTable reloadData];
}

/**
 * add to contumption and return back to consumption view.
 * @param sender the button.
 */
- (IBAction)addToConsumption:(id)sender {
    [self.btnBack sendActionsForControlEvents:UIControlEventApplicationReserved];    
}

/**
 * click food photo in the grid view.
 * @param btn the button.
 */
- (void)clickPhoto:(UIButton *)btn{
    int row = btn.tag;
    FoodProduct *item = [foodList objectAtIndex:row];
    if([self.selectFoods containsObject:item]){
        [self.selectFoods removeObject:item];
        UIView *v = [btn.superview viewWithTag:10];
        [v removeFromSuperview];
    }
    else{
        [self.selectFoods addObject:item];
        
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(108, 28, 29, 29)];
        img.image = [UIImage imageNamed:@"btn-checkmark.png"];
        img.tag = 10;
        [btn.superview addSubview:img];
    }
    if(self.selectFoods.count == 0){
        [self.btnAdd setEnabled:NO];
    }
    else{
        [self.btnAdd setEnabled:YES];
    }
}

/**
 * load the grid view by food list.
 */
- (void)loadGridViews{
    int total = foodList.count;
    int rows = ceil(total / 3.0);
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:self.scrollView.frame];
    scroll.contentSize = CGSizeMake(scroll.frame.size.width, rows * 170 + 20);
    for(int i = 0; i < total; i++){
        FoodProduct *item = [foodList objectAtIndex:i];
        int x = (i % 3) * 147;
        int y = (i / 3) * 170;
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(x, y, 147, 170)];
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(18, 20, 127, 119)];
        img.layer.borderColor = [UIColor colorWithRed:0.54 green:0.79 blue:1 alpha:1].CGColor;
        img.layer.borderWidth = 1;
        img.image = [Helper loadImage:item.productProfileImage];
        [v addSubview:img];
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 153, 147, 17)];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.font = [UIFont fontWithName:@"Helvetica Neue" size:15];
        lbl.text = item.name;
        lbl.textColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1];
        [v addSubview:lbl];
        UIButton *btn = [[UIButton alloc] initWithFrame:img.frame];
        btn.tag = i;
        [btn addTarget:self action:@selector(clickPhoto:) forControlEvents:UIControlEventTouchUpInside];
        [v addSubview:btn];
        if([self.selectFoods containsObject:item]){
            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(108, 28, 29, 29)];
            img.image = [UIImage imageNamed:@"btn-checkmark.png"];
            img.tag = 10;
            [v addSubview:img];
        }
        [scroll addSubview:v];
    }
    [self.scrollView removeFromSuperview];
    [self.gridView addSubview:scroll];
    self.scrollView = scroll;
}

/**
 * change between list view and grid view.
 * @param sender the segment control.
 */
- (IBAction)listGridValueChanged:(id)sender{
    if(self.segListGrid.selectedSegmentIndex == 0){
        self.rightView.hidden = NO;
        self.rightView.frame = CGRectMake(314, 100, 454, 833);
        visibleStart = visibleEnd = 0;
        [self.rightTable reloadData];
        self.gridView.hidden = YES;
    }
    else if(self.segListGrid.selectedSegmentIndex == 1){
        self.rightView.hidden = YES;
        [self loadGridViews];
        self.gridView.hidden = NO;
    }
}

/**
 * release view resources after view unload by setting value nil.
 */
- (void)viewDidUnload {
    [self setLblTitle:nil];
    [self setSegListGrid:nil];
    [self setBtnAdd:nil];
    [self setLblSortBy:nil];
    [self setLblSubTitle:nil];
    [self setLeftTable:nil];
    [self setRightView:nil];
    [self setRightTable:nil];
    [self setGridView:nil];
    [self setSearchBar:nil];
    [self setInfoView:nil];
    [self setLblInfoTitle:nil];
    [super viewDidUnload];
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
    [btn addTarget:self action:@selector(hideInfo:) forControlEvents:UIControlEventTouchUpInside];
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
    appDelegate.loggedInUser.lastUsedFoodProductFilter.name = searchText;
    // Reload the foods
    [self loadFoods];
    [self listviewDidSelect:self.optionListView.selectIndex];
    
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

    FoodProductServiceImpl *foodProductService = appDelegate.foodProductService;
    NSError *error = nil;
    FoodProductFilter *filter = [foodProductService buildFoodProductFilter:&error];
    filter.sortOption = @2;
    if (![searchText isEqualToString:@""]) {
        filter.name = searchText;
    }
    NSArray *result = [foodProductService filterFoodProducts:appDelegate.loggedInUser filter:filter error:&error];
    if (self.suggestionTableView) {
        NSMutableArray *suggestions = [NSMutableArray array];
        for (int i = 0; i < result.count; i++) {
            AdhocFoodProduct *product = result[i];
            NSString *productName = [product.name uppercaseString];
            if ([searchText isEqualToString:@""] || [productName rangeOfString:[searchText uppercaseString]].location != NSNotFound) {
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

#pragma mark - CMIndexBarDelegate mothods
/**
 * index change and scroll the table.
 * @param IndexBar the index bar.
 * @param index the selected index.
 */
- (void)indexBar:(CustomIndexBar *)IndexBar DidChangeIndexSelection:(int)index{
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:index];
    [self.rightTable scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:NO];
}


#pragma mark - UITableView Delegate methods
/**
 * determine the section number according view mode and the table.
 * @param tableView An object representing the table view requesting this information.
 * @return categoriesKeys.count for left table and foodKeys.count for right table if need index. Otherwise 1.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(tableView == self.leftTable){
        return categoriesKeys.count;
    }
    else{
        if(selectIndex < 2){
            return foodKeys.count;
        }
        else{
            return 1;
        }
    }
}

/**
 * return rows count according table and section.
 * @param tableView The table-view object requesting this information.
 * @param section An index number identifying a section in tableView.
 * @return the rows count.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView == self.leftTable){
        return [[categories valueForKey:[categoriesKeys objectAtIndex:section]] count];
    }
    else{
        if(selectIndex < 2){
            return [[foodDict valueForKey:[foodKeys objectAtIndex:section]] count];
        }
        else{
            return foodList.count;
        }
    }
}

/**
 * defines the table cell for category navigate table and right content table.
 * @param tableView A table-view object requesting the cell.
 * @param indexPath An index path locating a row in tableView.
 * @return SelectFoodCell for right table and UITableViewCell for left table
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *categoriesCellIdentifier = @"categoriesCellIdentifier";
    if(self.leftTable == tableView){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:categoriesCellIdentifier];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:categoriesCellIdentifier];
            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(295, 17, 8, 13)];
            img.image = [UIImage imageNamed:@"icon-arrow.png"];
            img.tag = 100;
            [cell addSubview:img];
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 49, tableView.frame.size.width, 1)];
            [line setBackgroundColor:[UIColor whiteColor]];
            [cell addSubview:line];
        }
        int sec = indexPath.section;
        int row = indexPath.row;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        if(selectCategoryIndex[sec] == row){
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.contentView.backgroundColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1];
            [cell viewWithTag:100].hidden = YES;
        }
        else{
            cell.textLabel.textColor = [UIColor colorWithRed:0.2 green:0.43 blue:0.62 alpha:1];
            cell.contentView.backgroundColor = [UIColor clearColor];
            [cell viewWithTag:100].hidden = NO;
        }
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
        cell.textLabel.text = [[categories valueForKey:[categoriesKeys objectAtIndex:sec]] objectAtIndex:row];
        
        AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        NSString *categoryImageName = appDelegate.configuration[@"Categories"][cell.textLabel.text];
        if (categoryImageName) {
            cell.imageView.image = [UIImage imageNamed:categoryImageName];
        }
        else {
            cell.imageView.image = [UIImage imageNamed:@"btn-icon.png"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else{
        SelectFoodCell *cell = (SelectFoodCell *)[tableView
                                                  dequeueReusableCellWithIdentifier:@"SelectFoodCellIdentifier"];
        FoodProduct *item = nil;
        BOOL isLast = NO;
        if(selectIndex < 2){
            item = [[foodDict valueForKey:[foodKeys objectAtIndex:indexPath.section]]
                    objectAtIndex:indexPath.row];
            if(indexPath.row == [[foodDict valueForKey:[foodKeys objectAtIndex:indexPath.section]] count] - 1){
                isLast = YES;
            }
        }
        else{
            item = [foodList objectAtIndex:indexPath.row];
        }
        if(self.rightTable.frame.size.width > 454){
            cell.scrollView.frame = CGRectMake(245, 0, 285, 54);
        }
        cell.food = item;
        cell.btnCheck.tag = indexPath.row + indexPath.section * MAXROWS;
        [cell.btnCheck addTarget:self action:@selector(foodSelect:) forControlEvents:UIControlEventTouchUpInside];
        cell.cellButton.tag = indexPath.row + indexPath.section * MAXROWS;
        [cell.cellButton addTarget:self action:@selector(foodSelect:) forControlEvents:UIControlEventTouchUpInside];
        if([self.selectFoods containsObject:item]){
            [cell.btnCheck setSelected:YES];
        }
        else{
            [cell.btnCheck setSelected:NO];
        }
        cell.viewCaloriesOnly = viewCaloriesOnly;
        cell.viewFluidOnly = viewFluidOnly;
        cell.viewSodiumOnly = viewSodiumOnly;
        cell.viewProteinOnly = viewProteinOnly;
        cell.viewFatOnly = viewFatOnly;
        cell.viewCarbOnly = viewCarbOnly;
        if(isLast){
            cell.line.hidden = YES;
        }
        else{
            cell.line.hidden = NO;
        }
        [cell setNeedsDisplay];
        
        NSArray *indexArr = [tableView indexPathsForVisibleRows];
        if(indexArr.count > 1 && indexBar.isHidden == NO){
            NSIndexPath *start = [indexArr objectAtIndex:0];
            NSIndexPath *end = start;
            if(indexArr.count > 2){
                end = [indexArr objectAtIndex:indexArr.count - 1];
            }
            if(start.section != visibleStart || (end.section + 1) != visibleEnd){
                visibleEnd = end.section + 1;
                visibleStart = start.section;
                [indexBar setVisibleStartIndex:visibleStart EndIndex:visibleEnd];
            }
        }
        return cell;
    }
    return nil;
}

/**
 * define the header view for tables
 * @param tableView The table-view object asking for the view object.
 * @param section An index number identifying a section of tableView .
 * @return a green header for left category table view or a gray view for right table view.
 */
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(tableView == self.leftTable){
        if(section == 0){
            return nil;
        }
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 313, 24)];
        UIImageView *img = [[UIImageView alloc] initWithFrame:v.frame];
        img.image = [UIImage imageNamed:@"bg-green-header.png"];
        [v addSubview:img];
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 293, 24)];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.textColor = [UIColor whiteColor];
        lbl.text = [categoriesKeys objectAtIndex:section];
        lbl.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
        [v addSubview:lbl];
        return v;
    }
    else{
        if(selectIndex < 2){
            int width = self.rightTable.frame.size.width;
            UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 32)];
            v.autoresizesSubviews = YES;
            v.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            UIImageView *img = [[UIImageView alloc] initWithFrame:v.frame];
            img.image = [UIImage imageNamed:@"bg-gray-header.png"];
            [v addSubview:img];
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, width, 32)];
            lbl.backgroundColor = [UIColor clearColor];
            lbl.textColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1];
            lbl.text = [foodKeys objectAtIndex:section];
            lbl.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
            lbl.textAlignment = UITextAlignmentCenter;
            [v addSubview:lbl];
            img.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            lbl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            return v;
        }
        else{
            return 0;
        }
    }
}
/**
 * define the header height for tables
 * @param tableView The table-view object asking for the view object.
 * @param section An index number identifying a section of tableView .
 * @return 24 for left category table view or 32 for right table view if needed.
 */
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(tableView == self.leftTable){
        if(section == 0){
            return 0;
        }
        return 24;
    }
    else{
        if(selectIndex < 2){
            return 32;
        }
        else{
            return 0;
        }
    }
}

/**
 * define the footer height for tables
 * @param tableView The table-view object asking for the view object.
 * @param section An index number identifying a section of tableView .
 * @return 0 as default.
 */
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

/**
 * indicates the cell in index path is selctable or not. nil means should not select it.
 * @param tableView The table-view object asking for the view object.
 * @param indexPath An index path locating the row in tableView.
 * @return the index path for category navigate table or nil for right table.
 */
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.leftTable == tableView){
        return indexPath;
    }
    else{
        return nil;
    }
}

/**
 * handle action for navigate changed here.
 * @param tableView The table-view object asking for the view object.
 * @param indexPath An index path locating the row in tableView.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.leftTable == tableView){
        if (indexPath.section == 0) {
            selectCategoryIndex[0] = 0;
            for (int i = 1; i < 5; i++) {
                selectCategoryIndex[i] = -1;
            }
        }
        else {
            /*if (selectCategoryIndex[indexPath.section] == indexPath.row) {
                selectCategoryIndex[indexPath.section] = -1;
            }
            else {
                selectCategoryIndex[indexPath.section] = indexPath.row;
            }
            
            bool hasSelection = NO;
            for (int i = 1; i < 5; i++) {
                if (selectCategoryIndex[i] != -1) {
                    hasSelection = YES;
                }
            }
            if (hasSelection) {
                selectCategoryIndex[0] = -1;
            }
            else {
                selectCategoryIndex[0] = 0;
            }*/
            
            for (int i = 0; i < 5; i++) {
                selectCategoryIndex[i] = -1;
            }
            selectCategoryIndex[indexPath.section] = indexPath.row;
        }
        
        self.btnChange.hidden = (indexPath.section != 2);
        
        self.btnChange.selected = NO;
        self.lblSortTitle.text = @"Sort By:";
        self.optionListView.delegate = self;
        self.optionListView.selectIndex = 0;
        self.optionListView.options = sortByOptionArray;
        self.lblSortBy.text = [self.optionListView.options objectAtIndex:0];
        [self.optionListView.listTable reloadData];

        [tableView reloadData];
        [self loadFoods];
    }
}

@end
