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
//  UserApplicationDataViewController.m
//  FoodIntakeTracker
//
//  Created by lofzcx 06/25/2013
//

#import "UserApplicationDataViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Helper.h"
#import "AppDelegate.h"
#import "UserServiceImpl.h"
#import "FoodConsumptionRecordServiceImpl.h"
#import "Settings.h"

@implementation UserApplicationDataFoodTableCell

/**
 * overwrite this method to layout the quantity label and quantity unit label. Also update label text here.
 * @param rect the view frame.
 */
- (void)drawRect:(CGRect)rect{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:@"#.##"];
    self.lblQuantity.text = [numberFormatter stringFromNumber:self.foodConsumptionRecord.quantity];
    //CGSize size2 = self.lblQuantityUnit.frame.size;
    //CGSize size1 = [self.lblQuantity.text sizeWithFont:self.lblQuantity.font];
    //float centerX = 120;
    //float startX = centerX - (size1.width + size2.width + 2) / 2;
    //self.lblQuantity.frame = CGRectMake(startX, 16, size1.width, size2.height);
    //self.lblQuantityUnit.frame = CGRectMake(startX + size1.width + 2, 16, size2.width, size2.height);
    self.lblName.text = self.foodConsumptionRecord.foodProduct.name;
    NSDateFormatter *defaultFormatter = [Helper defaultFormatter];
    [defaultFormatter setDateFormat:@"HH:mm"];
    self.lblTime.text = [defaultFormatter stringFromDate:self.foodConsumptionRecord.timestamp];
    [defaultFormatter setDateFormat:@"MM/dd/YY"];
    self.lblDay.text = [defaultFormatter stringFromDate:self.foodConsumptionRecord.timestamp];
    if(self.foodConsumptionRecord.comment.length > 0){
        self.btnComment.hidden = NO;
    }
    else{
        self.btnComment.hidden = YES;
    }
}
@end

@interface UserApplicationDataViewController (){
    /* the food items */
    NSMutableArray *foodItems;
    /* the select index of the user list */
    NSInteger selectIndex;
    /* the clear background cover layer */
    UIView *clearCover;
}

@end

@implementation UserApplicationDataViewController
/**
 * hide search bar background, set font title, set border here.
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
    
    [self.segmentControl setDividerImage:[UIImage imageNamed:@"bg-seg-left@425"]
                     forLeftSegmentState:UIControlStateSelected
                       rightSegmentState:UIControlStateNormal
                              barMetrics:UIBarMetricsDefault];
    
    [self.segmentControl setDividerImage:[UIImage imageNamed:@"bg-seg-right@425"]
                     forLeftSegmentState:UIControlStateNormal
                       rightSegmentState:UIControlStateSelected
                              barMetrics:UIBarMetricsDefault];
    
    self.imgProfilePhoto.layer.borderWidth = 1;
    self.imgProfilePhoto.layer.borderColor = [UIColor colorWithRed:0.54 green:0.79 blue:1 alpha:1].CGColor;
    self.imgSelectedUserPhoto.layer.borderWidth = 1;
    self.imgSelectedUserPhoto.layer.borderColor = [UIColor colorWithRed:0.54 green:0.79 blue:1 alpha:1].CGColor;
    
    self.profileTable.layer.borderColor = [UIColor colorWithRed:0.77 green:0.77 blue:0.77 alpha:1].CGColor;
    self.profileTable.layer.cornerRadius = 10;
    self.profileTable.layer.borderWidth = 1;
    
    selectIndex = 0;
    foodConsumptionRecords = [NSMutableArray array];
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    UserServiceImpl *userService = appDelegate.userService;
    NSError *error;
    users = [NSMutableArray arrayWithArray:[userService filterUsers:@"" error:&error]];
    if ([Helper displayError:error]) return;
    [users sortUsingComparator:^(User *obj1, User *obj2){
        return [obj1.fullName compare:obj2.fullName];
    }];
    
    self.lblSelectedUserName.text = appDelegate.loggedInUser.fullName;
    self.imgProfilePhoto.image = self.imgSelectedUserPhoto.image =
    [Helper loadImage:appDelegate.loggedInUser.profileImage];
    self.imgProfilePhoto.contentMode = UIViewContentModeScaleAspectFit;
    self.imgSelectedUserPhoto.contentMode = UIViewContentModeScaleAspectFit;
    NSArray *arr = [appDelegate.loggedInUser.fullName componentsSeparatedByString:@" "];
    self.lblProfileFirstName.text = [arr objectAtIndex:0];
    self.lblProfileLastName.text = (arr.count > 1) ? [arr objectAtIndex:1] : @"";
    
    for (int i = 0; i < users.count; i++) {
        User *user = users[i];
        if ([user isEqual:appDelegate.loggedInUser]) {
            selectIndex = i;
        }
    }
    
    self.lblSegRightTitle.textColor = [UIColor colorWithRed:0.21 green:0.21 blue:0.21 alpha:1];
    self.lblSegLeftTitle.textColor = [UIColor whiteColor];
    
    self.profileView.hidden = YES;
    self.commentView.hidden = YES;
    self.consumptionView.hidden = NO;
    
    [self.userListTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectIndex inSection:0]
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionNone];
    [[NSNotificationCenter defaultCenter] postNotificationName:AutoLogoutRenewEvent object:nil];
}

/**
 * clear resource by setting nil value
 */
