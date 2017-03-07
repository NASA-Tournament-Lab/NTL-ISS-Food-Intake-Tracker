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
//  ManageUserProfileViewController.m
//  FoodIntakeTracker
//
//  Created by lofzcx 06/25/2013
//

#import "ManageUserProfileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "UserServiceImpl.h"
#import "Helper.h"
#import "Settings.h"

@interface ManageUserProfileViewController (){
    /* the clear background cover layer */
    UIView *clearCover;
}

@end

@implementation ManageUserProfileViewController {
    /* Represents the users. */
    NSMutableArray *users;
}

/**
 * set the border for image view.
 * @param img the image view that are setted.
 */
- (void)setImageBorder:(UIImageView *)img{
    
    img.layer.borderWidth = 1;
    img.layer.borderColor = [UIColor colorWithRed:0.54 green:0.79 blue:1 alpha:1].CGColor;
}
/**
 * set the conner radius and border for view.
 * @param v the view that are setted.
 */
- (void)setTableBorder:(UIView *)v{
    v.layer.borderColor = [UIColor colorWithRed:0.77 green:0.77 blue:0.77 alpha:1].CGColor;
    v.layer.cornerRadius = 10;
    v.layer.borderWidth = 1;
}

/**
 * overwrite this method to layout the quantity label and quantity unit label. Also update label text here.
 * @param rect the view frame.
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
    
    [self setImageBorder:self.imgProfilePhoto];
    [self setImageBorder:self.imgSelectedUserPhoto];
    
    [self setTableBorder:self.profileTable];
    
    self.segmentControl.tintColor = [UIColor colorWithRed:0.16 green:0.33 blue:0.53 alpha:1];
    self.lblSegLeftTitle.textColor = [UIColor whiteColor];
    self.lblSegRightTitle.textColor = [UIColor blackColor];

    [[NSNotificationCenter defaultCenter] postNotificationName:AutoLogoutRenewEvent object:nil];

    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

/**
 * clear resource by setting nil value
 */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.selectIndex = 0;
    NSError *error;

    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    UserServiceImpl *userService = appDelegate.userService;
    users = [NSMutableArray arrayWithArray:[userService filterUsers:@"" error:&error]];
    if ([Helper displayError:error]) return;
    [users sortUsingComparator:^(User *obj1, User *obj2){
        return [obj1.fullName compare:obj2.fullName];
    }];

    for (int i = 0; i < users.count; i++) {
        User *user = users[i];
        if ([user.objectID isEqual:appDelegate.loggedInUser.objectID]) {
            self.selectIndex = i;
        }
    }

    [self.userListTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectIndex inSection:0]
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionNone];
    [self showPreviewProfile];

    if ([appDelegate.loggedInUser admin].boolValue) {
        [self.rightView setFrame:CGRectMake(313, 52, 455, 952)];
    }
    else {
        [self.rightView setFrame:CGRectMake(0, 52, 768, 952)];
    }

    self.lblSelectedUserName.numberOfLines = 4;
    self.lblSelectedUserName.text = appDelegate.loggedInUser.fullName;
    [self.lblSelectedUserName sizeToFit];
    self.imgProfilePhoto.image = self.imgSelectedUserPhoto.image = [Helper loadImage:appDelegate.loggedInUser.profileImage.filename];
    self.imgProfilePhoto.contentMode = UIViewContentModeScaleAspectFit;
    self.imgSelectedUserPhoto.contentMode = UIViewContentModeScaleAspectFit;
    NSArray *arr = [appDelegate.loggedInUser.fullName componentsSeparatedByString:@" "];
    self.lblProfileFirstName.text = [arr objectAtIndex:0];
    self.lblProfileLastName.text = (arr.count > 1) ? [arr objectAtIndex:1] : @"";
    self.btnTakePhoto.hidden = YES;

    [self reloadUsers];
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
    [self setBtnUpdateSave:nil];
    [self setBtnDelete:nil];
    [self setBtnCancel:nil];
    [self setTxtFirstName:nil];
    [self setTxtLastName:nil];
    [self setProfileDeletedNoteView:nil];
    [self setDeletePopupView:nil];
    [super viewDidUnload];
}
/**
 * hide the delete profile note view.
 */
