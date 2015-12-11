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
//  LoginViewController.m
//  FoodIntakeTracker
//
//  Created by lofzcx 05/03/2013
//
//  Updated by pvmagacho on 05/07/2014
//  F2Finish - NASA iPad App Updates
//

#import "LoginViewController.h"
#import "CustomTabBarViewController.h"
#import "UserServiceImpl.h"
#import "AppDelegate.h"
#import "PGCoreData.h"
#import "Helper.h"
#import "Settings.h"

@implementation LoginGridView

/**
 * overwrite this method to draw grid view.
 * @param rect the drawing rect.
 */
- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 1, 1, 1, 1);
    CGContextSetLineWidth(context, 1.0f);
    int height = rect.size.height;
    int width = rect.size.width;
    CGContextSetRGBFillColor(context, 0, 0, 0, 1);
    for(int x = 0; x < width; x += 40){
        int w = 38;
        if(x + 40 > width){
            w = width - x;
        }
        for(int y = 0; y < height; y += 40){
            int h = 38;
            if(y + 40 > height){
                h = height - y;
            }
            CGContextFillRect(context, CGRectMake(x + 1 , y + 1 , w, h));
        }
    }
    CGContextStrokePath(context);
    CGSize size = self.imgTakePhoto.frame.size;
    CGPoint pos = self.imgTakePhoto.frame.origin;
    UIGraphicsBeginImageContext(size);
    CGRect imgRect = self.imgTakePhoto.frame;
    [self.imgTakePhoto.image drawInRect:CGRectMake(0, 0, imgRect.size.width, imgRect.size.height)];
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 10);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1, 0, 0, 10);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    for(int x = 40; x < width; x += 40){
        if(x - pos.x > 0 && x - pos.x < size.width){
            CGContextMoveToPoint(UIGraphicsGetCurrentContext(), x - pos.x - 1, 0);
            CGContextClearRect (UIGraphicsGetCurrentContext(), CGRectMake(x - pos.x - 1, 0, 2, size.height));
        }
    }
    for(int y = 40; y < height; y += 40){
        if(y - pos.y > 0 && y - pos.y < size.height){
            CGContextMoveToPoint(UIGraphicsGetCurrentContext(), 0, y - pos.y);
            CGContextClearRect (UIGraphicsGetCurrentContext(), CGRectMake(0, y - pos.y - 1, size.width, 2));
        }
    }
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    // No need to update the taken photo any more.
    // self.imgTakePhoto.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

@end

@interface LoginViewController() <UIScrollViewDelegate>{
    /* the selected user index */
    int selectUserIndex;
}

/**
 * get saved user and images. Push them in the scroll view.
 */
- (void)getSavedUsers;

/**
 * show user selected login panel.
 * @param btn Indicates which user is selected.
 */
- (void)showSelectedUserPanel:(UIButton *)btn;

/**
 * update the taking pregress.
 * @param timer the update timer.
 */
- (void)updateTakingStatusTimer:(NSTimer *)timer;

@end

@implementation LoginViewController {
    NSArray *userLocks;
}

/**
 * Overwrite this method to set login panel list panel as default.
 */
- (void)viewWillAppear:(BOOL)animated{
    [self showLoginPanel:nil];
    [self getSavedUsers];
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startLoading)
                                                 name:InitialLoadingBeginEvent object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishLoading:)
                                                 name:InitialLoadingEndEvent object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backup)
                                                 name:BackupBeginEvent object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadingNew)
                                                 name:LoadingNewBeginEvent object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgress:)
                                                 name:InitialLoadingProgressEvent object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 * we set some property and hardcode some values here. It could be modified to load specify values.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.lblSelectedUsername.font = [UIFont fontWithName:@"Bebas" size:28];
    self.lblLoginScreenTitle.font = self.lblRegisterPanelTitle.font = [UIFont fontWithName:@"Bebas" size:40];
    self.lblLoginPanelTitle.font = self.lblRegisterPanelTitle.font = [UIFont fontWithName:@"Bebas" size:32];
    
    // Do any additional setup after loading the view.
    
    self.progressView.backgoundImage = [UIImage imageNamed:@"bg-progress.png"];
    self.progressView.fullColor = [UIColor greenColor];
    self.progressView.progressImage = [UIImage imageNamed:@"bg-progress-red.png"];
    self.progressView.currentProgress = 0.0;
}

