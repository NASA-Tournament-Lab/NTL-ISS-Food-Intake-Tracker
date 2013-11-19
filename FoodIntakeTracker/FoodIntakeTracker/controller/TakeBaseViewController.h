//
//  TakeBaseViewController.h
//  FoodIntakeTracker
//
//  Created by lofzcx 06/25/2013
//  Copyright (c) 2013 Topcoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTabBarViewController.h"
#import "ConsumptionViewController.h"

/**
 * @class TakeBaseViewController
 * base controller for Take Photo, Scan Label, Scan Barcode controller.
 * bind common view here.
 *
 * Changes in 1.1
 * - Added business logic
 *
 * @author lofzcx, flying2hk, subchap
 * @version 1.1
 * @since 1.0
 */
@interface TakeBaseViewController : UIViewController{
    /* the update progress timer */
    NSTimer *updateProcessTimer;
    /* the photo image view */
    UIImageView *photoImage;
    /* the clear background layer */
    UIView *clearCover;
    /* is performing animation or not */
    BOOL isAnimation;
    /* the result foods */
    NSMutableArray *resultFoods;
    /* the selected foods */
    NSMutableArray *selectFoods;
    /* the analyzed Food */
    Food *analyzeFood;
    /* Represents ConsumptionViewController.*/
    ConsumptionViewController *consumptionViewController;
}

/* the tab bar controller */
@property (weak, nonatomic) CustomTabBarViewController *customTabBarController;

/* the footer view */
@property (weak, nonatomic) IBOutlet UIView *footer;
/* the title for take button */
@property (weak, nonatomic) IBOutlet UILabel *lblTakeButtonTitle;
/* the take button */
@property (weak, nonatomic) IBOutlet UIButton *btnTake;
/* the show all button */
@property (weak, nonatomic) IBOutlet UIButton *btnShowAll;
/* the cancel button */
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
/* the showing results button */
@property (weak, nonatomic) IBOutlet UIButton *btnResults;
/* the preview */
@property (weak, nonatomic) IBOutlet UIView *preview;
/* the centering image view */
@property (weak, nonatomic) IBOutlet UIImageView *imgCenter;
/* the add to consumption button in footer view */
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;

/* the processing view */
@property (weak, nonatomic) IBOutlet UIView *processView;
/* the processing title label */
@property (weak, nonatomic) IBOutlet UILabel *lblProcessTitle;
/* the processing progress view */
@property (weak, nonatomic) IBOutlet UIProgressView *prgProcess;
/* the cancel processing button */
@property (weak, nonatomic) IBOutlet UIButton *btnProcessCancel;

/* the result view */
@property (weak, nonatomic) IBOutlet UIView *resultView;
/* the title label in result view */
@property (weak, nonatomic) IBOutlet UILabel *lblResultTitle;
/* the add to consumption button in result view */
@property (weak, nonatomic) IBOutlet UIButton *btnResultAdd;
/* the food name label */
@property (weak, nonatomic) IBOutlet UILabel *lblFoodName;
/* the food category label */
@property (weak, nonatomic) IBOutlet UILabel *lblFoodCategory;
/* the calories label */
@property (weak, nonatomic) IBOutlet UILabel *lblCalories;
/* the sodium label */
@property (weak, nonatomic) IBOutlet UILabel *lblSodium;
/* the fluid label */
@property (weak, nonatomic) IBOutlet UILabel *lblFluid;
/* the protein label */
@property (weak, nonatomic) IBOutlet UILabel *lblProtein;
/* the carb label */
@property (weak, nonatomic) IBOutlet UILabel *lblCarb;
/* the fat label */
@property (weak, nonatomic) IBOutlet UILabel *lblFat;
/* the image view of food */
@property (weak, nonatomic) IBOutlet UIImageView *imgFood;
/* the view contains reuslt */
@property (weak, nonatomic) IBOutlet UIView *resultTableView;
/* the scroll view */
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
/* the food name text input */
@property (weak, nonatomic) IBOutlet UITextField *txtFoodName;
/* the food added popup view */
@property (weak, nonatomic) IBOutlet UIView *foodAddedPopup;
/* the title label food added popup view */
@property (weak, nonatomic) IBOutlet UILabel *lblFoodAddedTitile;

/* the results view */
@property (weak, nonatomic) IBOutlet UIView *resultsView;
/* the scroll view contents results photos */
@property (weak, nonatomic) IBOutlet UIScrollView *resultsContentScrollView;


/**
 * click food photo in the grid view.
 * @param btn the button.
 */
- (void)clickPhoto:(UIButton *)btn;

/**
 * fill the content of foods according got foods.
 */
- (void)buildResults;

/**
 * action for take button click.
 * Leave empty for base class.
 * @param sender the button.
 */
- (IBAction)take:(id)sender;

/**
 * return back to summary view.
 * @param sender the button.
 */
- (IBAction)viewSummary:(id)sender;

/**
 * action for take another button in result panel click.
 * Leave empty for base class.
 * @param sender the button.
 */
- (IBAction)takeAnotherPhoto:(id)sender;
/**
 * action for add to consumption button click.
 * Leave empty for base class.
 * @param sender the button.
 */
- (IBAction)addToConsumption:(id)sender;
/**
 * show the results panel.
 * @param sender the button.
 */
- (IBAction)showResults:(id)sender;

/**
 * This method will add selected foods to consumption.
 */
- (void)addSelectedFoodsToConsumption;

@end