- (void)hideProfileDeletedNoteView{
    self.profileDeletedNoteView.hidden = YES;
    
    [self.customTabBarController toggleEnableTab];
}

/**
 * action for delete button.
 * @param sender the button.
 */
- (IBAction)deleteProfile:(id)sender {
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    UserServiceImpl *userService = appDelegate.userService;
    User *user = [users objectAtIndex:self.selectIndex];
    if ([appDelegate.loggedInUser.objectID isEqual:user.objectID]) {
        [Helper showAlert:@"Error" message:@"You cannot delete your own profile."];
        [self hideDeletePopup:sender];
        return;
    }
    
    NSError *error;
    [userService deleteUser:user error:&error];
    if ([Helper displayError:error]) return;
    
    [users removeObject:user];
    [self.userListTable reloadData];
    self.selectIndex = 0;
    [self showPreviewProfile];
    self.deletePopupView.hidden = YES;
    self.profileDeletedNoteView.hidden = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DataSyncUpdate object:[NSDate date]];
    
    [self performSelector:@selector(hideProfileDeletedNoteView) withObject:nil afterDelay:1];
}

/**
 * hide the delete confirm view view.
 * @param sender the button.
 */
- (IBAction)hideDeletePopup:(id)sender {
    self.deletePopupView.hidden = YES;
    
    [self.customTabBarController toggleEnableTab];
}
/**
 * show the delete confirm view view.
 * @param sender the button.
 */
- (IBAction)showDeletePopup:(id)sender {
    self.deletePopupView.hidden = NO;
    
    [self.customTabBarController toggleEnableTab];
}

/**
 * return back to summary view.
 * @param sender the button.
 */

- (IBAction)viewSummary:(id)sender{
    [self.txtLastName resignFirstResponder];
    [self.txtFirstName resignFirstResponder];
    [self.customTabBarController setConsumptionActive];
}
/**
 * show the profile preview view
 */
- (void)showPreviewProfile{
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    User *user = [users objectAtIndex:self.selectIndex];
    self.btnCancel.hidden = YES;
    self.btnDelete.hidden = ![appDelegate.loggedInUser.admin boolValue] || [appDelegate.loggedInUser.objectID isEqual:user.objectID];
    [self.btnUpdateSave setTitle:@"Update" forState:UIControlStateNormal];
    self.profileView.hidden = NO;
    self.profileTable.hidden = NO;
    self.txtFirstName.hidden = YES;
    self.txtLastName.hidden = YES;
    self.lblProfileFirstName.hidden = NO;
    self.lblProfileLastName.hidden = NO;
    NSArray *components = [user.fullName componentsSeparatedByString:@" "];
    if (components.count > 0) {
        self.lblProfileFirstName.text = [components objectAtIndex:0];
    }
    else {
        self.lblProfileFirstName.text = @"";
    }
    if (components.count > 1) {
        self.lblProfileLastName.text = [components objectAtIndex:1];
    }
    else {
        self.lblProfileLastName.text = @"";
    }
    
    self.imgProfilePhoto.image = [Helper loadImage:user.profileImage.filename];
    [self.txtLastName resignFirstResponder];
    [self.txtFirstName resignFirstResponder];
}

/**
 * show the profile edit view.
 */