- (void)viewDidUnload {
    [self setSegmentControl:nil];
    [self setLblSegLeftTitle:nil];
    [self setLblSegRightTitle:nil];
    [self setLblTitle:nil];
    [self setLblSelectedUserName:nil];
    [self setImgSelectedUserPhoto:nil];
    [self setSearchBar:nil];
    [self setUserListTable:nil];
    [self setLeftView:nil];
    [self setProfileView:nil];
    [self setImgProfilePhoto:nil];
    [self setProfileTable:nil];
    [self setLblProfileFirstName:nil];
    [self setLblProfileLastName:nil];
    [self setConsumptionView:nil];
    [self setConsumptionTable:nil];
    [self setCommentView:nil];
    [self setCommentText:nil];
    [super viewDidUnload];
}

/**
 * clear resource by setting nil value
 */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    self.lblSelectedUserName.text = appDelegate.loggedInUser.fullName;
    self.imgSelectedUserPhoto.image = [Helper loadImage:appDelegate.loggedInUser.profileImage];
    [self reloadUsers];
    
    NSError *error;
    FoodConsumptionRecordServiceImpl *recordService = appDelegate.foodConsumptionRecordService;
    [foodConsumptionRecords removeAllObjects];
    [foodConsumptionRecords addObjectsFromArray:
     [recordService getFoodConsumptionRecords:[users objectAtIndex:selectIndex]
                                        error:&error]];
    [self.consumptionTable reloadData];
}

/**
 * return back to summary view.
 * @param sender the button.
 */
- (IBAction)viewSummary:(id)sender{
    [self.customTabBarController setConsumptionActive];
}

/**
 * Reload the users
 */
- (void)reloadUsers{
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    UserServiceImpl *userService = appDelegate.userService;
    NSError *error;
    NSString *filterText = self.searchBar.text;
    if (!filterText) {
        filterText = @"";
    }
    users = [NSMutableArray arrayWithArray:[userService filterUsers:filterText error:&error]];
    if ([Helper displayError:error]) return;
    
    [users sortUsingComparator:^(User *obj1, User *obj2){
        return [obj1.fullName compare:obj2.fullName];
    }];
    
    if (selectIndex >= users.count) {
        selectIndex = 0;
    }
    [self.userListTable reloadData];
    if (users.count == 0) {
        selectIndex = -1;
    }
    
    if (selectIndex >= 0) {
        [self.userListTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectIndex inSection:0]
                                        animated:YES
                                  scrollPosition:UITableViewScrollPositionNone];
    }
    [self updateDetailsView];
}

/**
 * hide the comment popup
 */
- (void)hideFoodComment{
    [clearCover removeFromSuperview];
    clearCover = nil;
    self.commentView.hidden = YES;
}
/**
 * show the comment popup and set comment text.
 * @param sender the button.
 */
