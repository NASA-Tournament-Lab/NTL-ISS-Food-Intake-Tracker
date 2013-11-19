//
//  BaseDataService.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 2013-07-10.
//  Copyright (c) 2013 TopCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @class BaseDataService
 @discussion Base class for data services. This base class holds a reference to CoreData's NSManagedObjectContext that s
 ubclasses can make use of.
 @author flying2hk, duxiaoyang, LokiYang
 @version 1.1
 @changes from 1.0
    1. Add undo support.
 */
@interface BaseDataService : NSObject

/*!
 @discussion Get the NSManagedObjectContext reference held by this object.
 @return The NSManagedObjectContext.
 */
- (NSManagedObjectContext *)managedObjectContext;

/*!
 @discussion Discards all previous changes in undo stack in managed object context,
 and start a new undo group. All changes made after this method can be undo.
 */
- (void)startUndoActions;

/*!
 @discussion Undo all changes in undo stack in managed object context. The undo stack will be empty at the same time.
 */
- (void)undo;

/*!
 @discussion This method will discard all changes in undo statck.
 */
- (void)endUndoActions;

@end
