//
//  TakeBarcodeViewController.h
//  FoodIntakeTracker
//
//  Created by lofzcx 06/25/2013
//  Copyright (c) 2013 Topcoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TakePhotoViewController.h"
#import "ZXingWidgetController.h"

/**
 * controller for scan barcode view.
 *
 * Changes in 1.1
 * - Added business logic
 *
 * @author lofzcx, flying2hk, subchap
 * @version 1.1
 * @since 1.0
 */
@interface TakeBarcodeViewController : TakeBaseViewController<UISearchBarDelegate, ZXingDelegate>

/* the note label at top */
@property (weak, nonatomic) IBOutlet UILabel *lblNoteTop;
/* the note label at bottom */
@property (weak, nonatomic) IBOutlet UILabel *lblNoteBottom;
/* the photo image */
@property (weak, nonatomic) IBOutlet UIImageView *imgPhoto;
/* the background image view */
@property (weak, nonatomic) IBOutlet UIImageView *imgBG;
/* the scan line image view */
@property (weak, nonatomic) IBOutlet UIImageView *scanLine;
/* the bracket image view */
@property (weak, nonatomic) IBOutlet UIImageView *imgBracket;
/* the search bar */
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

/**
 * show clear Barcode and update scan line, bracket, note label at top.
 */
- (void)showClearBarcode;

/**
 * action for cancel button in progress view.
 * @param sender the button.
 */
- (IBAction)cancelProcessing:(id)sender;

@end
