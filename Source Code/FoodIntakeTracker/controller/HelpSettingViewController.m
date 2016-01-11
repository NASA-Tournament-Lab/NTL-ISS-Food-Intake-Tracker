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
//  HelpSettingViewController.m
//  FoodIntakeTracker
//
//  Created by lofzcx 05/03/2013
//

#import "HelpSettingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PopoverBackgroundView.h"
#import "CustomTabBarViewController.h"
#import "AppDelegate.h"
#import "UserServiceImpl.h"
#import "Helper.h"
#import "Settings.h"

#define LEFT_VISIBLE_FRAME  CGRectMake(0, 0, 328, 828);
#define LEFT_HIDE_ORIGIN_FRAME  CGRectMake(328, 0, 328, 828);
#define LEFT_HIDE_TARGET_FRAME  CGRectMake(-328, 0, 328, 828);
#define RIGHT_VISIBLE_FRAME  CGRectMake(0, 0, 446, 828);
#define RIGHT_HIDE_ORIGIN_FRAME  CGRectMake(446, 0, 446, 828);
#define RIGHT_HIDE_TARGET_FRAME  CGRectMake(-446, 0, 446, 828);

@implementation SettingLoginView

#pragma mark - Table View Datasource Delegate Methods

/**
 * in default login and default logout setting table only contains 2 options
 * @param tableView The table-view object requesting this information.
 * @param section An index number identifying a section in tableView.
 * @return the rows count (2).
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

/**
 *
 * defines the view of default login and default logout table cell.
 * just hardcode values here as setting login page is a static page.
 * @param tableView A table-view object requesting the cell.
 * @param indexPath An index path locating a row in tableView.
 * @return the table cell.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:nil];
    cell.textLabel.frame = CGRectMake(15, 0, 500, 50);
    cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(374, 19, 14, 13)];
    img.image = [UIImage imageNamed:@"icon-check.png"];
    [cell addSubview:img];
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    if(appDelegate.shouldAutoLogout == indexPath.row){
        img.hidden = NO;
        cell.textLabel.textColor = [UIColor colorWithRed:0.48 green:0.78 blue:1 alpha:1];
    }
    else{
        img.hidden = YES;
        cell.textLabel.textColor = [UIColor colorWithRed:0.26 green:0.26 blue:0.26 alpha:1];
    }
    if(indexPath.row == 0){
        cell.textLabel.text = @"Never Logout";
    }
    else{
        cell.textLabel.text = @"Logout after 5 minutes of inactivity";
    }

    return cell;
}

/**
 * handles table select for default logout action
 * @param tableView A table-view object informing the delegate about the new row selection.
 * @param indexPath An index path locating the new selected row in tableView.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == self.defaultLogout){
        AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        if (indexPath.row == 0) {
            appDelegate.shouldAutoLogout = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:AutoLogoutStopEvent object:nil];
        }
        else {
            appDelegate.shouldAutoLogout = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:AutoLogoutStartEvent object:nil];
        }
        [tableView reloadData];
    }
}

/**
 * overwrite thie method to set border and radius here.
 * @param rect the redraw rect.
 */
- (void)drawRect:(CGRect)rect{
    self.defaultLogout.layer.cornerRadius = 10;
    self.defaultLogout.layer.borderColor = [[UIColor colorWithRed:0.77 green:0.77 blue:0.77 alpha:1] CGColor];
    self.defaultLogout.layer.borderWidth = 1;
    
    [self.defaultLogout reloadData];
}

@end

@implementation SettingListView

#pragma mark - Table View Datasource Delegate Methods

/**
 * return the options' length.
 * @param tableView The table-view object requesting this information.
 * @param section An index number identifying a section in tableView.
 * @return the options.count.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.options.count;
}

/**
 * defines the view of list cell. It only contains a label and a check mark.
 * @param tableView A table-view object requesting the cell.
 * @param indexPath An index path locating a row in tableView.
 * @return the table cell.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:nil];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(self.listTable.frame.size.width - 40,
                                                                     (tableView.rowHeight - 13) / 2, 14, 13)];
    img.image = [UIImage imageNamed:@"icon-check.png"];
    [cell addSubview:img];
    if(self.selectIndex == indexPath.row){
        img.hidden = NO;
        cell.textLabel.textColor = [UIColor colorWithRed:0.48 green:0.78 blue:1 alpha:1];
    }
    else{
        img.hidden = YES;
        cell.textLabel.textColor = [UIColor colorWithRed:0.26 green:0.26 blue:0.26 alpha:1];
    }
    cell.textLabel.text = [self.options objectAtIndex:indexPath.row];
    return cell;
}

/**
 * handles table select action. Check if need to call delegate methods here for value change.
 * @param tableView A table-view object informing the delegate about the new row selection.
 * @param indexPath An index path locating the new selected row in tableView.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectIndex = indexPath.row;
    [self.listTable reloadData];
    if(self.delegate && [self.delegate respondsToSelector:@selector(listviewDidSelect:)]){
        [self.delegate listviewDidSelect:self.selectIndex];
    }
}

/**
 * overwrite thie method to set border and radius here.
 * @param rect the redraw rect.
 */
