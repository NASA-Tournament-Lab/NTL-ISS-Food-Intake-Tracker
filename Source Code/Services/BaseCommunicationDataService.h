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
//  BaseCommunicationDataService.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 2013-07-13.
//

#import "BaseDataService.h"

/*!
 @protocol BaseCommunicationDataService
 @discussion This interface defines the methods to create smbclient.
 @author flying2hk, duxiaoyang, LokiYang
 @version 1.1
 @changes from 1.0
    1. Add support for SMBClient.
 */
@interface BaseCommunicationDataService : BaseDataService

/*!
 @discussion Represents the path of the shared file server.
 */
@property (nonatomic, readonly, strong) NSString *sharedFileServerPath;

/*!
 @discussion Represents the username used to access the shared file server.
 */
@property (nonatomic, readonly, strong) NSString *sharedFileServerUsername;

/*!
 @discussion Represents the database used to access the shared file server.
 */
@property (nonatomic, readonly, strong) NSString *sharedFileServerDatabase;

/*!
 @discussion Represents the password used to access the shared file server.
 */
@property (nonatomic, readonly, strong) NSString *sharedFileServerPassword;

/*!
 @discussion Initialize the class instance with NSManagedObjectContext and configuration.
 * @param context The NSManagedObjectContext.
 * @param configuration The configuration.
 * @return The newly created object.
 */
-(id)initWithConfiguration:(NSDictionary *)configuration;

@end
