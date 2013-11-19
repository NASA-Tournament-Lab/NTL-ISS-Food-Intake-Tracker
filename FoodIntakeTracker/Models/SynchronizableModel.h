//
//  SynchronizableModel.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 7/12/13.
//  Copyright (c) 2013 tc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

//This is the base class for model classes which can be synchronized between iPad devices.
@interface SynchronizableModel : NSManagedObject

//Represents the created date.
@property (nonatomic, strong) NSDate * createdDate;

//Indicates whether the model object is deleted. Note that this is used to flag the object is deleted and this flag is
//mainly used to instruct SynchronizationService to notify other iPad devices of this deletion. And
//SynchronizationService will physically delete this object from Core Data persistence once it synchronizes this
//deletion to other iPad devices.
@property (nonatomic, strong) NSNumber * deleted;

//Represents the last modified date.
@property (nonatomic, strong) NSDate * lastModifiedDate;

//Indicates whether the changes of the data model have been synchronized. Each time the data is modified, this property will be changed to NO, and once the changes are synchronized to Shared File Server it will be updated to YES.
@property (nonatomic, strong) NSNumber * synchronized;

@end
