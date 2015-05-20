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
//  SelectFoodCell.m
//  FoodIntakeTracker
//
//  Created by lofzcx 06/12/2013
//
//  Updated by pvmagacho on 05/14/2014
//  F2Finish - NASA iPad App Updates - Round 3
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
        self.lblName.text = self.isUnique ? self.food.name : [NSString stringWithFormat:@"%@ - %@", self.food.name,
                                                              self.food.origin];
        
        self.lblCalories.text = [NSString stringWithFormat:@"%@", self.food.energy];
        self.lblSodium.text = [NSString stringWithFormat:@"%@", self.food.sodium];
        self.lblFluid.text = [numberFormatter stringFromNumber:self.food.fluid];
        self.lblProtein.text = [NSString stringWithFormat:@"%@", self.food.protein];
        self.lblCarb.text = [NSString stringWithFormat:@"%@", self.food.carb];
        self.lblFat.text = [numberFormatter stringFromNumber:self.food.fat];
    } else {
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
    
    CGRect frame = self.lblName.frame;
    frame.size.width = 340 - frame.origin.x;
    self.lblName.frame = frame;
    
    // update nutrient view size and position in different mode.
    if(self.viewCaloriesOnly && rect.size.width == 454){
        nutrientFrame = CGRectMake(340, 0, 285, 54);
        self.viewFluid.hidden = YES;
        self.viewSodium.hidden = YES;
        self.viewCalories.hidden = NO;
        self.viewProtein.hidden = YES;
        self.viewCarb.hidden = YES;
        self.viewFat.hidden = YES;
    }
    else if(self.viewSodiumOnly && rect.size.width == 454){
        nutrientFrame = CGRectMake(340 - 96, 0, 285, 54);
        self.viewFluid.hidden = YES;
        self.viewSodium.hidden = NO;
        self.viewCalories.hidden = YES;
        self.viewProtein.hidden = YES;
        self.viewCarb.hidden = YES;
        self.viewFat.hidden = YES;
    }
    else if(self.viewFluidOnly && rect.size.width == 454){
        nutrientFrame = CGRectMake(340 - 96 * 2, 0, 285, 54);
        self.viewFluid.hidden = NO;
        self.viewSodium.hidden = YES;
        self.viewCalories.hidden = YES;
        self.viewProtein.hidden = YES;
        self.viewCarb.hidden = YES;
        self.viewFat.hidden = YES;
    }
    else if(self.viewProteinOnly && rect.size.width == 454){
        [self.scrollView scrollRectToVisible:CGRectMake(569, 0, 1, 1) animated:NO];
        nutrientFrame = CGRectMake(340, 0, 285, 54);
        self.viewFluid.hidden = YES;
        self.viewSodium.hidden = YES;
        self.viewCalories.hidden = YES;
        self.viewProtein.hidden = NO;
        self.viewCarb.hidden = YES;
        self.viewFat.hidden = YES;
    }
    else if(self.viewCarbOnly && rect.size.width == 454){
        [self.scrollView scrollRectToVisible:CGRectMake(569, 0, 1, 1) animated:NO];
        nutrientFrame = CGRectMake(340 - 96, 0, 285, 54);
        self.viewFluid.hidden = YES;
        self.viewSodium.hidden = YES;
        self.viewCalories.hidden = YES;
        self.viewProtein.hidden = YES;
        self.viewCarb.hidden = NO;
        self.viewFat.hidden = YES;
    }
    else if(self.viewFatOnly && rect.size.width == 454){
        [self.scrollView scrollRectToVisible:CGRectMake(569, 0, 1, 1) animated:NO];
        nutrientFrame = CGRectMake(340 - 96 * 2, 0, 285, 54);
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
        
        CGRect frame = self.lblName.frame;
        frame.size.width = 290 - frame.origin.x;
        self.lblName.frame = frame;
    };
    
    if(rect.size.width > 454){
        [self.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        self.scrollView.userInteractionEnabled = YES;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        self.scrollView.frame = CGRectMake(285, 0, 285, 54);
        [UIView commitAnimations];
    }
    else{
        self.scrollView.userInteractionEnabled = NO;
        if(self.scrollView.frame.origin.x == 285){
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
