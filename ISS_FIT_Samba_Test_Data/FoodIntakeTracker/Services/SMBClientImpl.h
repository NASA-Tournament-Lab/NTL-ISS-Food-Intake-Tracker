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
//  SMBClientImpl.h
//  ISSFoodIntakeTracker
//
//  Created by LokiYang on 2013-07-27.
//

#import <Foundation/Foundation.h>
#import "SMBClient.h"
#import "KxSMBProvider.h"

/*!
 @class LockServiceImpl
 @discussion This is the default implementation of SMBClient protocol.
 @author flying2hk, LokiYang
 @version 1.0
 */
@interface SMBClientImpl : NSObject<SMBClient>

/*!
 @discussion Represents the path of the shared file server.
 */
@property (nonatomic, strong, readonly) NSString *serverRootPath;
@end
