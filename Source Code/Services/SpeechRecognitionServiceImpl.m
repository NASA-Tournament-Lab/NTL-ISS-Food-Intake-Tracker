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
//  SpeechRecognitionServiceImpl.m
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 2013-07-13.
//

#import "SpeechRecognitionServiceImpl.h"
#import "LoggingHelper.h"

@implementation SpeechRecognitionServiceImpl

@synthesize foodProductLanguageModelFileName;
@synthesize generalLanguageModelFileName;

-(id)initWithConfiguration:(NSDictionary *)configuration {
    self = [super init];
    if (self) {
        foodProductLanguageModelFileName = [configuration valueForKey:@"FoodProductLanguageModelFileName"];
        generalLanguageModelFileName = [configuration valueForKey:@"GeneralLanguageModelFileName"];
    }
    return self;
}

-(BOOL)updateFoodProductLanguageModel:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.updateFoodProductLanguageModel:",
                            NSStringFromClass(self.class)];
    [LoggingHelper logMethodEntrance:methodName paramNames:nil params:nil];
    [self.managedObjectContext lock];
    //Fetch product names
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(removed == NO)"];
    NSEntityDescription *description = [NSEntityDescription  entityForName:@"FoodProduct"
                                                    inManagedObjectContext:[self managedObjectContext]];
    NSExpression *categoryExpression = [NSExpression expressionForKeyPath:@"name"];
    NSExpressionDescription *expression = [[NSExpressionDescription alloc] init];
    expression.name = @"name";
    expression.expression = categoryExpression;
    expression.expressionResultType = NSStringAttributeType;
    [request setEntity:description];
    [request setPredicate:predicate];
    [request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch:@[expression]];
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:error];
    [LoggingHelper logError:methodName error:*error];
    [self.managedObjectContext unlock];
    if (*error) {
        [LoggingHelper logMethodExit:methodName returnValue:nil];
        return NO;
    }
    
    //Upper case of names
    NSMutableArray *names = [NSMutableArray array];
    for (NSDictionary *item in result) {
        NSString *value = [item[@"name"] uppercaseString];
        NSArray *values = [value componentsSeparatedByCharactersInSet:[NSCharacterSet
                                                                       characterSetWithCharactersInString:@" ,"]];
        for (NSString *name in values) {
            if (![names containsObject:name] && name.length > 0) {
                [names addObject:name];
            }
        }
    }
    
    //Generate language model
    /*LanguageModelGenerator *lmGenerator = [[LanguageModelGenerator alloc] init];
    NSError *generateError = [lmGenerator generateLanguageModelFromArray:names
                                                          withFilesNamed:foodProductLanguageModelFileName];
    [LoggingHelper logError:methodName error:generateError];
    if (generateError && generateError.code != noErr) {
        *error = generateError;
        [LoggingHelper logError:methodName error:*error];
    }*/
    
    [LoggingHelper logMethodExit:methodName returnValue:nil];
    return YES;
}

-(NSDictionary *)getFoodProductLanguageModelPaths:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.getFoodProductLanguageModelPaths:",
                            NSStringFromClass(self.class)];
    [LoggingHelper logMethodEntrance:methodName paramNames:nil params:nil];
    
    // If lmPath or dicPath is nil, throw error
    NSString *lmPath = [[NSBundle mainBundle] pathForResource:self.foodProductLanguageModelFileName ofType:@"arpa"];
    NSString *dicPath = [[NSBundle mainBundle] pathForResource:self.foodProductLanguageModelFileName ofType:@"dic"];
    if (lmPath == nil || dicPath == nil) {
        if(error) {
            *error = [NSError errorWithDomain:@"SpeechRecognitionServiceImpl" code:FilePathNotExistErrorCode
                                 userInfo:@{NSUnderlyingErrorKey: @"File paths don't exist"}];
           [LoggingHelper logError:methodName error:*error];
        }
        return nil;
    }
    
    NSDictionary *paths = @{@"LMPath": lmPath, @"DictionaryPath": dicPath};
    
    [LoggingHelper logMethodExit:methodName returnValue:paths];
    return paths;
}

-(NSDictionary *)getGeneralLanguageModelPaths:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.getGeneralLanguageModelPaths:",
                            NSStringFromClass(self.class)];
    [LoggingHelper logMethodEntrance:methodName paramNames:nil params:nil];
    
    // If lmPath or dicPath is nil, throw error
    NSString *lmPath = [[NSBundle mainBundle] pathForResource:self.generalLanguageModelFileName ofType:@"arpa"];
    NSString *dicPath = [[NSBundle mainBundle] pathForResource:self.generalLanguageModelFileName ofType:@"dic"];
    if (lmPath == nil || dicPath == nil) {
        if(error) {
            *error = [NSError errorWithDomain:@"SpeechRecognitionServiceImpl" code:FilePathNotExistErrorCode
                                 userInfo:@{NSUnderlyingErrorKey: @"File paths don't exist"}];
           [LoggingHelper logError:methodName error:*error];
        }
        return nil;
    }
    
    NSDictionary *paths = @{@"LMPath": lmPath, @"DictionaryPath": dicPath};
    
    [LoggingHelper logMethodExit:methodName returnValue:paths];
    return paths;
}

@end
