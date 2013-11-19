//
//  StringWrapper.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 7/11/13.
//  Copyright (c) 2013 tc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

//This class holds a NSString value, that is associated with other classes as set of string values.
@interface StringWrapper : NSManagedObject

//Represents string value hold in other class, like values of "origin" or "category"
@property (nonatomic, strong) NSString *value;

@end