- (void)showEditProfile{
    User *user = [users objectAtIndex:self.selectIndex];
    self.btnCancel.hidden = NO;
    self.btnDelete.hidden = YES;
    [self.btnUpdateSave setTitle:@"Save" forState:UIControlStateNormal];
    self.profileView.hidden = NO;
    self.profileTable.hidden = NO;
    self.txtFirstName.hidden = NO;
    self.txtLastName.hidden = NO;
    self.lblProfileFirstName.hidden = YES;
    self.lblProfileLastName.hidden = YES;
    NSArray *components = [user.fullName componentsSeparatedByString:@" "];
    if (components.count > 0) {
        self.txtFirstName.text = [components objectAtIndex:0];
    }
    else {
        self.txtFirstName.text = @"";
    }
    if (components.count > 1) {
        self.txtLastName.text = [components objectAtIndex:1];
    }
    else {
        self.txtLastName.text = @"";
    }
    self.imgProfilePhoto.image = [Helper loadImage:user.profileImage.filename];
}

/**
 * show the photo preview view.
 */
- (void)showPhotoPreview{
    User *user = [users objectAtIndex:self.selectIndex];
    self.btnTakePhoto.hidden = YES;
    self.btnCancel.hidden = YES;
    self.btnDelete.hidden = YES;
    [self.btnUpdateSave setTitle:@"Update" forState:UIControlStateNormal];
    self.profileView.hidden = NO;
    self.profileTable.hidden = YES;
    [self.txtLastName resignFirstResponder];
    [self.txtFirstName resignFirstResponder];
    self.imgProfilePhoto.image = [Helper loadImage:user.profileImage.filename];
}

/**
 * This method will show edit profile photo.
 */
- (void)showEditPhoto{
    User *user = [users objectAtIndex:self.selectIndex];
    self.btnTakePhoto.hidden = NO;
    self.btnCancel.hidden = NO;
    self.btnDelete.hidden = YES;
    [self.btnUpdateSave setTitle:@"Save" forState:UIControlStateNormal];
    self.profileView.hidden = NO;
    self.profileTable.hidden = YES;
    self.imgProfilePhoto.image = [Helper loadImage:user.profileImage.filename];
    [self takePhoto:nil];
}

/**
 * This method will reset the selection of the left table.
 */
- (void)resetSelection:(NSString *)name {
    for (int i = 0; i < users.count; i++) {
        User *user = users[i];
        if ([user.fullName isEqualToString:name]) {
            self.selectIndex = i;
        }
    }
    [self reloadUsers];
}

/**
 * This method will take user's picture.
 * @param sender the segment control.
 */
- (IBAction)takePhoto:(id)sender {
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
    [self.popover presentPopoverFromRect:self.btnTakePhoto.frame
                                  inView:self.btnTakePhoto.superview
                permittedArrowDirections:UIPopoverArrowDirectionAny
                                animated:YES];
}


/**
 * change between profile and photo view.
 * @param sender the segment control.
 */
- (IBAction)segmentValueChanged:(id)sender {
    
    if(self.segmentControl.selectedSegmentIndex == 0){
        self.lblSegLeftTitle.textColor = [UIColor whiteColor];
        self.lblSegRightTitle.textColor = [UIColor blackColor];
        
        [self showPreviewProfile];
    }
    else{
        self.lblSegRightTitle.textColor = [UIColor whiteColor];
        self.lblSegLeftTitle.textColor = [UIColor blackColor];
        
        [self showPhotoPreview];
    }
}
/**
 * action for cancel button click.
 * @param sender the button.
 */
- (IBAction)cancelEditing:(id)sender {
    if (self.segmentControl.selectedSegmentIndex == 0) {
        [self showPreviewProfile];
    }
    else {
        [self showPhotoPreview];
    }
}
/**
 * actoin for update and save button.
 * @param sender the button.
 */
