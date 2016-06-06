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
//  SynchronizationServiceImpl.h
//  ISSFoodIntakeTracker
//
//  Created by LokiYang on 2013-07-27.
//

#import <Foundation/Foundation.h>
#import "BaseCommunicationDataService.h"
#import "SynchronizationService.h"


/*!
 @class SynchronizationServiceImpl
 @discussion This is the default implementation of SynchronizationService protocol.
 @author flying2hk, LokiYang, subchap, supercharger
 @version 1.0
 */
@interface SynchronizationServiceImpl : BaseCommunicationDataService<SynchronizationService>

/*!
 @discussion This value represents the local file system directory to save the image and voice recording files.
    Can't be null or empty.
 */
@property (nonatomic, readonly, strong) NSString *localFileSystemDirectory;

/*!
 @discussion This value represents image file name suffix.
 */
@property (nonatomic, readonly, strong) NSString *imageFileNameSuffix;

/*!
 @discussion This value represents voice recording file name suffix.
 */
@property (nonatomic, readonly, strong) NSString *voiceRecordingFileNameSuffix;

/*!
 @discussion This method will get entity object by id
 @param entityName The object's entity name.
 @param uuid The object's uuid.
 @param error The error.
 @return A NSArray contains objects.
 */
- (NSManagedObject *)getObjectById:(NSString *)entityName id:(NSString *)uuid error:(NSError **)error;

@end