- (void)showFoodComment:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSInteger row = btn.tag;
    int startPos = 55 * row + 135 - self.consumptionTable.contentOffset.y;
    self.commentView.frame = CGRectMake(471, startPos, 291, 153);
    self.commentView.hidden = NO;
    
    FoodConsumptionRecord *item = [foodConsumptionRecords objectAtIndex:row];
    self.commentText.text = item.comment;
    
    btn = [[UIButton alloc] initWithFrame:self.view.frame];
    [self.view addSubview:btn];
    [self.view bringSubviewToFront:self.commentView];
    [btn addTarget:self action:@selector(hideFoodComment) forControlEvents:UIControlEventTouchUpInside];
    clearCover = btn;
}
/**
 * change between profile and consumption view.
 * @param sender the segment control.
 */
- (IBAction)segmentValueChanged:(id)sender {
    if(self.segmentControl.selectedSegmentIndex == 0){
        self.lblSegLeftTitle.textColor = [UIColor colorWithRed:0.21 green:0.21 blue:0.21 alpha:1];
        self.lblSegRightTitle.textColor = [UIColor whiteColor];
        
        self.profileView.hidden = NO;
        self.commentView.hidden = YES;
        self.consumptionView.hidden = YES;
    }
    else{
        AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        FoodConsumptionRecordServiceImpl *recordService = appDelegate.foodConsumptionRecordService;
        NSError *error;
        [foodConsumptionRecords removeAllObjects];
        [foodConsumptionRecords addObjectsFromArray:
         [recordService getFoodConsumptionRecords:[users objectAtIndex:selectIndex]
                                            error:&error]];
        [self.consumptionTable reloadData];
        self.lblSegRightTitle.textColor = [UIColor colorWithRed:0.21 green:0.21 blue:0.21 alpha:1];
        self.lblSegLeftTitle.textColor = [UIColor whiteColor];
        
        self.profileView.hidden = YES;
        self.commentView.hidden = YES;
        self.consumptionView.hidden = NO;
    }
}

/**
 * Update the details view.
 */
- (void) updateDetailsView {
    if (selectIndex >= 0) {
        self.profileView.hidden = NO;
        self.consumptionView.hidden = NO;
        self.segmentControl.hidden = NO;
        self.lblSegLeftTitle.hidden = NO;
        self.lblSegRightTitle.hidden = NO;
        
        User *user = [users objectAtIndex:selectIndex];
        AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        FoodConsumptionRecordServiceImpl *recordService = appDelegate.foodConsumptionRecordService;
        NSError *error;
        [foodConsumptionRecords removeAllObjects];
        [foodConsumptionRecords addObjectsFromArray:[recordService getFoodConsumptionRecords:user
                                                                                       error:&error]];
        if ([Helper displayError:error]) return;
        
        [self.consumptionTable reloadData];
        
        NSArray *components = [user.fullName componentsSeparatedByString:@" "];
        
        self.lblProfileFirstName.text = @"";
        self.lblProfileLastName.text = @"";
        if (components.count >= 1) {
            self.lblProfileFirstName.text = [components objectAtIndex:0];
        }
        if (components.count >= 2) {
            self.lblProfileLastName.text = [components objectAtIndex:1];
        }
        
        self.imgProfilePhoto.image = [Helper loadImage:user.profileImage];
    }
    else {
        self.profileView.hidden = YES;
        self.consumptionView.hidden = YES;
        self.segmentControl.hidden = YES;
        self.lblSegLeftTitle.hidden = YES;
        self.lblSegRightTitle.hidden = YES;
    }
}

#pragma mark - Table View Datasource Delegate Methods