- (IBAction)saveUpdateProfile:(id)sender {
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    UserServiceImpl *userService = appDelegate.userService;
    User *user = [users objectAtIndex:self.selectIndex];
    NSError *error;
    if(self.profileTable.hidden == NO && self.lblProfileFirstName.hidden == NO){
        [self showEditProfile];
    }
    else if(self.profileTable.hidden == NO && self.txtFirstName.hidden == NO){
        // Validation
        // Validation
        self.txtFirstName.text = [self.txtFirstName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.txtLastName.text = [self.txtLastName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        if (![Helper checkStringIsValid:self.txtFirstName.text] || ![Helper checkStringIsValid:self.txtLastName.text]) {
            [Helper showAlert:@"Error" message:@"Please enter your first & last name"];
            return;
        }
        
        if (self.txtFirstName.text.length > 35 || self.txtLastName.text.length > 35) {
            [Helper showAlert:@"Error" message:@"Sorry, the name field values entered are too long (max 35 characters)."];
            return;
        }
        
        if ([self.txtFirstName.text rangeOfString:@" "].location != NSNotFound ||
            [self.txtLastName.text rangeOfString:@" "].location != NSNotFound) {
            [Helper showAlert:@"Error" message:@"The names should not have spaces."];
            return;
        }
        
        User *user = [users objectAtIndex:self.selectIndex];
        user.fullName = [NSString stringWithFormat:@"%@ %@", self.txtFirstName.text, self.txtLastName.text];
        user.synchronized = @NO;
        [userService saveUser:user error:&error];
        if ([Helper displayError:error]) return;
        [self showPreviewProfile];
        [self reloadUsers];
        [self resetSelection:user.fullName];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DataSyncUpdate object:[NSDate date]];
    }
    else if(self.btnTakePhoto.hidden) {
        [self showEditPhoto];
    }
    else {
        NSString *imagePath = [Helper saveImage2:self.imgProfilePhoto.image];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Media"
                                                  inManagedObjectContext:[user managedObjectContext]];

        user.profileImage = [[Media alloc] initWithEntity:entity insertIntoManagedObjectContext:[user managedObjectContext]];
        user.profileImage.removed = @NO;
        user.profileImage.filename = imagePath;
        user.profileImage.data = UIImageJPEGRepresentation(self.imgProfilePhoto.image, 0.9);
        user.profileImage.synchronized = @NO;
        user.synchronized = @NO;
        [userService saveUser:user error:&error];
        if ([Helper displayError:error]) return;

        if ([appDelegate.loggedInUser.objectID isEqual:user.objectID]) {
            appDelegate.loggedInUser = user;
        }

        [self showPhotoPreview];
        [self reloadUsers];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DataSyncUpdate object:[NSDate date]];
    }
}

#pragma mark - Table View Datasource Delegate Methods

/**
 * returns the rows number of user list table.
 * @param tableView The table-view object requesting this information.
 * @param section An index number identifying a section in tableView.
 * @return helpitems count or setting items count.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return users.count;
}

/**
 * defines the table cell for user list table.
 * @param tableView A table-view object requesting the cell.
 * @param indexPath An index path locating a row in tableView.
 * @return the table cell.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* UserListCellIdentifier = @"UserListCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UserListCellIdentifier];
    User *user = [users objectAtIndex:indexPath.row];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:UserListCellIdentifier];
        
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(295, 17, 8, 13)];
        img.image = [UIImage imageNamed:@"icon-arrow.png"];
        img.tag = 100;
        [cell addSubview:img];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 49, tableView.frame.size.width, 1)];
        [line setBackgroundColor:[UIColor whiteColor]];
        [cell addSubview:line];
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(52, 0, 240, 49)];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.tag = 101;
        [cell addSubview:lbl];
        UIImageView *img1 = [[UIImageView alloc] initWithFrame:CGRectMake(11, 11, 26, 26)];
        [cell addSubview:img1];
        img1.tag = 102;
    }
    UILabel *lbl = (UILabel *)[cell viewWithTag:101];
    UIImageView *img = (UIImageView *)[cell viewWithTag:102];
    if(indexPath.row == self.selectIndex){
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
    img.image = [Helper loadImage:user.profileImage.filename];
    img.layer.borderWidth = 1;
    img.layer.borderColor = [UIColor colorWithRed:0.54 green:0.79 blue:1 alpha:1].CGColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

/**
 * Update the details view.
 */
