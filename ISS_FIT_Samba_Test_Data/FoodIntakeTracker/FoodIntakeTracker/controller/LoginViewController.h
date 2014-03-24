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
//  LoginViewController.h
//  FoodIntakeTracker
//
//  Created by lofzcx 06/12/2013
//

#import <UIKit/UIKit.h>
#import "ConsumptionViewController.h"

/**
 * @class LoginGridView
 * Use to draw grid view in register view.
 *
 * @version 1.0
 * @author lofzcx, flying2hk, subchap
 */
@interface LoginGridView : UIView

/* the photo view */
@property (weak, nonatomic) IBOutlet UIImageView *imgTakePhoto;
/* the cover view */
@property (weak, nonatomic) IBOutlet UIView *imgPhotoCover;
@end

/**
 * @class LoginViewController
 * View controller for Login Register view.
 *
 * Changes in 1.1
 * - add checking for user's role (Admin or not)
 *
 * Changes in 1.2
 * - Added business logic
 *
 * @author lofzcx, flying2hk, subchap
 * @version 1.2
 * @since 1.0
 */
@interface LoginViewController : UIViewController
<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate, UITextFieldDelegate> {
    /* Represents the users corresponding to the user photos displayed on login view. */
    NSArray *users;
    
    /* Represents the full name of the selected user. */
    NSString *selectedUserFullName;
}

/* the title label of login screen */
@property (weak, nonatomic) IBOutlet UILabel *lblLoginScreenTitle;

/* the login panel view */
@property (weak, nonatomic) IBOutlet UIView *loginPanel;
/* title label for login panel */
@property (weak, nonatomic) IBOutlet UILabel *lblLoginPanelTitle;
/* login list panel */
@property (weak, nonatomic) IBOutlet UIView *loginListPanel;
/* scroll view of login list panel */
@property (weak, nonatomic) IBOutlet UIScrollView *loginListScrollView;
/* page controll of login list panel */
@property (weak, nonatomic) IBOutlet UIPageControl *loginListPageControll;
/* login selected panel */
@property (weak, nonatomic) IBOutlet UIView *loginSelectedPanel;
/* login panel selected username label */
@property (weak, nonatomic) IBOutlet UILabel *lblSelectedUsername;
/* login panel selected username image */
@property (weak, nonatomic) IBOutlet UIImageView *imgSelectedUserImage;

/* register panel view of login screen */
@property (weak, nonatomic) IBOutlet UIView *registerPanel;
/* title label of register title */
@property (weak, nonatomic) IBOutlet UILabel *lblRegisterPanelTitle;

/* the UserName password panel of register panel */
@property (weak, nonatomic) IBOutlet UIView *registerUserNamePanel;
/* the username textfield of register panel */
@property (weak, nonatomic) IBOutlet UITextField *txtUserName;
/* the password textfield of register panel */
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;


/* the take photo panel of register panel */
@property (weak, nonatomic) IBOutlet UIView *registerPhotoPanel;
/* the progress bar of taking photo */
@property (weak, nonatomic) IBOutlet UILabel *lblTakeingPhoto;
@property (weak, nonatomic) IBOutlet UIProgressView *prgTakingPhoto;
/* cancel button in taking photo panel */
@property (weak, nonatomic) IBOutlet UIButton *btnTakeCancel;
/* take photo button in taking photo panel */
@property (weak, nonatomic) IBOutlet UIButton *btnTakePhoto;
/* retake photo button in taking photo panel */
@property (weak, nonatomic) IBOutlet UIButton *btnRetakePhoto;
/* finish button in taking photo panel */
@property (weak, nonatomic) IBOutlet UIButton *btnFinish;
@property (weak, nonatomic) IBOutlet LoginGridView *loginGridView;

/* register finish panel */
@property (weak, nonatomic) IBOutlet UIView *registerFinishPanel;
/* login now button */
@property (weak, nonatomic) IBOutlet UIButton *btnLoginNow;
/* loading panel */
@property (weak, nonatomic) IBOutlet UIView *loadingPanel;
/* loading label */
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
/* progress view */
@property (weak, nonatomic) IBOutlet CustomProgressView *progressView;

/* Represents the popover controller. */
@property (strong, nonatomic) UIPopoverController *popover;

/**
 * action for register button. Show the register panel.
 */
- (IBAction)showRegister;
/**
 * showing login panel. Action for cancel button in register username panel.
 * @param sender the button click.
 */
- (IBAction)showLoginPanel:(id)sender;
/**
 * action for next button in register username panel.
 * @param sender the button click.
 */
- (IBAction)showRegisterPhotoPanel:(id)sender;
/**
 * action for taking photo button.
 * @param sender the button click.
 */
- (IBAction)takePhoto:(id)sender;
/**
 * action for finish button.
 * @param sender the button click.
 */
- (IBAction)showRegisterFinishPanel:(id)sender;
/**
 * action for login button.
 * @param sender the button click.
 */
- (IBAction)login:(id)sender;
/**
 * action for login button.
 * @param sender the button click.
 */
- (IBAction)showHelpSetting:(id)sender;

/**
 * action for list page control's page number changed.
 * @param sender the page control.
 */
- (IBAction)listPageChanged:(id)sender;
@end
