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
//  Helper.m
//  FoodIntakeTracker
//
//  Created by lofzcx 06/12/2013
//

#import "Helper.h"
#import "AppDelegate.h"
#import "PGCoreData.h"

#define MAX_WIDTH 768

@implementation Helper

/* the month name array */
static NSArray *monthNameArray = nil;

/**
 * get the month name by month number.
 * @param month should be 1 - 12.
 * @return the month name if valid month number. else nil.
 */
+ (NSString *)monthName:(int)month{
    if(monthNameArray == nil){
        monthNameArray = [NSArray arrayWithObjects:@"January", @"February", @"March", @"April",
                          @"May", @"June", @"July", @"August", @"September", @"October ",
                          @"November ", @"December" , nil];
    }
    if(month <= 0 || month > 12){
        return nil;
    }
    else{
        return [monthNameArray objectAtIndex:month - 1];
    }
}

/*!
 @discussion This method will save an image to file system. The file name will be automatically generated.
 @param data the content of the file
 @return the file path
 */
+ (NSString *)saveImage:(NSData *)data {
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *additionalFileDirectory = [documentsPath stringByAppendingPathComponent:appDelegate.additionalFilesDirectory];
    
    // Check if the directory already exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:additionalFileDirectory]) {
        // Directory does not exist so create it
        [[NSFileManager defaultManager] createDirectoryAtPath:additionalFileDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSDateFormatter *defaultFormatter = [[NSDateFormatter alloc] init];
    [defaultFormatter setLocale:[NSLocale autoupdatingCurrentLocale]];
    [defaultFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [defaultFormatter setDateFormat:nil];
    [defaultFormatter setDateFormat:@"yyyyddMMHHmmss"];
    NSString *dateString = [defaultFormatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", dateString];
    NSString *filePath = [additionalFileDirectory stringByAppendingFormat:@"/%@", fileName];
    if ([data writeToFile:filePath atomically:YES]) {
        return fileName;
    }
    return nil;
}

/*
 * This method will save an image to file system. The file name will be automatically generated.
 * @param image the image to save
 * @return the file path
 */
+ (NSString *)saveImage2:(UIImage *)image {
    if (image.size.width > 480) {
        CGSize newSize = CGSizeMake(480, 480);
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    
        return [Helper saveImage:UIImageJPEGRepresentation(newImage, 0.9)];
    }
    
    return [Helper saveImage:UIImageJPEGRepresentation(image, 0.9)];
}

/*!
 @discussion This method will save a voice recording to file system. The file name will be automatically generated.
 @param data the content of the file
 @return the file path
 */
+ (NSString *)saveVoiceRecording:(NSData *)data {
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *additionalFileDirectory = [documentsPath stringByAppendingPathComponent:appDelegate.additionalFilesDirectory];
    
    // Check if the directory already exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:additionalFileDirectory]) {
        // Directory does not exist so create it
        [[NSFileManager defaultManager] createDirectoryAtPath:additionalFileDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSDateFormatter *defaultFormatter = [Helper defaultFormatter];
    [defaultFormatter setDateFormat:@"yyyyddMMHHmmss"];
    NSString *dateString = [defaultFormatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.aac", dateString];
    NSString *filePath = [additionalFileDirectory stringByAppendingFormat:@"/%@", fileName];
    if ([data writeToFile:filePath atomically:YES]) {
        return fileName;
    }
    return nil;
}

/*!
 @discussion This method gets the default date formatter.
 @return the default formatter
 */
+ (NSDateFormatter *) defaultFormatter {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale autoupdatingCurrentLocale]];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    return formatter;
}

/*!
 @discussion This method shows an alert to the user.
 @param title The message title.
        message The message body.
 */
+(void)showAlert:(NSString *)title message:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    });
}

/*!
 @discussion This method shows an alert to the user.
 @param title The message title.
    message The message body.
    delegate The alert delegate
 */
+(void)showAlert:(NSString *)title message:(NSString *)message delegate:(id)delegate {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:delegate
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    });
}

/*!
 @discussion This method displays error to the user.
 @param error The error.
 @return YES  if the error is displayed. NO if there's no error.
 */
+(BOOL)displayError:(NSError *)error {
    if (error != nil) {
        NSString *errorMessage = error.userInfo[NSUnderlyingErrorKey];
        if (!errorMessage || [errorMessage isEqualToString:@""]) {
            errorMessage = error.userInfo[NSLocalizedDescriptionKey];
        }
        [Helper showAlert:@"Error" message:errorMessage];
        return YES;
    }
    return NO;
}

/*!
 @discussion This method is used to load image.
 @param imagePath The image path.
 @return The image
 */
+(UIImage *)loadImage:(NSString *)imagePath {
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *additionalFileDirectory = [documentsPath stringByAppendingPathComponent:appDelegate.additionalFilesDirectory];
    NSString *filePath = [additionalFileDirectory stringByAppendingFormat:@"/%@", imagePath];
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    if (!image) {
        image = [UIImage imageNamed:imagePath];
    }
    return image;
}