/**
 * action for register button. Show the register panel.
 */
- (IBAction)showRegister {
    self.txtUserName.text = @"";
    self.txtLastName.text = @"";
    self.loginPanel.hidden = YES;
    self.registerPanel.hidden = NO;
    self.registerUserNamePanel.hidden = NO;
    self.registerPhotoPanel.hidden = YES;
    self.registerFinishPanel.hidden = YES;
}

/**
 * showing login panel. Action for cancel button in register username panel.
 * @param sender the button click.
 */
- (IBAction)showLoginPanel:(id)sender{
    self.registerPanel.hidden = YES;
    self.loginPanel.hidden = NO;
    self.loginSelectedPanel.hidden = YES;
    self.loginListPanel.hidden = NO;
    [self.txtLastName resignFirstResponder];
    [self.txtUserName resignFirstResponder];
}
/**
 * action for next button in register username panel.
 * @param sender the button click.
 */
- (IBAction)showRegisterPhotoPanel:(id)sender{
    // Validation
    self.txtUserName.text = [self.txtUserName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.txtLastName.text = [self.txtLastName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (![Helper checkStringIsValid:self.txtUserName.text] || ![Helper checkStringIsValid:self.txtLastName.text]) {
        [Helper showAlert:@"Error" message:@"Please enter your first & last name"];
        return;
    }
    
    if (self.txtUserName.text.length > 35 || self.txtLastName.text.length > 35) {
        [Helper showAlert:@"Error" message:@"Sorry, the name field values entered are too long (max 35 characters)."];
        return;
    }
    
    if ([self.txtUserName.text rangeOfString:@" "].location != NSNotFound ||
        [self.txtLastName.text rangeOfString:@" "].location != NSNotFound) {
        [Helper showAlert:@"Error" message:@"The names should not have spaces."];
        return;
    }

    // check if user exists
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    UserServiceImpl *userService = appDelegate.userService;
    NSError *error;

    NSString *fullName = [self.txtUserName.text stringByAppendingFormat:@" %@", self.txtLastName.text];
    NSArray *results = [userService filterUsers:fullName error:&error];
    if ([Helper displayError:error]) return;

    if (results.count > 0) {
        [Helper showAlert:@"Error" message:@"User already exists. Please select different First/Last names."];

        self.loginPanel.hidden = YES;
        self.registerPanel.hidden = NO;
        self.registerUserNamePanel.hidden = NO;
        self.registerPhotoPanel.hidden = YES;
        self.registerFinishPanel.hidden = YES;

        return;
    }
    
    self.registerPanel.hidden = NO;
    self.registerPhotoPanel.hidden = NO;
    self.btnTakePhoto.hidden = NO;
    self.btnTakeCancel.hidden = NO;
    self.loginPanel.hidden = YES;
    self.registerUserNamePanel.hidden = YES;
    self.registerFinishPanel.hidden = YES;
    self.lblTakeingPhoto.hidden = YES;
    self.btnFinish.hidden = YES;
    self.btnRetakePhoto.hidden = YES;
    self.prgTakingPhoto.hidden = YES;
    [self.txtLastName resignFirstResponder];
    [self.txtUserName resignFirstResponder];
    self.loginGridView.imgPhotoCover.frame = CGRectMake(0, 0, 320, 0);
    self.loginGridView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.loginGridView.layer.borderWidth = 1.0f;
    [self.loginGridView setNeedsDisplay];
}

/**
 * update the taking pregress.
 * @param timer the update timer.
 */
- (void)updateTakingStatusTimer:(NSTimer *)timer{
    if(self.prgTakingPhoto.progress == 1){
        [timer invalidate];
        self.btnTakeCancel.hidden = NO;
        self.btnTakePhoto.hidden = YES;
        self.btnFinish.hidden = NO;
        self.btnRetakePhoto.hidden = NO;
        self.lblTakeingPhoto.hidden = YES;
        return;
    }
    self.prgTakingPhoto.progress = self.prgTakingPhoto.progress + 0.02;
    self.loginGridView.imgPhotoCover.frame = CGRectMake(0, 0, 320, self.prgTakingPhoto.progress * 200);
    [self.loginGridView setNeedsDisplay];
}
/**
 * action for taking photo button.
 * @param sender the button click.
 */
- (IBAction)takePhoto:(id)sender{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        picker.cameraViewTransform = CGAffineTransformScale(CGAffineTransformIdentity, -1, 1);
    }
    else {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    self.popover = [[UIPopoverController alloc] initWithContentViewController:picker];
    self.popover.delegate = self;
    [self.popover presentPopoverFromRect:self.btnTakePhoto.frame
                                  inView:self.btnTakePhoto.superview
                permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

/**
 * action for finish button.
 * @param sender the button click.
 */
- (IBAction)showRegisterFinishPanel:(id)sender{
    // Save image
    NSString *imagePath = [Helper saveImage2:self.loginGridView.imgTakePhoto.image];
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    UserServiceImpl *userService = appDelegate.userService;
    NSError *error;
    User *user = [userService buildUser:&error];
    if ([Helper displayError:error]) return;
    
    user.fullName = [self.txtUserName.text stringByAppendingFormat:@" %@", self.txtLastName.text];
    user.profileImage = imagePath;
    user.dailyTargetEnergy = [appDelegate.configuration objectForKey:@"DailyTargetCalories"];
    user.dailyTargetSodium = [appDelegate.configuration objectForKey:@"DailyTargetSodium"];
    user.dailyTargetFluid = [appDelegate.configuration objectForKey:@"DailyTargetFluid"];
    user.dailyTargetProtein = [appDelegate.configuration objectForKey:@"DailyTargetProtein"];
    user.dailyTargetCarb = [appDelegate.configuration objectForKey:@"DailyTargetCarbs"];
    user.dailyTargetFat = [appDelegate.configuration objectForKey:@"DailyTargetFats"];
    user.weight = [appDelegate.configuration objectForKey:@"UserWeight"];
    
    user.synchronized = @NO;
    user.admin = @NO;
    
    [userService saveUser:user error:&error];
    if ([Helper displayError:error]) return;
    selectedUserFullName = user.fullName;
    self.loginPanel.hidden = YES;
    self.registerPanel.hidden = NO;
    self.registerUserNamePanel.hidden = YES;
    self.registerPhotoPanel.hidden = YES;
    self.registerFinishPanel.hidden = NO;
}
/**
 * action for login button.
 * @param sender the button click.
 */
- (IBAction)login:(id)sender{
    self.loadingPanel.hidden = NO;
    [self performSelector:@selector(startLogin) withObject:nil afterDelay:0.0];
}

/**
 * action for login back button.
 * @param sender the button click.
 */
- (IBAction)loginBack:(id)sender{
    [self showLoginPanel:nil];
}

- (void)startLogin {
    AppDelegate *appDelegate = AppDelegate.shareDelegate;
    UserServiceImpl *userService = appDelegate.userService;
    NSError *error = nil;
    User *loggedInUser = [userService loginUser:selectedUserFullName error:&error];
    if ([Helper displayError:error]) return;
    appDelegate.loggedInUser = loggedInUser;

    [[PGCoreData instance] insertUserLock:loggedInUser];

    [appDelegate doSyncUpdateWithBlock:^(BOOL result) {
        self.loadingPanel.hidden = YES;
        [self performSegueWithIdentifier:@"Login" sender:self];
    }];

}

/**
 * action for login button.
 * @param sender the button click.
 */
- (IBAction)showHelpSetting:(id)sender{
    [self performSegueWithIdentifier:@"LoginHelpSetting" sender:self];
}

/**
 * action for list page control's page number changed.
 * @param sender the page control.
 */
- (IBAction)listPageChanged:(id)sender {
    int width = self.loginListScrollView.frame.size.width;
    int height = self.loginListScrollView.frame.size.height;
    NSInteger current = self.loginListPageControll.currentPage;
    [self.loginListScrollView scrollRectToVisible:CGRectMake(width * current, 0, width, height)
                                         animated:YES];
}

/*!
 @discussion Called when the app starts loading process.
 */
- (void)startLoading {
    self.loadingLabel.hidden = NO;
    self.loadingLabel.text = @"Loading";
    self.loadingPanel.hidden = NO;
    self.progressView.hidden = YES;
}

/*!
 @discussion Called when the app finishes loading process.
 */
- (void)finishLoading:(NSNotification *)notification {
    userLocks = [[PGCoreData instance] fetchUserLocks];

    self.loadingLabel.text = @"Loading";
    
    [self showLoginPanel:nil];
    [self getSavedUsers];
    
    self.loadingPanel.hidden = YES;
    self.loadingLabel.hidden = NO;
    self.progressView.hidden = YES;
    
    NSDictionary *params = [notification object];
    NSNumber *success = [params objectForKey:@"success"];
    if (![success boolValue]) {
        [Helper showAlert:@"Error" message:@"We are unable to sync this iPad with the central food repository. \n"
         "Don’t worry! You can still use the ISS FIT app and we will attempt to sync with the central food repository"
         " when it is available."];
    }
}

/*!
 @discussion Called when the app starts loading process.
 */
- (void)backup {
    self.progressView.backgoundImage = [UIImage imageNamed:@"bg-progress.png"];
    self.progressView.fullColor = [UIColor greenColor];
    self.progressView.progressImage = [UIImage imageNamed:@"bg-progress-red.png"];
    self.progressView.currentProgress = 0.0f;
    
    self.loadingLabel.text = @"Saving data to old server";
    self.loadingLabel.hidden = NO;
    self.loadingPanel.hidden = NO;
    self.progressView.hidden = NO;
}

/*!
 @discussion Called when the app starts loading process.
 */
- (void)loadingNew {
    self.progressView.backgoundImage = [UIImage imageNamed:@"bg-progress.png"];
    self.progressView.fullColor = [UIColor greenColor];
    self.progressView.progressImage = [UIImage imageNamed:@"bg-progress-red.png"];
    self.progressView.currentProgress = 0.0f;
    
    self.loadingLabel.text = @"Loading data, please wait a moment.";
    self.loadingLabel.hidden = NO;
    self.loadingPanel.hidden = NO;
    self.progressView.hidden = NO;
}

/*!
 @discussion Called when the loading progress is updated.
 */
- (void) updateProgress:(NSNotification *)notification {
    if (self.loadingPanel.hidden == YES) {
        return;
    }
    
    if (self.progressView.hidden) {
        self.progressView.hidden = NO;
    }
    NSDictionary *params = [notification object];
    NSNumber *progress = [params objectForKey:@"progress"];
    self.progressView.currentProgress = progress.floatValue;
}

/*!
 @discussion Prepare for segue action.
 @param segue the UIStoryboardSegue object
        sender the sender
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    CustomTabBarViewController *viewController = (CustomTabBarViewController *)segue.destinationViewController;
    if([segue.identifier isEqualToString:@"LoginHelpSetting"]){
        [viewController setHelpSettingActive];
        [viewController setAdmin:NO];
    }
    else if([segue.identifier isEqualToString:@"Login"]){
        AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        [viewController setConsumptionActive];
        [viewController setAdmin:appDelegate.loggedInUser.admin.boolValue];
    }
}

/*!
 * Show user selected login panel.
 @param btn the button.
 */
- (void)showSelectedUserPanel:(UIButton *)btn{
    selectUserIndex = btn.tag;
    User *user = (User*)[users objectAtIndex:selectUserIndex];
    selectedUserFullName = user.fullName;
    // Set the user's photo and user's full name on loginSelectedPanel
    self.imgSelectedUserImage.image = [Helper loadImage:user.profileImage];    
    if (self.imgSelectedUserImage.image == nil) {
        self.imgSelectedUserImage.image = [UIImage imageNamed:@"defaultUserIcon.png"];
    }
    NSArray *arr = [user.fullName componentsSeparatedByString:@" "];
    NSMutableString *str = [[NSMutableString alloc] init];
    if(arr.count > 0){
        [str appendString:[arr objectAtIndex:0]];
    }
    for (int i = 1; i < arr.count; i++){
        [str appendString:@"    "];
        [str appendString:[arr objectAtIndex:i]];
    }
    self.lblSelectedUsername.text = str;
    self.loginListPanel.hidden = YES;
    self.loginSelectedPanel.hidden = NO;
}
/**
 * This method will retrieve users from UserService and push photos to the scroll view..
 */
- (void)getSavedUsers{
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];    
    UserServiceImpl *userService = appDelegate.userService;
    
    NSError *error = nil;
    users = [userService filterUsers:@"" error:&error];
    if ([Helper displayError:error]) return;
    int userNumber = [users count];
    int width = self.loginListScrollView.frame.size.width;
    int height = self.loginListScrollView.frame.size.height;
    self.loginListScrollView.panGestureRecognizer.delaysTouchesBegan = self.loginListScrollView.delaysContentTouches;
    self.loginListScrollView.contentSize = CGSizeMake(width * ceil(userNumber / 3.0f), height);
    self.loginListPageControll.numberOfPages = ceil(userNumber / 3.0f);
    // clear old view
    for(UIView *v in self.loginListScrollView.subviews){
        [v removeFromSuperview];
    }
    for(int i = 0; i < userNumber; i++){
        User *user = (User *) [users objectAtIndex:i];
        int pos = (floor(i / 3.0f) * width) + 153 * (i % 3) + 10;
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(pos, 0, 128, 128)];
        img.contentMode = UIViewContentModeScaleAspectFit;
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(pos, 0, 128, 128)];
        img.tag = btn.tag = i;
        img.image = [Helper loadImage:user.profileImage];
        if (img.image == nil) {
            img.image = [UIImage imageNamed:@"defaultUserIcon.png"];
        }
        [btn setImage:[UIImage imageNamed:@"icon-photo-list-active.png"] forState:UIControlStateHighlighted];
        [self.loginListScrollView addSubview:img];
        [self.loginListScrollView addSubview:btn];
        if (![self isUserLocked:user]) {
            [btn addTarget:self action:@selector(showSelectedUserPanel:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (BOOL)isUserLocked:(User *) user {
    if (userLocks) {
        for (NSDictionary *dict in userLocks) {
            NSString *uid = [dict objectForKey:@"id"];
            if ([uid isEqualToString:user.uuid]) {
                return YES;
            }
        }
    }

    return NO;
}

#pragma mark - UIScrollView Delegate Methods
/**
 * Obtain the change in content offset from scrollView and draw the affected portion of the content view.
 * @param scrollView The scroll-view object that is performing the scrolling animation.
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    int width = self.loginListScrollView.frame.size.width;
    int current = floor(scrollView.contentOffset.x / width + 0.5);
    if(current != self.loginListPageControll.currentPage){
        self.loginListPageControll.currentPage = current;
    }
}

/*!
 * This method will be called when the picture is taken.
 * @param picker the UIImagePickerController
 * @param info the information
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.loginGridView.imgTakePhoto.image = chosenImage;
    self.loginGridView.imgTakePhoto.hidden = NO;
    self.prgTakingPhoto.hidden = YES;
    self.btnTakeCancel.hidden = NO;
    self.btnTakePhoto.hidden = YES;
    self.btnFinish.hidden = NO;
    self.btnRetakePhoto.hidden = NO;
    self.lblTakeingPhoto.hidden = YES;
    self.loginGridView.imgPhotoCover.frame = CGRectMake(0, 0, 320, 200);
    self.loginGridView.imgTakePhoto.frame = CGRectMake(70, 10, 180, 180);
    self.loginGridView.imgTakePhoto.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.loginGridView.imgTakePhoto.layer.borderWidth = 1.0f;
    [self.loginGridView setNeedsDisplay];

    [self.popover dismissPopoverAnimated:YES];
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
    if ([textField isEqual:self.txtUserName]) {
        [self.txtLastName becomeFirstResponder];
    }
    else if ([textField isEqual:self.txtLastName]) {
        [self.txtLastName resignFirstResponder];
    }
    return YES;
}

@end