- (void)drawRect:(CGRect)rect{
    self.listTable.layer.cornerRadius = 10;
    self.listTable.layer.borderColor = [[UIColor colorWithRed:0.77 green:0.77 blue:0.77 alpha:1] CGColor];
    self.listTable.layer.borderWidth = 1;
    
    [self.listTable reloadData];
}

@end

@interface HelpSettingViewController ()<UITableViewDataSource, UITableViewDelegate>{
    /* A boolean value indicates help page is showing or not */
    BOOL isShowingHelp;
    /* the help item array */
    NSMutableDictionary *helpItems;
    /* the setting navigation item array */
    NSMutableArray *settingItems;
    /* the select index of navigation table. */
    NSInteger selectIndex;
    /* the label the time picker is for */
    UILabel *timeLabel;
    /* Represents the help titles. */
    NSArray *helpTitles;
}

@end

@implementation HelpSettingViewController

/**
 * called when help setting page will appear. We set default view here.
 * @param animate If YES, the view is being added to the window using an animation.
 */
- (void)viewWillAppear:(BOOL)animated{
    self.lblSegLeft.textColor = [UIColor colorWithRed:0.21 green:0.21 blue:0.21 alpha:1];
    self.lblSegRight.textColor = [UIColor whiteColor];
    self.segHelpSetting.selectedSegmentIndex = 0;
    selectIndex = 0;
    isShowingHelp = true;
    self.helpItemList.frame = LEFT_VISIBLE_FRAME;
    self.settingItemList.frame = LEFT_HIDE_ORIGIN_FRAME;
    self.helpDetailView.frame = RIGHT_VISIBLE_FRAME;
    self.settingLogin.frame = RIGHT_HIDE_ORIGIN_FRAME;
    [self.helpItemList reloadData];
    [self loadHelpDetails];
    [super viewWillAppear:animated];
}

/**
 * Do additional setup after loading the view.
 * Initialize hardcode and some other showing values here.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.lblTitle.font = [UIFont fontWithName:@"Bebas" size:24];
    
    [self.segHelpSetting setDividerImage:[UIImage imageNamed:@"bg-seg-left"]
                     forLeftSegmentState:UIControlStateSelected
                       rightSegmentState:UIControlStateNormal
                              barMetrics:UIBarMetricsDefault];
    
    [self.segHelpSetting setDividerImage:[UIImage imageNamed:@"bg-seg-right"]
                     forLeftSegmentState:UIControlStateNormal
                       rightSegmentState:UIControlStateSelected
                              barMetrics:UIBarMetricsDefault];
    
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    helpItems = [NSMutableDictionary dictionaryWithDictionary:appDelegate.helpData];
    helpTitles = [helpItems keysSortedByValueUsingComparator:^(id a, id b) {
        int first = [self itemHelp:a];
        int second = [self itemHelp:b];
        
        if ( first < second ) {
            return (NSComparisonResult)NSOrderedAscending;
        } else if ( first > second ) {
            return (NSComparisonResult)NSOrderedDescending;
        } else {
            return (NSComparisonResult)NSOrderedSame;
        }
    }];
    
    /*helpTitles = [helpItems allKeys];
    helpTitles = [NSArray arrayWithArray:[[helpItems allKeys] sortedArrayUsingFunction:helpItemsSorter
                                                                               context:(__bridge void *)(self)]];*/
    
    //init setting options
    settingItems = [[NSMutableArray alloc] initWithObjects:
                    [NSDictionary dictionaryWithObjectsAndKeys: @"Login & Logout Configuration", @"title",
                     @"icon-setting-login.png", @"image", nil],
                    [NSDictionary dictionaryWithObjectsAndKeys: @"Filter Food Product", @"title",
                     @"icon-setting-filter.png", @"image", nil], nil];
    
    self.settingFilter.options = [[NSMutableArray alloc] initWithObjects:@"Use Default Filter",
                                  @"Use Last Used Filter", nil];
    if (appDelegate.loggedInUser && appDelegate.loggedInUser.useLastUsedFoodProductFilter.boolValue == YES) {
        self.settingFilter.selectIndex = 1;
    } else {
        self.settingFilter.selectIndex = 0;
    }
    self.settingFilter.delegate = self;
    [self.settingFilter setNeedsDisplay];
    [[NSNotificationCenter defaultCenter] postNotificationName:AutoLogoutRenewEvent object:nil];
}

