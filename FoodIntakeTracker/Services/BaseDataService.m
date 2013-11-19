//
//  BaseDataService.m
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 2013-07-10.
//  Copyright (c) 2013 TopCoder. All rights reserved.
//

#import "BaseDataService.h"
#import "DBHelper.h"

@interface BaseDataService ()

@end


@implementation BaseDataService

- (NSManagedObjectContext *) managedObjectContext {
    NSManagedObjectContext *moc = [DBHelper currentThreadMoc];
    if(! moc.undoManager)
        [moc setUndoManager:[[NSUndoManager alloc] init]];
    
    return moc;
}

/*!
 @discussion Discards all previous changes in undo stack in managed object context, 
    and start a new undo group. All changes made after this method can be undo.
 */
- (void)startUndoActions
{
    [self.managedObjectContext processPendingChanges];
    [[self.managedObjectContext undoManager] beginUndoGrouping];
}

/*!
 @discussion Undo all changes in undo stack in managed object context. The undo stack will be empty at the same time.
 */
- (void)undo
{
    [self.managedObjectContext processPendingChanges];
    [[self.managedObjectContext undoManager] endUndoGrouping];
    [[self.managedObjectContext undoManager] undoNestedGroup];
}

/*!
 @discussion This method will discard all changes in undo statck.
 */
- (void)endUndoActions
{
    [self.managedObjectContext processPendingChanges];
    [[self.managedObjectContext undoManager] endUndoGrouping];
    [[self.managedObjectContext undoManager] removeAllActions];
}

@end
