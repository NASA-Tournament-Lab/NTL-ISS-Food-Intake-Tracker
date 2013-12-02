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
//  FoodConsumptionRecordService.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 2013-07-13.
//

#import <Foundation/Foundation.h>
#import "Models.h"

/*!
 @protocol FoodConsumptionRecordService
 @discussion This protocol defines the methods to manange FoodConsumptionRecord.
 @author flying2hk, duxiaoyang, LokiYang
 @version 1.1
 @changes from 1.0
    1.Fixed " Method accepting NSError** should have a non-void return value to indicate whether or not an error
    occurred". Add a BOOL return to indicate whether the operation succeeds.
 */

@protocol FoodConsumptionRecordService <NSObject>

/*!
 @discussion Build a default new FoodConsumptionRecord object. This method simply creates the entity but does not
 save it into context.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return The newly created FoodConsumptionRecord object.
 */
-(FoodConsumptionRecord *)buildFoodConsumptionRecord:(NSError **)error;

/*!
 @discussion Make a copy of an existing FoodConsumptionRecord and return the copy.
 @param record The record to copy.
 @param copyToDay The date to which the record will be copied.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return The new copy of the record.
 */
-(FoodConsumptionRecord *)copyFoodConsumptionRecord:(FoodConsumptionRecord *)record copyToDay:(NSDate *)copyToDay
                                              error:(NSError **)error;

/*!
 @discussion Save (or create if not present) a FoodConsumptionRecord object in the Core Data managed object context.
 Note that this method will set the synchronized property of the object as NO, set the lastModifiedDate property of 
 the object as current date time, and set the createdDate property of the object as current date time if it's nil.
 @param user The User object which is associated with the product.
 @param record The FoodConsumptionRecord object to save.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)addFoodConsumptionRecord:(User *)user record:(FoodConsumptionRecord *)record error:(NSError **)error;

/*!
 @discussion Save modifications to an existing FoodConsumptionRecord in the Core Data managed object context.
 Note that an existing food consumption record can only be modified within a given period of time once created, 
 this method should return NSError if the record can't be modified anymore.
 If the record's timestamp is in a time range for which the summary file has already been generated and sent to 
 Samba3 Shared File Server, then this method will call generateSummary method immediately to re-generate and 
 resend the summary.
 * @param record The record to save.
 * @param error The reference to an NSError object which will be filled if any error occurs.
 * @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)saveFoodConsumptionRecord:(FoodConsumptionRecord *)record error:(NSError **)error;

/*!
 @discussion Mark an FoodConsumptionRecord object as deleted.
 Note that this method will NOT physically delete the FoodConsumptionRecord object from the Core Data managed
 object context. It will set the isSynchronized property of the object as NO, set the lastModifiedDate property of 
 the object as current date time, and set the 'deleted' property of the object as YES.
 @param record The FoodConsumptionRecord object to delete.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)deleteFoodConsumptionRecord:(FoodConsumptionRecord *)record error:(NSError **)error;

/*!
 @discussion Retrieve the FoodConsumptionRecord objects for a user at a given day.
 @param date The date within which the records will be retrieved.
 @param user The user for whom the records will be retrieved.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return An array of FoodConsumptionRecords for the given date and user.
 */
-(NSArray *)getFoodConsumptionRecords:(User *)user date:(NSDate *)date error:(NSError **)error;

/*!
 @discussion Delete FoodConsumptionRecord objects which are older than a pre-configured time period.
 Note that this method will physically delete the FoodConsumptionRecord objects directly from Core Data managed
 object context.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)expireFoodConsumptionRecords:(NSError **)error;

/*!
 @discussion Generate food consumption summary spreadsheet file for one user in certain reporting period and push the 
 file to Samba3 Shared File Server (/output_files directory).
 @param user The user.
 @param startDate The start date.
 @param endDate The end date.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)generateSummary:(User *)user startDate:(NSDate *)startDate endDate:(NSDate *)endDate error:(NSError **)error;

@end
