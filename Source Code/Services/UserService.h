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
//  Created by duxiaoyang on 2013-07-12.
//

#import <Foundation/Foundation.h>
#import "Models.h"

/*!
 @protocol UserService
 @discussion This protocol defines the methods for managing users, logging in/out and authorization checking.
 @author flying2hk, duxiaoyang, LokiYang
 @version 1.1
 @changes from 1.0
    1.Fixed " Method accepting NSError** should have a non-void return value to indicate whether or not an error
    occurred". Add a BOOL return to indicate whether the operation succeeds.
 */
@protocol UserService <NSObject>

/*!
 @discussion Build a default new User object. This method simply creates the entity but does not save it into context.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return The newly created User object.
 */
-(User *)buildUser:(NSError **) error;

/*!
 @discussion Save (or create if not present) a User object in the Core Data managed object context.
 Note that this method will set the synchronized property of the object as NO, set the lastModifiedDate property of 
    the object as current date time, and set the createdDate property of the object as current date time if it's NULL.
 @param user The User object to save.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)saveUser:(User *)user error:(NSError **)error;

/*!
 @discussion Mark a User object as deleted.
 Note that this method will NOT physically delete the User object from the Core Data managed object context. It will set 
 the synchronized property of the object as NO, set the lastModifiedDate property of the object as current date time, 
 and set the deleted property of the object YES. This method will also mark any data associated with the user as deleted.
 @param user The User object to delete.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)deleteUser:(User *)user error:(NSError **)error;

/*!
 @discussion Filter users according to a partial name.
 @param partialName The partial name.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return The list of Users matching the partial name.
 */
-(NSArray *)filterUsers:(NSString *)partialName error:(NSError **)error;

/*!
 @discussion Login user with the full name and return the User object if login succeeded.
 @param fullName The full name.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return The logged in User; or nil if the full name cannot be found.
 */
-(User *)loginUser:(NSString *)fullName error:(NSError **)error;

/*!
 @discussion Logout the user.
 @param user The user to logout.
 @param error The reference to an NSError object which will be filled if any error occurs.
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)logoutUser:(User *)user error:(NSError **)error;

@end