/**
 * returns the rows number of user list table and consumption table.
 * @param tableView The table-view object requesting this information.
 * @param section An index number identifying a section in tableView.
 * @return helpitems count or setting items count.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView == self.userListTable){
        return users.count;
    } else{
        return foodConsumptionRecords.count;
    }
}

/**
 * defines the table cell for user list table and consumption table.
 * @param tableView A table-view object requesting the cell.
 * @param indexPath An index path locating a row in tableView.
 * @return the table cell.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* UserListCellIdentifier = @"UserListCellIdentifier";
    if(tableView == self.userListTable){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UserListCellIdentifier];
        User *user = [users objectAtIndex:indexPath.row];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:UserListCellIdentifier];
            
            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(263, 17, 8, 13)];
            img.image = [UIImage imageNamed:@"icon-arrow.png"];
            img.tag = 100;
            [cell addSubview:img];
            /*UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 49, tableView.frame.size.width, 1)];
            [line setBackgroundColor:[UIColor lightGrayColor]];
            [cell addSubview:line];*/
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(52, 0, 211, 49)];
            lbl.backgroundColor = [UIColor clearColor];
            lbl.tag = 101;
            [cell addSubview:lbl];
            UIImageView *img1 = [[UIImageView alloc] initWithFrame:CGRectMake(11, 11, 26, 26)];
            [cell addSubview:img1];
            img1.tag = 102;
        }
        UILabel *lbl = (UILabel *)[cell viewWithTag:101];
        UIImageView *img = (UIImageView *)[cell viewWithTag:102];
        if(indexPath.row == selectIndex){
            lbl.textColor = [UIColor whiteColor];
            cell.contentView.backgroundColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1];
            [cell viewWithTag:100].hidden = YES;
        }
        else{
            lbl.textColor = [UIColor colorWithRed:0.2 green:0.43 blue:0.62 alpha:1];
            cell.contentView.backgroundColor = [UIColor clearColor];
            [cell viewWithTag:100].hidden = NO;
        }
        lbl.font = [UIFont boldSystemFontOfSize:16];
        lbl.text = user.fullName;
        img.image = [Helper loadImage:user.profileImage];
        img.layer.borderWidth = 1;
        img.layer.borderColor = [UIColor colorWithRed:0.54 green:0.79 blue:1 alpha:1].CGColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else{
        static NSString *UserApplicationDataFoodTableCellIdentifier = @"UserApplicationDataFoodTableCellIdentifier";
        UserApplicationDataFoodTableCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                                  UserApplicationDataFoodTableCellIdentifier];
        cell.foodConsumptionRecord = [foodConsumptionRecords objectAtIndex:indexPath.row];
        cell.btnComment.tag = indexPath.row;
        [cell.btnComment addTarget:self
                            action:@selector(showFoodComment:)
                  forControlEvents:UIControlEventTouchUpInside];
        
        [cell setNeedsDisplay];
        return cell;
    }
}

/**
 * perform the navigate action for user list table.
 * change the detail content of profile.
 * @param tableView A table-view object requesting the cell.
 * @param indexPath An index path locating a row in tableView.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    int oldSelectIndex = 0;
    if(indexPath.row == selectIndex){
        return;
    }
    if(tableView == self.userListTable){
        if(selectIndex != -1){
            oldSelectIndex = selectIndex;
        }
        selectIndex = indexPath.row;
        //update help content here.
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,
                                           [NSIndexPath indexPathForRow:oldSelectIndex inSection:0],
                                           nil]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
        [self updateDetailsView];
    }
    else {
        return;
    }
}

#pragma mark - UISearchBarDelegate methods
/**
 * called when keyboard search text is changed. Perform filtering here.
 * @param searchBar the searchBar.
 */
- (void)searchBar:(UISearchBar *)bar textDidChange:(NSString *)searchText {
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    UserServiceImpl *userService = appDelegate.userService;
    NSError *error;
    [users removeAllObjects];
    NSArray *result = [userService filterUsers:searchText error:&error];
    [users addObjectsFromArray:result];
    
    if (selectIndex >= users.count) {
        selectIndex = 0;
    }
    [self.userListTable reloadData];
    if (users.count == 0) {
        selectIndex = -1;
    }
    
    if (selectIndex >= 0) {
        [self.userListTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectIndex inSection:0]
                                        animated:YES
                                  scrollPosition:UITableViewScrollPositionNone];
    }
    
    [self updateDetailsView];
    
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
        for (int i = 0; i < result.count; i++) {
            User *user = result[i];
            NSString *userName = user.fullName;
            if ([searchText isEqualToString:@""] || [userName rangeOfString:searchText].location == 0) {
                [suggestions addObject:userName];
            }
        }
        self.suggestionTableView.suggestions = suggestions;
        [self.suggestionTableView.theTableView reloadData];
    }
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
