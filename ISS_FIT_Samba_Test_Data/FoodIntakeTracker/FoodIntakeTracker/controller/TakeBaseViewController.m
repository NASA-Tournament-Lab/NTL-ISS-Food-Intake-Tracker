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
//  TakeBaseViewController.m
//  FoodIntakeTracker
//
//  Created by lofzcx 06/25/2013
//
//  Updated by pvmagacho on 05/07/2014
//  F2Finish - NASA iPad App Updates
//

#import "TakeBaseViewController.h"
#import "Helper.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "FoodConsumptionRecordServiceImpl.h"
#import "Settings.h"

@implementation TakeBaseViewController

/**
 * Called when view will be presented.
 * Hide tab view here.
 * @param animated If YES, the view is being added to the window using an animation.
 */
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.customTabBarController.tabView.hidden = YES;
}
/**
 * hide search border, set title font and initialize array after view loaded.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.lblResultTitle.font = [UIFont fontWithName:@"Bebas" size:24];
    
    self.lblFoodAddedTitile.font = [UIFont fontWithName:@"Bebas" size:20];
    
    self.imgFood.layer.borderWidth = 1;
    self.imgFood.layer.borderColor = [UIColor colorWithRed:0.54 green:0.79 blue:1 alpha:1].CGColor;
    
    self.resultTableView.layer.borderColor = [UIColor colorWithRed:0.77 green:0.77 blue:0.77 alpha:1].CGColor;
    self.resultTableView.layer.cornerRadius = 10;
    self.resultTableView.layer.borderWidth = 1;
    
    self.lblResultTitle.font = [UIFont fontWithName:@"Bebas" size:24];
    
    resultFoods = [[NSMutableArray alloc] init];
    selectFoods = [[NSMutableArray alloc] init];
    
    [self.btnResults setEnabled:NO];
    [self.btnAdd setHidden:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:AutoLogoutRenewEvent object:nil];
}
/**
 * release resource by setting nil value.
 */
- (void)viewDidUnload {
    [self setFooter:nil];
    [self setLblTakeButtonTitle:nil];
    [self setBtnTake:nil];
    [self setBtnShowAll:nil];
    [self setBtnCancel:nil];
    [self setBtnResults:nil];
    [self setPreview:nil];
    [self setResultView:nil];
    [self setLblResultTitle:nil];
    [self setBtnResultAdd:nil];
    [self setLblFoodName:nil];
    [self setLblFoodCategory:nil];
    [self setLblCalories:nil];
    [self setLblSodium:nil];
    [self setLblFluid:nil];
    [self setLblProtein:nil];
    [self setLblCarb:nil];
    [self setLblFat:nil];
    [self setImgFood:nil];
    [self setResultTableView:nil];
    [self setFoodAddedPopup:nil];
    [self setLblFoodAddedTitile:nil];
    [self setResultsView:nil];
    [self setResultsContentScrollView:nil];
    [self setBtnAdd:nil];
    [self setTxtFoodName:nil];
    [self setImgCenter:nil];
    [super viewDidUnload];
}

/**
 * click food photo in the grid view.
 * @param btn the button.
 */
- (void)clickPhoto:(UIButton *)btn{
    int row = btn.tag;
    FoodProduct *item = [resultFoods objectAtIndex:row];
    if([selectFoods containsObject:item]){
        [selectFoods removeObject:item];
        UIView *v = [btn.superview viewWithTag:10];
        [v removeFromSuperview];
    }
    else{
        [selectFoods addObject:item];
        
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(82, 22, 29, 29)];
        img.image = [UIImage imageNamed:@"btn-checkmark.png"];
        img.tag = 10;
        [btn.superview addSubview:img];
    }
    if(selectFoods.count == 0){
        [self.btnAdd setEnabled:NO];
    }
    else{
        [self.btnAdd setEnabled:YES];
    }
}
/**
 * fill the content of foods according got foods.
 */
- (void)buildResults{
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:self.resultsContentScrollView.frame];
    scroll.contentSize = CGSizeMake(120 * resultFoods.count, 152);
    for(int i = 0; i < resultFoods.count; i++){
        FoodProduct *item = [resultFoods objectAtIndex:i];
        int x = i * 120;
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(x, 0, 120, 152)];
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 104, 95)];
        img.layer.borderColor = [UIColor colorWithRed:0.54 green:0.79 blue:1 alpha:1].CGColor;
        img.layer.borderWidth = 1;
        img.image = [Helper loadImage:item.productProfileImage];
        [v addSubview:img];
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 111, 105, 41)];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:15];
        lbl.text = item.name;
        lbl.textColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1];
        lbl.lineBreakMode = UILineBreakModeClip;
        [v addSubview:lbl];
        
        UIImageView *imgCover = [[UIImageView alloc] initWithFrame:CGRectMake(70, 111, 50, 41)];
        imgCover.image = [UIImage imageNamed:@"bg-white-cover.png"];
        [v addSubview:imgCover];
        
        UIButton *btn = [[UIButton alloc] initWithFrame:img.frame];
        btn.tag = i;
        [btn addTarget:self action:@selector(clickPhoto:) forControlEvents:UIControlEventTouchUpInside];
        [v addSubview:btn];
        if([selectFoods containsObject:item]){
            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(82, 22, 29, 29)];
            img.image = [UIImage imageNamed:@"btn-checkmark.png"];
            img.tag = 10;
            [v addSubview:img];
        }
        [scroll addSubview:v];
    }
    [self.resultsContentScrollView.superview insertSubview:scroll belowSubview:self.resultsContentScrollView];
    [self.resultsContentScrollView removeFromSuperview];
    self.resultsContentScrollView = scroll;
}

