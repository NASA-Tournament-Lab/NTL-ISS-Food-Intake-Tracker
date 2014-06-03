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
//  VoiceSearchViewController.h
//  FoodIntakeTracker
//
//  Created by lofzcx 06/12/2013
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import <OpenEars/PocketsphinxController.h>
#import <OpenEars/OpenEarsEventsObserver.h>

#import "ConsumptionViewController.h"

/**
 * @class VoiceSearchViewController
 * controller for voice search view.
 *
 * Changes in 1.1
 * - Added business logic
 *
 * @author lofzcx, flying2hk, subchap
 * @version 1.1
 * @since 1.0
 */
@interface VoiceSearchViewController : UIViewController <OpenEarsEventsObserverDelegate> {
    /* Represents the OpenEarsEventsObserver used in this controller. */
    OpenEarsEventsObserver *openEarsEventsObserver;

    /* Represents the PocketsphinxController used in this controller. */
    PocketsphinxController *pocketsphinxController;
}

/* sub title label */
@property (weak, nonatomic) ConsumptionViewController *consumptionViewController;
/* sub title label */
@property (weak, nonatomic) IBOutlet UILabel *lblSubTitle;
/* title label */
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
/* cancel button */
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
/* done button */
@property (weak, nonatomic) IBOutlet UIButton *btnDone;
/* re do search button */
@property (weak, nonatomic) IBOutlet UIButton *btnSearchAgain;
/* result view */
@property (weak, nonatomic) IBOutlet UIView *resultView;
/* add to consumption button */
@property (weak, nonatomic) IBOutlet UIButton *btnAddToConsumption;
/* the scroll view contains the result */
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
/* speak button */
@property (weak, nonatomic) IBOutlet UIButton *btnSpeak;

/* the selected food products arrray */
@property (strong, nonatomic) NSMutableArray *selectedFoodProducts;
/* the search results */
@property (strong, nonatomic) NSMutableArray *searchResult;
/* results label */
@property (weak, nonatomic) IBOutlet UILabel *resultsLabel;
/* no results message label */
@property (weak, nonatomic) IBOutlet UILabel *noResultsMessageLabel;
/* the top divider */
@property (weak, nonatomic) IBOutlet UIView *topDivider;

/**
 * action for clicking at photo.
 * @param btn the button.
 */
- (void)clickPhoto:(UIButton *)btn;

/**
 * build grid photo list and make it visible.
 */
- (void)showResult;

/**
 * handle action for redo button.
 * @param sender the button.
 */
- (IBAction)redoSearch:(id)sender;

/**
 * handle action for analyze.
 * @param sender the button.
 */
- (IBAction)Analyze:(id)sender;
@end
