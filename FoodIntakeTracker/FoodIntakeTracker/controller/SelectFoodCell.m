//
//  SelectFoodCell.m
//  FoodIntakeTracker
//
//  Created by lofzcx 06/12/2013
//  Copyright (c) 2013 Topcoder. All rights reserved.
//

#import "SelectFoodCell.h"

@implementation SelectFoodCell

/**
 * overwrite this method to manage view contents in the view.
 * @param rect the cell's frame size.
 */
- (void)drawRect:(CGRect)rect{
    if(self.food){
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];        
        self.lblName.text = self.food.name;
        
        self.lblCalories.text = [NSString stringWithFormat:@"%@", self.food.energy];
        self.lblSodium.text = [NSString stringWithFormat:@"%@", self.food.sodium];
        self.lblFluid.text = [numberFormatter stringFromNumber:self.food.fluid];
        self.lblProtein.text = [NSString stringWithFormat:@"%@", self.food.protein];
        self.lblCarb.text = [NSString stringWithFormat:@"%@", self.food.carb];
        self.lblFat.text = [numberFormatter stringFromNumber:self.food.fat];
    }
    else{
        self.lblName.text = @"";        
        self.lblCalories.text = @"";
        self.lblSodium.text = @"";
        self.lblFluid.text = @"";
        self.lblProtein.text = @"";
        self.lblCarb.text = @"";
        self.lblFat.text = @"";
        
    }
    self.line.frame = CGRectMake(14, rect.size.height - 1, rect.size.width - 26, 1);
    self.scrollView.contentSize = CGSizeMake(570, 54);
    [self.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    CGRect nutrientFrame;
    
    // update nutrient view size and position in different mode.
    if(self.viewCaloriesOnly && rect.size.width == 454){
        nutrientFrame = CGRectMake(240, 0, 285, 54);
        self.viewFluid.hidden = YES;
        self.viewSodium.hidden = YES;
        self.viewCalories.hidden = NO;
        self.viewProtein.hidden = YES;
        self.viewCarb.hidden = YES;
        self.viewFat.hidden = YES;
    }
    else if(self.viewSodiumOnly && rect.size.width == 454){
        nutrientFrame = CGRectMake(240 - 96, 0, 285, 54);
        self.viewFluid.hidden = YES;
        self.viewSodium.hidden = NO;
        self.viewCalories.hidden = YES;
        self.viewProtein.hidden = YES;
        self.viewCarb.hidden = YES;
        self.viewFat.hidden = YES;
    }
    else if(self.viewFluidOnly && rect.size.width == 454){
        nutrientFrame = CGRectMake(240 - 96 * 2, 0, 285, 54);
        self.viewFluid.hidden = NO;
        self.viewSodium.hidden = YES;
        self.viewCalories.hidden = YES;
        self.viewProtein.hidden = YES;
        self.viewCarb.hidden = YES;
        self.viewFat.hidden = YES;
    }
    else if(self.viewProteinOnly && rect.size.width == 454){
        [self.scrollView scrollRectToVisible:CGRectMake(569, 0, 1, 1) animated:NO];
        nutrientFrame = CGRectMake(240, 0, 285, 54);
        self.viewFluid.hidden = YES;
        self.viewSodium.hidden = YES;
        self.viewCalories.hidden = YES;
        self.viewProtein.hidden = NO;
        self.viewCarb.hidden = YES;
        self.viewFat.hidden = YES;
    }
    else if(self.viewCarbOnly && rect.size.width == 454){
        [self.scrollView scrollRectToVisible:CGRectMake(569, 0, 1, 1) animated:NO];
        nutrientFrame = CGRectMake(240 - 96, 0, 285, 54);
        self.viewFluid.hidden = YES;
        self.viewSodium.hidden = YES;
        self.viewCalories.hidden = YES;
        self.viewProtein.hidden = YES;
        self.viewCarb.hidden = NO;
        self.viewFat.hidden = YES;
    }
    else if(self.viewFatOnly && rect.size.width == 454){
        [self.scrollView scrollRectToVisible:CGRectMake(569, 0, 1, 1) animated:NO];
        nutrientFrame = CGRectMake(240 - 96 * 2, 0, 285, 54);
        self.viewFluid.hidden = YES;
        self.viewSodium.hidden = YES;
        self.viewCalories.hidden = YES;
        self.viewProtein.hidden = YES;
        self.viewCarb.hidden = YES;
        self.viewFat.hidden = NO;
    }
    else{
        nutrientFrame = CGRectMake(436, 0, 285, 54);
        self.viewFluid.hidden = NO;
        self.viewSodium.hidden = NO;
        self.viewCalories.hidden = NO;
        self.viewProtein.hidden = NO;
        self.viewCarb.hidden = NO;
        self.viewFat.hidden = NO;
    };
    
    if(rect.size.width > 454){
        [self.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        self.scrollView.userInteractionEnabled = YES;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        self.scrollView.frame = CGRectMake(245, 0, 285, 54);
        [UIView commitAnimations];
    }
    else{
        self.scrollView.userInteractionEnabled = NO;
        if(self.scrollView.frame.origin.x == 245){
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.5];
            self.scrollView.frame = nutrientFrame;
            [UIView commitAnimations];
        }
        else{
            self.scrollView.frame = nutrientFrame;
        }
    }
}
@end
