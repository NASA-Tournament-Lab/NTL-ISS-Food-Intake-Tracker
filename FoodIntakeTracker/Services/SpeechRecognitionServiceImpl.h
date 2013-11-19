//
//  SpeechRecognitionServiceImpl.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 2013-07-13.
//  Copyright (c) 2013 TopCoder. All rights reserved.
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