/*!
 @discussion Check if the input is a number.
 @param input the input string
 @return YES if the string is a number.
 */
+ (BOOL) checkIsNumber:(NSString *) input {
    // Has to be numerical
    if (input.length == 0) {
        return NO;
    }
    NSArray *components = [input componentsSeparatedByString:@"."];
    if (components.count > 2) {
        return NO;
    }
    if ([components[0] length] == 0) {
        return NO;
    }

    BOOL valid = [input length] > 0 && [[input stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789."]] isEqualToString:@""];
    return valid;
}

/*!
 @discussion Check if the string is a valid.
 @param input the input string
 @return YES if the string is valid.
 */
+ (BOOL) checkStringIsValid:(NSString *) input {
    NSString *inputString =
    [input stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    BOOL valid = [inputString length] > 0;
    return valid;
}

/*!
 @discussion This method combines date and time to a new date.
 @param date The date.
        time The time.
 @return The combined date.
 */
+(NSDate *)convertDateTimeToDate:(NSDate *)date time:(NSDate *)time {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit |
                                                         NSMonthCalendarUnit |
                                                         NSDayCalendarUnit |
                                                         NSHourCalendarUnit |
                                                         NSMinuteCalendarUnit)
                                               fromDate:date];
    [components setCalendar:calendar];
    
    NSDateComponents *currentDateComponents = [calendar components:(NSHourCalendarUnit |
                                                                    NSMinuteCalendarUnit)
                                                          fromDate:time];
    components.hour = [currentDateComponents hour];
    components.minute = [currentDateComponents minute];
    return [components date];
}

/*!
 @discussion Get number of days from today.
 @param the date to compare.
 @return the number of days from today.
 */
+(NSInteger) daysFromToday:(NSDate *) date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    
    NSDateComponents *c = [calendar components:(NSYearCalendarUnit |
                                                NSMonthCalendarUnit |
                                                NSDayCalendarUnit)
                                      fromDate:[NSDate date]];
    [c setCalendar:calendar];
    c.hour = 0;
    c.minute = 0;
    c.second = 1;
    NSDate *f = [c date];
    
    c = [calendar components:(NSYearCalendarUnit |
                              NSMonthCalendarUnit |
                              NSDayCalendarUnit)
                    fromDate:date];
    [c setCalendar:calendar];
    c.hour = 0;
    c.minute = 0;
    c.second = 1;
    NSDate *t = [c date];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:f toDate:t options:0];
    return [difference day];
}

/*!
 @discussion Check if user lock exists.
 * @param user the user to check.
 * @return true if lock was acquired or if user is already locked for this device, false otherwise.
 */
+ (BOOL)checkLock:(User *)user {
    // check if current user has been lock by another device
    NSString *deviceUuid = [[NSUserDefaults standardUserDefaults] stringForKey:@"UUID"];

    NSArray *userLocks = [[PGCoreData instance] fetchUserLocks];
    if (userLocks) {
        for (NSDictionary *dict in userLocks) {
            NSString *uid = [dict objectForKey:@"id"];
            NSString *deviceId = [dict objectForKey:@"deviceid"];
            if ([uid isEqualToString:user.uuid]) {
                return [deviceId isEqualToString:deviceUuid];
            }
        }
    }
    
    return NO;
}

/*!
 @discussion Try to acquire a user lock.
 * @param user the user to set new lock.
 * @return true if lock was acquired or if user is already locked for this device, false otherwise.
 */
+ (BOOL)acquireLock:(User *)user {
    // check if current user has been lock by another device
    NSString *deviceUuid = [[NSUserDefaults standardUserDefaults] stringForKey:@"UUID"];

    NSArray *userLocks = [[PGCoreData instance] fetchUserLocks];
    if (userLocks) {
        for (NSDictionary *dict in userLocks) {
            NSString *uid = [dict objectForKey:@"id"];
            NSString *deviceId = [dict objectForKey:@"deviceid"];
            if ([uid isEqualToString:user.uuid]) {
                return [deviceId isEqualToString:deviceUuid];
            }
        }
    }

    [[PGCoreData instance] insertUserLock:user];

    return YES;
}

@end

@implementation NSString (CustomFunction)

- (NSString *)trimString {
    return [[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
            stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
}

@end

@implementation NSManagedObject (CustomFunction)

- (NSString *)getSavedObjectId {
    return [self.objectID.URIRepresentation absoluteString];
}

- (NSSet *)categoryToSet:(NSString *) categoy {
    StringWrapper *stringWrapper = [[StringWrapper alloc] initWithEntity:[NSEntityDescription
                                                                          entityForName:@"StringWrapper"
                                                                          inManagedObjectContext:
                                                                          self.managedObjectContext]
                                          insertIntoManagedObjectContext:self.managedObjectContext];
    stringWrapper.value = categoy;
    return [NSSet setWithObject:stringWrapper];
}

@end