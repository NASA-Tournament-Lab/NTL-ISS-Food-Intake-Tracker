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
//  BaseDataService.m
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 2013-07-10.
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
