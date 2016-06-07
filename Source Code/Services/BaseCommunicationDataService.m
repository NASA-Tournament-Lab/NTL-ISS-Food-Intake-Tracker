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
//  BaseCommunicationDataService.m
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 2013-07-13.
//

#import "BaseCommunicationDataService.h"
#import "LoggingHelper.h"

@implementation BaseCommunicationDataService

@synthesize sharedFileServerPath = _sharedFileServerPath;
@synthesize sharedFileServerUsername = _sharedFileServerUsername;
@synthesize sharedFileServerPassword = _sharedFileServerPassword;

/*!
 @discussion Initialize the class instance with NSManagedObjectContext and configuration.
 * @param context The NSManagedObjectContext.
 * @param configuration The configuration.
 * @return The newly created object.
 */
-(id)initWithConfiguration:(NSDictionary *)configuration {
    self = [super init];
    if (self) {
        _sharedFileServerPath = configuration[@"SharedFileServerPath"];
        _sharedFileServerUsername = configuration[@"SharedFileServerUsername"];
        _sharedFileServerPassword = configuration[@"SharedFileServerPassword"];
    }
    return self;
}

@end
