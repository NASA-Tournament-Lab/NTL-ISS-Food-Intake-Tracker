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
//  SynchronizationService.h
//  ISSFoodIntakeTracker
//
//  Created by LokiYang on 2013-07-27.
//
//  Updated by pvmagacho on 04/19/2014
//  F2Finish - NASA iPad App Updates
//

#import <Foundation/Foundation.h>

/*!
 @protocol SynchronizationService
 @discussion SynchronizationService protocol defines the method to synchronize data between iPad devices.
    Specifically this service is responsible for
    1. Push local data changes to Samba Shared File Server.
    2. Pull data changes from other iPad devices and apply the data changes locally.
 @author flying2hk, LokiYang
 @version 1.0
 */
@protocol SynchronizationService <NSObject>

/*!
 @discussion This method will be used to backup the data. If the iPad device is currently not connected
 to Wi-Fi network, then this method will do nothing.
 @parame error The NSError object if any error occurred during the operation
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)backup:(NSError **)error;

/*!
 @discussion This method will be used to synchronize the data. If the iPad device is currently not connected to Wi-Fi
    network, then this method will do nothing.
 @parame error The NSError object if any error occurred during the operation
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)synchronize:(NSError **)error;

@end