- (int)itemHelp:(id) item {
    NSString *str = item;
    int value = 0;
    NSArray *array = [str componentsSeparatedByString:@"-"];
    for (int i = 0; i < 3; i++) {
        int x = [[array objectAtIndex:i] intValue];
        value += pow(10, 3 - i) * x;
    }
    return value;
}

/**
 * get the view of the setting navigate index.
 * If need more view or some other view could be returned here.
 * @param index the setting navaigate table select index.
 */
- (UIView *)getSettingViewByIndex:(NSInteger)index{
    if(index == 0){
        return self.settingLogin;
    }
    else if(index == 1){
        return self.settingFilter;
    }
    else{
        return nil;
    }
}

/**
 * Load the help details for the currently selected help item.
 */
- (void) loadHelpDetails {
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    NSString *helpFileName = [appDelegate.helpData valueForKey:[helpTitles objectAtIndex:selectIndex]];
    NSURL *url = [[NSBundle mainBundle] URLForResource:helpFileName withExtension:@"html"];
    NSString *html = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    [self.helpDetailView loadHTMLString:html baseURL:baseUrl];
}

/**
 * action for changing between help page and setting page
 * @param sender the object sending message.
 */
- (IBAction)segmentValueChanged:(id)sender{
    if(self.segHelpSetting.selectedSegmentIndex == 0){
        self.lblSegLeft.textColor = [UIColor colorWithRed:0.21 green:0.21 blue:0.21 alpha:1];
        self.lblSegRight.textColor = [UIColor whiteColor];
        isShowingHelp = YES;
        self.settingItemList.frame = LEFT_VISIBLE_FRAME;
        self.helpItemList.frame = LEFT_HIDE_TARGET_FRAME;
        self.helpDetailView.frame = RIGHT_HIDE_TARGET_FRAME;
        [self getSettingViewByIndex:selectIndex].frame = RIGHT_VISIBLE_FRAME;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelay:0];
        [UIView setAnimationDuration:0.5];
        self.helpItemList.frame = LEFT_VISIBLE_FRAME;
        self.settingItemList.frame = LEFT_HIDE_ORIGIN_FRAME;
        [self getSettingViewByIndex:selectIndex].frame = RIGHT_HIDE_ORIGIN_FRAME;
        self.helpDetailView.frame = RIGHT_VISIBLE_FRAME;
        [UIView commitAnimations];
        selectIndex = 0;
        [self.helpItemList reloadData];
    }
    else{
        AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        if (!appDelegate.loggedInUser) {
            [self.segHelpSetting setSelectedSegmentIndex:0];
            [Helper showAlert:@"Error" message:@"I'm sorry, but you must be logged in to access this functionality."];
            return;
        }
        self.lblSegRight.textColor = [UIColor colorWithRed:0.21 green:0.21 blue:0.21 alpha:1];
        self.lblSegLeft.textColor = [UIColor whiteColor];
        isShowingHelp = NO;
        self.helpItemList.frame = LEFT_VISIBLE_FRAME;
        self.settingItemList.frame = LEFT_HIDE_TARGET_FRAME;
        self.settingLogin.frame = RIGHT_HIDE_TARGET_FRAME;
        self.helpDetailView.frame = RIGHT_VISIBLE_FRAME;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelay:0];
        [UIView setAnimationDuration:0.5];
        self.settingItemList.frame = LEFT_VISIBLE_FRAME;
        self.helpItemList.frame = LEFT_HIDE_ORIGIN_FRAME;
        self.helpDetailView.frame = RIGHT_HIDE_ORIGIN_FRAME;
        self.settingLogin.frame = RIGHT_VISIBLE_FRAME;
        [UIView commitAnimations];
        selectIndex = 0;
        [self.settingItemList reloadData];
    }
}

/**
 * called when select a value in picker view.
 * @param picker the picker view.
 * @param val the selected value.
 */
- (void)Picker:(BaseCustomPickerView *)picker DidSelectedValue:(NSString *)val{
    timeLabel.text = val;
}

#pragma mark - Table View Datasource Delegate Methods