- (void) updateDetailsView {
    if (self.selectIndex >= 0) {
        self.profileView.hidden = NO;
        self.segmentControl.hidden = NO;
        self.buttonsView.hidden = NO;
        self.lblSegLeftTitle.hidden = NO;
        self.lblSegRightTitle.hidden = NO;

        User *user = [users objectAtIndex:self.selectIndex];
        NSArray *components = [user.fullName componentsSeparatedByString:@" "];
        if (components.count > 0) {
            self.lblProfileFirstName.text = [components objectAtIndex:0];
        }
        else {
            self.lblProfileFirstName.text = @"";
        }
        if (components.count > 1) {
            self.lblProfileLastName.text = [components objectAtIndex:1];
        }
        else {
            self.lblProfileLastName.text = @"";
        }
        self.txtFirstName.text = self.lblProfileFirstName.text;
        self.txtLastName.text = self.lblProfileLastName.text;
        if(self.segmentControl.selectedSegmentIndex == 0){
            [self showPreviewProfile];
        } else {
            [self showPhotoPreview];
        }
    }
    else {
        self.profileView.hidden = YES;
        self.segmentControl.hidden = YES;
        self.buttonsView.hidden = YES;
        self.lblSegLeftTitle.hidden = YES;
        self.lblSegRightTitle.hidden = YES;
    }
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
    
    if (self.selectIndex >= users.count) {
        self.selectIndex = 0;
    }
    [self.userListTable reloadData];
    if (users.count == 0) {
        self.selectIndex = -1;
    }
    
    if (self.selectIndex >= 0) {
        [self.userListTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectIndex inSection:0]
                                        animated:YES
                                  scrollPosition:UITableViewScrollPositionNone];
    }

    self.lblSelectedUserName.numberOfLines = 4;
    self.lblSelectedUserName.text = appDelegate.loggedInUser.fullName;
    [self.lblSelectedUserName sizeToFit];
    self.imgProfilePhoto.image = self.imgSelectedUserPhoto.image = [Helper loadImage:appDelegate.loggedInUser.profileImage.filename];

    [self updateDetailsView];
}

/**
 * perform the navigate action for user list table.
 * change the detail content of profile.
 * @param tableView A table-view object requesting the cell.
 * @param indexPath An index path locating a row in tableView.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger oldSelectIndex = 0;
    if(indexPath.row == self.selectIndex){
        return;
    }
    if(self.selectIndex != -1){
        oldSelectIndex = self.selectIndex;
    }
    self.selectIndex = indexPath.row;
    //update help content here.
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,
                                       [NSIndexPath indexPathForRow:oldSelectIndex inSection:0],
                                       nil]
                     withRowAnimation:UITableViewRowAnimationAutomatic];
    [self updateDetailsView];
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
    if (self.selectIndex >= users.count) {
        self.selectIndex = 0;
    }
    [self.userListTable reloadData];
    if (users.count == 0) {
        self.selectIndex = -1;
    }
    
    if (self.selectIndex >= 0) {
        [self.userListTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectIndex inSection:0]
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

/*!
 * This method will be called when the picture is taken.
 * @param picker the UIImagePickerController
 * @param info the information
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imgProfilePhoto.image = chosenImage;
    
    [self.popover dismissPopoverAnimated:YES];

    [[NSNotificationCenter defaultCenter] postNotificationName:DataSyncUpdate object:[NSDate date]];
}

/*!
 * This method will be called when the picture taking is cancelled.
 * @param picker the UIImagePickerController
 */
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.popover dismissPopoverAnimated:YES];
}

/*!
 * This method will be called when the return button on the text field is tapped.
 * @param textField the textField
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.txtFirstName]) {
        [self.txtLastName becomeFirstResponder];
    }
    else if ([textField isEqual:self.txtLastName]) {
        [self.txtLastName resignFirstResponder];
    }
    return YES;
}

- (void)keyboardWillShow:(NSNotification *) note{
    NSDictionary *userInfo = note.userInfo;
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];

    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        self.view.frame = CGRectMake(0, -120.f, self.view.frame.size.width, self.view.frame.size.height);
    } completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];

    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    } completion:nil];
}

@end
