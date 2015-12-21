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
//  Helper.h
//  FoodIntakeTracker
//
//  Created by lofzcx 06/12/2013
//

#import <Foundation/Foundation.h>

/* seconds for a day */
#define DAY_SECONDS 24 * 60 * 60

/**
 * @class Helper
 * common methods is defined here.
 *
 * Changes in 1.1
 * - Add random comment for food items
 *
 * @author lofzcx, subchap
 * @version 1.1
 * @since 1.0
 */
@interface Helper : NSObject

/**
 * get the month name by month number.
 * @param month should be 1 - 12.
 * @return the month name if valid month number. else nil.
 */
+ (NSString *)monthName:(int)month;

/*
 * This method will save an image to file system. The file name will be automatically generated.
 * @param data the content of the file
 * @return the file path
 */
+ (NSString *)saveImage:(NSData *)data;

/*
 * This method will save an image to file system. The file name will be automatically generated.
 * @param image the image to save
 * @return the file path
 */
+ (NSString *)saveImage2:(UIImage *)image;

/*
 * This method will save a voice recording to file system. The file name will be automatically generated.
 * @param data the content of the file
 * @return the file path
 */
+ (NSString *)saveVoiceRecording:(NSData *)data;

/*!
 @discussion This method shows an alert to the user.
 @param title The message title.
        message The message body.
 */
+(void)showAlert:(NSString *)title message:(NSString *)message;

/*!
 @discussion This method shows an alert to the user.
 @param title The message title.
    message The message body.
    delegate The alert delegate
 */
+(void)showAlert:(NSString *)title message:(NSString *)message delegate:(id) delegate;

/*!
 @discussion This method displays error to the user.
 @param error The error.
 @return YES  if the error is displayed. NO if there's no error.
 */
+(BOOL)displayError:(NSError *)error;

/*!
 @discussion This method gets the default date formatter.
 @return the default formatter
 */
+ (NSDateFormatter *) defaultFormatter;

/*!
 @discussion This method is used to load image.
 @param imagePath The image path.
 @return The image
 */
+(UIImage *)loadImage:(NSString *)imagePath;

/*!
 @discussion Check if the input is a number.
 @param input the input string
 @return YES if the string is a number.
 */
+ (BOOL) checkIsNumber:(NSString *) input;

/*!
 @discussion Check if the string is a valid.
 @param input the input string
 @return YES if the string is valid.
 */
+ (BOOL) checkStringIsValid:(NSString *) input;

/*!
 @discussion This method combines date and time to a new date.
 @param date The date.
 time The time.
 @return The combined date.
 */
+(NSDate *)convertDateTimeToDate:(NSDate *)date time:(NSDate *)time;

/*!
 @discussion Get number of days from today.
 @param the date to compare.
 @return the number of days from today.
 */
+(NSInteger) daysFromToday:(NSDate *) date;

@end

@interface NSString (CustomFunction)

- (NSString *) trimString;

@end

@interface NSManagedObject (CustomFunction)

- (NSString *) getSavedObjectId;
- (NSSet *) categoryToSet:(NSString *) category;

@end