/**
 * returns the rows number of help navigate table and setting navigate table.
 * @param tableView The table-view object requesting this information.
 * @param section An index number identifying a section in tableView.
 * @return helpitems count or setting items count.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView == self.helpItemList){
        return helpItems.count;
    }
    else{
        return settingItems.count;
    }
}

/**
 * defines the table cell for help navigate table and setting navigate table.
 * @param tableView A table-view object requesting the cell.
 * @param indexPath An index path locating a row in tableView.
 * @return the table cell.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* helpSettingCellIdentifier = @"helpSettingCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:helpSettingCellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:helpSettingCellIdentifier];
        
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(313, 17, 8, 13)];
        img.image = [UIImage imageNamed:@"icon-arrow.png"];
        img.tag = 100;
        [cell addSubview:img];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 49, tableView.frame.size.width, 1)];
        [line setBackgroundColor:[UIColor whiteColor]];
        [cell addSubview:line];
    }
    if(tableView == self.helpItemList){
        cell.textLabel.backgroundColor = [UIColor clearColor];
        if(indexPath.row == selectIndex){
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.contentView.backgroundColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1];
            [cell viewWithTag:100].hidden = YES;
        }
        else{
            cell.textLabel.textColor = [UIColor colorWithRed:0.2 green:0.43 blue:0.62 alpha:1];
            cell.contentView.backgroundColor = [UIColor clearColor];
            [cell viewWithTag:100].hidden = NO;
        }
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        cell.textLabel.text = [helpTitles objectAtIndex:indexPath.row];
        cell.imageView.image = [UIImage imageNamed:@"icon_help_list.png"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else{
        NSInteger selectedRow = indexPath.row;
        NSDictionary *dic = [settingItems objectAtIndex:selectedRow];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        if(indexPath.row == selectIndex){
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.contentView.backgroundColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1];
            [cell viewWithTag:100].hidden = YES;
        }
        else{
            cell.textLabel.textColor = [UIColor colorWithRed:0.2 green:0.43 blue:0.62 alpha:1];
            cell.contentView.backgroundColor = [UIColor clearColor];
            [cell viewWithTag:100].hidden = NO;
        }
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        cell.textLabel.text = [dic valueForKey:@"title"];
        cell.imageView.image = [UIImage imageNamed:[dic valueForKey:@"image"]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

/**
 * perform the navigate action for help navigate table and setting navigate table.
 * change the detail content or view.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger oldSelectIndex = 0;
    if(indexPath.row == selectIndex){
        return;
    }
    if(tableView == self.helpItemList){
        if(selectIndex != -1){
            oldSelectIndex = selectIndex;
        }
        selectIndex = indexPath.row;
        [self loadHelpDetails];
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,
                                           [NSIndexPath indexPathForRow:oldSelectIndex inSection:0],
                                           nil]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else{
        NSInteger selectedRow = indexPath.row;
        if (selectedRow == 1) {
            AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
            if (!appDelegate.loggedInUser) {
                [Helper showAlert:@"Error" message:@"Please login to perform this functionality."];
                return;
            }
        }
        if(selectIndex != -1){
            oldSelectIndex = selectIndex;
        }
        [tableView reloadData];
        selectIndex = selectedRow;
        UIView *left = [self getSettingViewByIndex:oldSelectIndex];
        UIView *right = [self getSettingViewByIndex:selectIndex];
        left.frame = RIGHT_VISIBLE_FRAME;
        if(oldSelectIndex > selectIndex){
            right.frame = RIGHT_HIDE_ORIGIN_FRAME;
        }
        else{
            right.frame = RIGHT_HIDE_TARGET_FRAME;
        }
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelay:0];
        [UIView setAnimationDuration:0.5];
        if(oldSelectIndex < selectIndex){
            left.frame = RIGHT_HIDE_ORIGIN_FRAME;
        }
        else{
            left.frame = RIGHT_HIDE_TARGET_FRAME;
        }
        right.frame = RIGHT_VISIBLE_FRAME;
        [UIView commitAnimations];
    }
}

/*!
 * This will be called when list item is selected.
 * @param index the index
 */
- (void)listviewDidSelect:(NSInteger)index {
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    UserServiceImpl *userService = appDelegate.userService;
    NSError *error;
    if (index == 0) {
        appDelegate.loggedInUser.useLastUsedFoodProductFilter = @NO;
    } else {
        appDelegate.loggedInUser.useLastUsedFoodProductFilter = @YES;
    }
    [userService saveUser:appDelegate.loggedInUser error:&error];
    if ([Helper displayError:error]) return;
}
@end