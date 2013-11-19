//
//  TakeLabelViewController.h
//  FoodIntakeTracker
//
//  Created by lofzcx 06/25/2013
//  Copyright (c) 2013 Topcoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TakePhotoViewController.h"
#import "Tesseract.h"

/**
 * controller for scan Label view.
 *
 * Changes in 1.1
 * - Added business logic
 *
 * @author lofzcx, flying2hk, subchap
 * @version 1.1
 * @since 1.0
 */
@interface TakeLabelViewController : TakeBaseViewController
<UISearchBarDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate> {
    /* Represents the Tesseract used in this controller. */
    Tesseract *tesseract;
}

/* the note label at bottom */
@property (weak, nonatomic) IBOutlet UILabel *lblNoteBottom;
/* the photo image */
@property (weak, nonatomic) IBOutlet UIImageView *imgPhoto;
/* the background image view */
@property (weak, nonatomic) IBOutlet UIImageView *imgBG;
/* the search bar */
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
/* the take button  */
@property (weak, nonatomic) IBOutlet UIButton *takeButton;
/* Represents the popover controller. */
@property (strong, nonatomic) UIPopoverController *popover;

/**
 * show clear label and update scan line, bracket, note label at top.
 */
- (void)showClearLabel;

/**
 * action for cancel button in progress view.
 * @param sender the button.
 */
- (IBAction)cancelProcessing:(id)sender;
@end
