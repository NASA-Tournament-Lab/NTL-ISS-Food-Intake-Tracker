//
//  SummaryGenerationHistory.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 7/12/13.
//  Copyright (c) 2013 tc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SynchronizableModel.h"

@class User;

//This represents a FoodConsumptionRecord summary generation history record.
@interface SummaryGenerationHistory : SynchronizableModel

//Represents the end date of the summary.
@property (nonatomic, strong) NSDate * endDate;

//Represents the start date of the summary.
@property (nonatomic, strong) NSDate * startDate;

//Represents the user for whom the summary was generated.
@property (nonatomic, strong) User *user;

@end
