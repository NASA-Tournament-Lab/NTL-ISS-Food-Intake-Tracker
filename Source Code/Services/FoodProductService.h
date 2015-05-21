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
//  UserService.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 2013-07-13.
//
//  Updated by pvmagacho on 05/07/2014
//  F2Finish - NASA iPad App Updates
//

#import <Foundation/Foundation.h>
#import "Models.h"

/*!
 @protocol FoodProductService
 @discussion This protocol defines the methods for accessing Food Product Inventory.
 @author flying2hk, duxiaoyang, LokiYang
 @version 1.1
 @changes from 1.0
    1.Fixed " Method accepting NSError** should have a non-void return value to indicate whether or not an error
    occurred". Add a BOOL return to indicate whether the operation succeeds.
*/
@protocol FoodProductService <NSObject>

/*!
 @discussion Build a default new AdhocFoodProduct object. This method simply creates the entity but does not save it 
 into context.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return The newly created AdhocFoodProduct object.
*/
-(AdhocFoodProduct *)buildAdhocFoodProduct:(NSError **)error;

/*!
 @discussion Build a default new FoodProductFilter object. This method simply creates the entity but does not save it
 into context.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return The newly created FoodProductFilter object.
 */
-(FoodProductFilter *)buildFoodProductFilter:(NSError **)error;

/*!
 @discussion Delete the filter object.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @param The FoodProductFilter object to delete.
 */
-(void)deleteFoodProductFilter:(FoodProductFilter *)filter error:(NSError **)error;

/*!
 @discussion Save (or create if not present) a AdhocFoodProduct object in the Core Data managed object context.
 Note that this method will set the synchronized property of the object as NO, set the lastModifiedDate property of 
 the object as current date time, and set the createdDate property of the object as current date time if it's nil.
 @param user The User object which is associated with the product.
 @param product The AdhocFoodProduct object to save.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)addAdhocFoodProduct:(User *)user product:(AdhocFoodProduct *)product error:(NSError **)error;

/*!
 @discussion Mark an AdhocFoodProduct object as deleted.
 Note that this method will NOT physically delete the AdhocFoodProduct object from the Core Data managed object context. 
 It will set the isSynchronized property of the object as NO, set the lastModifiedDate property of the object as current
 date time, and set the 'deleted' property of the object as YES.
 @param product The AdhocFoodProduct object to delete.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)deleteAdhocFoodProduct:(AdhocFoodProduct *)product error:(NSError **)error;

/*!
 @discussion Filter food product for a user according to given filter.
 * @param filter The filter.
 * @param error The reference to an NSError object which will be filled if any error occurs.
 * @return The array of FoodProduct entities matching the filter.
 */
-(NSArray *)filterFoodProducts:(FoodProductFilter *)filter error:(NSError **)error;

/*!
 @discussion Filter food product for a user according to given filter.
 * @param user The user performing the filtering. The filter will be saved under this user.
 * @param filter The filter.
 * @param error The reference to an NSError object which will be filled if any error occurs.
 * @return The array of FoodProduct entities matching the filter.
*/
-(NSArray *)filterFoodProducts:(User *)user filter:(FoodProductFilter *)filter error:(NSError **)error;

/*!
 @discussion Retrieve the food product with given barcode. Nil will be returned if there's no matching food product.
 @param user The user to search.
 @param barcode The barcode to search.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return The FoodProduct with given barcode; or nil if no such record can be found.
*/
-(FoodProduct *)getFoodProductByBarcode:(User *)user barcode:(NSString *)barcode error:(NSError **)error;

/*!
 @discussion Retrieve the food product with given name. Nil will be returned if there's no matching food product.
 @param user The user to search.
 @param name The name to search.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return The FoodProduct with given name; or nil if no such record can be found.
 */
-(FoodProduct *)getFoodProductByName:(User *)user name:(NSString *)name error:(NSError **)error;

/*!
 @discussion Retrieve the food product with given name (including deleted). Nil will be returned if there's no matching food product.
 @param user The user to search.
 @param name The name to search.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return The FoodProduct with given name; or nil if no such record can be found.
 */
-(FoodProduct *)getAllFoodProductByName:(User *)user name:(NSString *)name error:(NSError **)error;

/*!
 @discussion Retrieve all available product categories.
 * @param error The reference to an NSError object which will be filled if any error occurs.
 * @return The array of all product categories.
 */
-(NSArray *)getAllProductCategories:(NSError **)error;

/*!
 @discussion Retrieve all available product origins.
 * @param error The reference to an NSError object which will be filled if any error occurs.
 * @return The array of all product origins.
 */
-(NSArray *)getAllProductOrigins:(NSError **)error;

@end
