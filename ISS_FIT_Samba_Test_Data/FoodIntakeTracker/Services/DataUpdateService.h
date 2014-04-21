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
//  DataUpdateService.h
//  ISSFoodIntakeTracker
//
//  Created by LokiYang on 2013-07-27.
//
//  Updated by pvmagacho on 04/19/2013
//  F2Finish - NASA iPad App Updates
//

#import <Foundation/Foundation.h>

/*!
 @protocol DataUpdateService
 @discussion DataUpdateService protocol defines the method to apply data changes (control files) pushed
 from Earth Laboratory.
 @author flying2hk, LokiYang
 @version 1.0
 */
@protocol DataUpdateService <NSObject>

/*!
 @discussion This method will be used to apply data changes (control files) pushed from Earth Laboratory.
 @parame error The NSError object if any error occurred during the operation
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)update:(NSError **)error;

/*!
 @discussion This method will be used to apply data changes (control files) pushed from Earth Laboratory.
 @parame error The NSError object if any error occurred during the operation
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)update:(NSError **)error force:(BOOL) force;

/*!
 @discussion Set cancel update.
 @param the value to set.
 */
-(void)setCancelUpdate:(BOOL) value;

/*!
 @discussion Check if update was cancelled.
 */
-(BOOL)cancelUpdate;

@end
