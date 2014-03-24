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
//  DBHelper.h
//  Hercules Personal Content DVR
//
//  Created by namanhams on 3/9/13.
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
