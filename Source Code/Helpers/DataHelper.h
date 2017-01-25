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
//  DataHelper.h
//  ISSFoodIntakeTracker
//
//  Created by LokiYang on 8/5/13.
//

#import <Foundation/Foundation.h>
#import "Models.h"

/*!
 @class DataHelper
 @discussion This class is a helper class used for managing data.
 
 @ Changes in 1.1
   Added support for protein/carb/fat

 @author LokiYang, subchap
 @version 1.1
 @since 1.0
 */
@interface DataHelper : NSObject

/*!
 @discussion It will convert the NSString to a NSSet with managed objects. 
        The string is separated by the separator.
 @param str The string.
 @param entity The managed object's entity description.
 @param context The entity's context.
 @param separator The separator used to split the string.
 @return The NSSet with manged objects.
 */
+ (NSSet *)convertNSStringToNSSet:(NSString *)str withEntityDescription:(NSEntityDescription *)entity
           inManagedObjectContext:(NSManagedObjectContext*)context withSeparator:(NSString *)separator;


/*!
 @discussion This method will convert the NSSet of StringWrapper to NSString by using the separator.
 @param set The NSSet.
 @param separator The separator used to join StringWrapper in NSString.
 @return The NSString with joined StringWrapper.
 */
+ (NSString *)convertStringWrapperNSSetToNSString:(NSSet *)set withSeparator:(NSString *)separator;

/*!
 @discussion This method will build a FoodProductSortOption from string.
 @param str The string representation of FoodProductSortOption
 @return The FoodProductSortOption enum
 */
+ (FoodProductSortOption)buildFoodProductSortOptionFromString:(NSString *)str;

/*!
 @discussion This method will format a FoodProductSortOption to string.
 @param The NSNumber stores FoodProductSortOption enum
 @return str The string representation of FoodProductSortOption
 */
+ (NSString*)formatFoodProductSortOptionToString:(NSNumber *)sortOption;

/*!
 @discussion This method will get the LocalFileSystemDirectory absolute directory in "Document" folder.
 @return The absolute directory of the LocalFileSystemDirectory. 
 */
+ (NSString *)getAbsoulteLocalDirectory:(NSString *)localDirectory;

/*!
 @discussion This method will sort the array by the id of the object.
 @param array The NSArray with the objects
 @return the sorted array
 */
+ (NSArray *)orderByDate:(NSArray *)array;

+ (BOOL)updateObjectWithJSON:(NSDictionary *) dict  object:(NSManagedObject *)object
        managegObjectContext:(NSManagedObjectContext *) managedObjectContext;
+ (BOOL)convertJSONToObject:(NSString *) theId jsonValue:(NSDictionary *) dict name:(NSString *) name
                    managegObjectContext:(NSManagedObjectContext *) managedObjectContext;

+ (BOOL) checkNameUnique:(NSArray *) array withFood:(FoodProduct *) currentFood;

@end
