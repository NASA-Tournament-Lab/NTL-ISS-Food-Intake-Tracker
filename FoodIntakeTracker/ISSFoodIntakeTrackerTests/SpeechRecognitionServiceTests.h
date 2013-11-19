//
//  SpeechRecognitionServiceTests.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 2013-07-13.
//  Copyright (c) 2013 TopCoder. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "SpeechRecognitionServiceImpl.h"
#import "BaseTests.h"

/*!
 @class SpeechRecognitionServiceTests
 @discussion This is the unit test cases for SpeechRecognitionService.
 @author duxiaoyang
 @version 1.0
 */
@interface SpeechRecognitionServiceTests : BaseTests

/*!
 @property The SpeechRecognitionService to test.
 */
@property (nonatomic, strong) SpeechRecognitionServiceImpl *speechRecognitionService;

@end
