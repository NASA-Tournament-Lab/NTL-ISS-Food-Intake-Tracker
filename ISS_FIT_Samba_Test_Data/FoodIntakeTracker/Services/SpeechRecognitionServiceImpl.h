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
//  SpeechRecognitionServiceImpl.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 2013-07-13.
//

#import <UIKit/UIKit.h>
#import "SpeechRecognitionService.h"
#import "BaseDataService.h"

/*!
 @class SpeechRecognitionServiceImpl
 @discussion This class is the default implementation which conform to SpeechRecognitionService protocol.
 @author flying2hk, duxiaoyang, LokiYang
 @version 1.1
 @changes from 1.0
    1.Fixed " Method accepting NSError** should have a non-void return value to indicate whether or not an error
    occurred". Add a BOOL return to indicate whether the operation succeeds.
 */
@interface SpeechRecognitionServiceImpl : BaseDataService<SpeechRecognitionService>

/*!
 @discussion Represents language model file name for food product names.
 */
@property (nonatomic, readonly, strong) NSString *foodProductLanguageModelFileName;

/*!
 @discussion Represents language model file name for general English language.
 */
@property (nonatomic, readonly, strong) NSString *generalLanguageModelFileName;

/*!
 @discussion Initialize the class instance with NSManagedObjectContext and configuration.
 * @param context The NSManagedObjectContext.
 * @param configuration The configuration.
 * @return The newly created object.
 */
-(id)initWithConfiguration:(NSDictionary *)configuration;

@end
