//
//  DBHelper.h
//  Hercules Personal Content DVR
//
//  Created by namanhams on 3/9/13.
//  Copyright (c) 2013 TopCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @version 1.0
 @discussion This class implements the CoreData layer
            Here, asset indicates the Asset object in CoreData, not ALAsset
 @author namanhams
 */

@interface DBHelper : NSObject

// Call this method to access the NSManagedObjectContext of current thread. NSManagedObjectContext is not thread-safe
// so each thread owns a separate NSManagedObjectContext
+ (NSManagedObjectContext *) currentThreadMoc;

// Save the db
+ (void) saveMoc;

@end