/**
 * animation delegate method. Called when animation ends. Remove some hidden view here.
 * @param animationID An NSString containing the identifier.
 * @param finished An NSNumber object containing a Boolean value.
 * The value is YES if the animation ran to completion before it stopped or NO if it did not.
 * @param context This is the context data passed to the beginAnimations:context: method.
 */
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    isAnimation = NO;
    if([animationID isEqualToString:@"hideResults"]){
        self.resultsView.hidden = YES;
        self.resultsView.frame = CGRectMake(0, 170, self.resultsView.frame.size.width, 0);
    }
    else if([animationID isEqualToString:@"showResults"]){
        self.resultsView.frame = CGRectMake(0, 0, self.resultsView.frame.size.width, 185);
    }
}

/**
 * This method will add selected foods to consumption.
 */
- (void)addSelectedFoodsToConsumption {
    if ([selectFoods count] == 0) {
        // Add the first one if none selected
        [selectFoods addObject:[resultFoods objectAtIndex:0]];
    }
    
    consumptionViewController = [self.customTabBarController getConsumptionViewController];
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    FoodConsumptionRecordServiceImpl *recordService = appDelegate.foodConsumptionRecordService;
    NSDate *selectedDate = consumptionViewController.dateListView.currentDate;
    if (!selectedDate) {
        selectedDate = [NSDate date];
    }
    NSError *error;
    for (FoodProduct *product in selectFoods) {
        FoodConsumptionRecord *record = [recordService buildFoodConsumptionRecord:&error];
        record.quantity = @1;
        record.sodium = product.sodium;
        record.energy = product.energy;
        record.fluid = product.fluid;
        record.protein = product.protein;
        record.carb = product.carb;
        record.fat = product.fat;
        record.timestamp = selectedDate;
        [recordService addFoodConsumptionRecord:appDelegate.loggedInUser record:record error:&error];
        record.foodProduct = product;
        [recordService saveFoodConsumptionRecord:record error:&error];

        if ([Helper displayError:error]) return;
        [consumptionViewController.foodConsumptionRecords addObject:record];
    }
    if (selectFoods.count) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DataSyncUpdateInterval" object:selectedDate];
    }
    
    [selectFoods removeAllObjects];
    [consumptionViewController updateProgress];
}

/**
 * action for take button click.
 * Leave empty for base class.
 * @param sender the button.
 */
- (IBAction)take:(id)sender{
    
}

/**
 * return back to summary view.
 * @param sender the button.
 */
- (IBAction)viewSummary:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    self.customTabBarController.imgConsumption.image = [UIImage imageNamed:@"icon-consumption-active.png"];
    [self.customTabBarController.btnConsumption setImage:[UIImage imageNamed:@"icon-tab-active.png"]
                                                forState:UIControlStateNormal];
    self.customTabBarController.activeTab = 1;
}

/**
 * action for take another button in result panel click.
 * Leave empty for base class.
 * @param sender the button.
 */
- (IBAction)takeAnotherPhoto:(id)sender {
}

/**
 * action for add to consumption button click.
 * Leave empty for base class.
 * @param sender the button.
 */
- (IBAction)addToConsumption:(id)sender {
}

/**
 * show the results panel.
 * @param sender the button.
 */
- (IBAction)showResults:(id)sender {
    if(isAnimation){
        return;
    }
    CGRect frame;
    NSString *animationId;
    if(self.btnResults.selected){
        [self.btnResults setSelected:NO];
        self.resultsView.frame = CGRectMake(0, 0, self.resultsView.frame.size.width, 170);
        frame = CGRectMake(0, 170, self.resultsView.frame.size.width, 0);
        animationId = @"hideResults";
        [self.btnAdd setHidden:YES];
    }
    else{
        [self.btnResults setSelected:YES];
        self.resultsView.hidden = NO;
        self.resultsView.frame = CGRectMake(0, 170, self.resultsView.frame.size.width, 0);
        frame = CGRectMake(0, 0, self.resultsView.frame.size.width, 170);
        animationId = @"showResults";
        [self.btnAdd setHidden:NO];
    }
    isAnimation = YES;
    [UIView beginAnimations:animationId context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    self.resultsView.frame = frame;
    [UIView commitAnimations];
}

/**
 * set the custom tabbar view controller here.
 * @param segue The segue object containing information about the view controllers involved in the segue.
 * @param sender The object that initiated the segue.
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.destinationViewController respondsToSelector:@selector(setCustomTabBarController:)]){
        [segue.destinationViewController setCustomTabBarController:self.customTabBarController];
        self.customTabBarController.imgConsumption.image = [UIImage imageNamed:@"icon-consumption"];
        [self.customTabBarController.btnConsumption setImage:nil forState:UIControlStateNormal];
        self.customTabBarController.activeTab = 0;
    }
}
@end
