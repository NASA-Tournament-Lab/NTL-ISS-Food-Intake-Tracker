//
//  SpeechRecognitionService.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 2013-07-13.
//  Copyright (c) 2013 TopCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @protocol SpeechRecognitionService
 @discussion 
 @author flying2hk, duxiaoyang, LokiYang
 @version 1.1
 @changes from 1.0
    1.Fixed " Method accepting NSError** should have a non-void return value to indicate whether or not an error
    occurred". Add a BOOL return to indicate whether the operation succeeds.
 */
@protocol SpeechRecognitionService <NSObject>

/*!
 @discussion Update the OpenEars' language model for food product names.
 This method should query all existing food product names, and use LanguageModelGenerator to generate language model, 
 and save the generated dictionary paths (LMPath and DictionaryPath obtained from the 
 LanguageModelGenerator.generateLanguageModelFromArray method).
 * @param error The reference to an NSError object which will be filled if any error occurs.
 * @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)updateFoodProductLanguageModel:(NSError **)error;

/*!
 @discussion Get the language model paths (LMPath and DictionaryPath) of the food product language model.
 The return value will be a NSDictionary, with "LMPath" and "DictionaryPath" as keys.
 * @param error The reference to an NSError object which will be filled if any error occurs.
 * @return The paths for food product language model.
 */
-(NSDictionary *)getFoodProductLanguageModelPaths:(NSError **)error;

/*!
 @discussion Get the language model paths (LMPath and DictionaryPath) of the general English language model.
 The return value will be a NSDictionary, with "LMPath" and "DictionaryPath" as keys.
 The general English language model will be generated using LanguageModelGenerator which includes frequently
 and commonly used English words/phrases, and this language model isn't expected to change at runtime.
 * @param error The reference to an NSError object which will be filled if any error occurs.
 * @return The paths for general English language model.
 */
-(NSDictionary *)getGeneralLanguageModelPaths:(NSError **)error;

@end
