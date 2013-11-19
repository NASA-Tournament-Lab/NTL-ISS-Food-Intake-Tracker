//
//  ManageUserProfileViewController.h
//  FoodIntakeTracker
//
//  Created by lofzcx 06/25/2013
//  Copyright (c) 2013 Topcoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTabBarViewController.h"
#import "CustomTableViewController.h"

/**
 * @class ManageUserProfileViewController
 * controller for manage user profile view.
 *
 * Changes in 1.1
 * - Added business logic
 *
 * @author lofzcx, flying2hk, subchap
 * @version 1.1
 * @since 1.0
 */
@interface ManageUserProfileViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UINavigationControllerDelegate,
UIImagePickerControllerDelegate, UIPopoverControllerDelegate, CustomTableViewDelegate, UITextFieldDelegate>

/* the tab bar controller */
@property (weak, nonatomic) CustomTabBarViewController *customTabBarController;
/* the profile and photo segment control */
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
/* the left label for segment control */
@property (weak, nonatomic) IBOutlet UILabel *lblSegLeftTitle;
/* the right label for segment control */
@property (weak, nonatomic) IBOutlet UILabel *lblSegRightTitle;
/* the head title label */
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
/* the selected User name label*/
@property (weak, nonatomic) IBOutlet UILabel *lblSelectedUserName;
/* the selected user photo image view */
@property (weak, nonatomic) IBOutlet UIImageView *imgSelectedUserPhoto;
/* the search bar */
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
/* the user list table */
@property (weak, nonatomic) IBOutlet UITableView *userListTable;
/* the left part of the view */
@property (weak, nonatomic) IBOutlet UIView *leftView;

/* the profile view */
@property (weak, nonatomic) IBOutlet UIView *profileView;
/* the profile image view */
@property (weak, nonatomic) IBOutlet UIImageView *imgProfilePhoto;
/* the profile table */
@property (weak, nonatomic) IBOutlet UIView *profileTable;
/* the firstname label */
@property (weak, nonatomic) IBOutlet UILabel *lblProfileFirstName;
/* the lastname label */
@property (weak, nonatomic) IBOutlet UILabel *lblProfileLastName;
/* the fristname text input */
@property (weak, nonatomic) IBOutlet UITextField *txtFirstName;
/* the lastname text input */
@property (weak, nonatomic) IBOutlet UITextField *txtLastName;
/* the update and save button */
@property (weak, nonatomic) IBOutlet UIButton *btnUpdateSave;
/* the delete button */
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;
/* the cancel button */
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
/* the take photo button */
@property (weak, nonatomic) IBOutlet UIButton *btnTakePhoto;

@property (weak, nonatomic) IBOutlet UIView *profileDeletedNoteView;
@property (weak, nonatomic) IBOutlet UIView *deletePopupView;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;
@property (weak, nonatomic) IBOutlet UIView *rightView;
/* Represents the popover controller. */
@property (strong, nonatomic) UIPopoverController *popover;
/* the select index of user list table */
@property (assign, nonatomic) int selectIndex;
/* the suggestion table view */
@property (strong, nonatomic) SuggestionTableView *suggestionTableView;

/**
 * set the border for image view.
 * @param img the image view that are setted.
 */
- (void)setImageBorder:(UIImageView *)img;
/**
 * set the conner radius and border for view.
 * @param v the view that are setted.
 */
- (void)setTableBorder:(UIView *)v;
/**
 * show the profile preview view
 */
- (void)showPreviewProfile;
/**
 * show the profile edit view.
 */
- (void)showEditProfile;
/**
 * show the photo preview view.
 */
- (void)showPhotoPreview;
/**
 * change between profile and photo view.
 * @param sender the segment control.
 */
- (IBAction)segmentValueChanged:(id)sender;
/**
 * action for cancel button click.
 * @param sender the button.
 */
- (IBAction)cancelEditing:(id)sender;
/**
 * action for delete button.
 * @param sender the button.
 */
- (IBAction)deleteProfile:(id)sender;
/**
 * actoin for update and save button.
 * @param sender the button.
 */
- (IBAction)saveUpdateProfile:(id)sender;
/**
 * return back to summary view.
 * @param sender the button.
 */
- (IBAction)viewSummary:(id)sender;
/**
 * hide the delete confirm view view.
 * @param sender the button.
 */
- (IBAction)hideDeletePopup:(id)sender;
/**
 * show the delete confirm view view.
 * @param sender the button.
 */
- (IBAction)showDeletePopup:(id)sender;
@end
