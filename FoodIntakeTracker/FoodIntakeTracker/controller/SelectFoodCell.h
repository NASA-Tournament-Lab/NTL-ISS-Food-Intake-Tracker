//
//  SelectFoodCell.h
//  FoodIntakeTracker
//
//  Created by lofzcx 06/12/2013
//  Copyright (c) 2013 Topcoder. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Food;

/**
 * @class SelectFoodCell
 * cell for table view in select consumption view.
 * 
 * Changes in 1.1
 * - Added business logic
 *
 * @author lofzcx, flying2hk, subchap
 * @version 1.1
 * @since 1.0
 */
@interface SelectFoodCell : UITableViewCell


/* the check box button */
@property (weak, nonatomic) IBOutlet UIButton *btnCheck;
/* the cell button */
@property (weak, nonatomic) IBOutlet UIButton *cellButton;
/* the name label */
@property (weak, nonatomic) IBOutlet UILabel *lblName;
/* the quantity label */
@property (weak, nonatomic) IBOutlet UILabel *lblQuantity;
/* the quantity unit label */
@property (weak, nonatomic) IBOutlet UILabel *lblQuantityUnit;
/* the calories value label */
@property (weak, nonatomic) IBOutlet UILabel *lblCalories;
/* the sodium value label */
@property (weak, nonatomic) IBOutlet UILabel *lblSodium;
/* the fluid value label */
@property (weak, nonatomic) IBOutlet UILabel *lblFluid;
/* the protein value label */
@property (weak, nonatomic) IBOutlet UILabel *lblProtein;
/* the carb value label */
@property (weak, nonatomic) IBOutlet UILabel *lblCarb;
/* the fat value label */
@property (weak, nonatomic) IBOutlet UILabel *lblFat;
/* the nutrient view */
@property (weak, nonatomic) IBOutlet UIView *nutrientView;

/* the bottom line */
@property (weak, nonatomic) IBOutlet UIImageView *line;

/* the scroll view */
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

/* the calories view */
@property (weak, nonatomic) IBOutlet UIView *viewCalories;
/* the sodium view */
@property (weak, nonatomic) IBOutlet UIView *viewSodium;
/* the fluid view */
@property (weak, nonatomic) IBOutlet UIView *viewFluid;
/* the protein view */
@property (weak, nonatomic) IBOutlet UIView *viewProtein;
/* the carb view */
@property (weak, nonatomic) IBOutlet UIView *viewCarb;
/* the fat view */
@property (weak, nonatomic) IBOutlet UIView *viewFat;

/* is only calories view visible */
@property (unsafe_unretained, nonatomic) BOOL viewCaloriesOnly;
/* is only sodium view visible */
@property (unsafe_unretained, nonatomic) BOOL viewSodiumOnly;
/* is only fluid view visible */
@property (unsafe_unretained, nonatomic) BOOL viewFluidOnly;
/* is only protein view visible */
@property (unsafe_unretained, nonatomic) BOOL viewProteinOnly;
/* is only carb view visible */
@property (unsafe_unretained, nonatomic) BOOL viewCarbOnly;
/* is only fat view visible */
@property (unsafe_unretained, nonatomic) BOOL viewFatOnly;

/* the food item */
@property (weak, nonatomic) FoodProduct *food;
@end
