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
//  DataUpdateServiceImpl.m
//  ISSFoodIntakeTracker
//
//  Created by LokiYang on 2013-07-27.
//
//  Updated by pvmagacho on 04/19/2014
//  F2Finish - NASA iPad App Updates
//

#import "DataUpdateServiceImpl.h"
#import "FoodProductServiceImpl.h"
#import "UserServiceImpl.h"
#import "parseCSV.h"
#import "Models.h"
#import "LoggingHelper.h"
#import "DataHelper.h"


@implementation DataUpdateServiceImpl

@synthesize cancelUpdate = _cancelUpdate;
@synthesize localFileSystemDirectory = _localFileSystemDirectory;
@synthesize imageFileNameSuffix = _imageFileNameSuffix;
@synthesize voiceRecordingFileNameSuffix = _voiceRecordingFileNameSuffix;

#define CHECK_ERROR_AND_RETURN(error, return_error, error_msg, error_code, unlock_context, undo_context) \
    if (error || self.cancelUpdate) {\
        if (error && return_error) {\
            *return_error = [NSError errorWithDomain:@"DataUpdateService" code:error_code\
                                            userInfo:@{NSUnderlyingErrorKey:error_msg}];\
        }\
        if (undo_context) {\
            [self undo];\
        }\
        if (unlock_context) {\
            [[self managedObjectContext] unlock];\
        }\
        [LoggingHelper logMethodExit:methodName returnValue:@NO];\
        return NO;\
    }

/*!
 @discussion Initialize the class instance with NSManagedObjectContext and configuration.
 * @param context The NSManagedObjectContext.
 * @param configuration The configuration.
 * @return The newly created object.
 */
-(id)initWithConfiguration:(NSDictionary *)configuration {
    self = [super initWithConfiguration:configuration];
    
    if(self) {
        _localFileSystemDirectory = [configuration valueForKey:@"LocalFileSystemDirectory"];
        _imageFileNameSuffix = [configuration valueForKey:@"ImageFileNameSuffix"];
        _voiceRecordingFileNameSuffix = [configuration valueForKey:@"VoiceRecordingFileNameSuffix"];
    }
    return self;
}

/*!
 @discussion This method will be used to apply data changes (control files) pushed from Earth Laboratory.
 @parame error The NSError object if any error occurred during the operation
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)update:(NSError **)error {
    return [self update:error force:NO];
}

/*!
 @discussion This method will be used to apply data changes (control files) pushed from Earth Laboratory.
 @parame error The NSError object if any error occurred during the operation
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)update:(NSError **)error force:(BOOL)force {
    NSString *methodName = [NSString stringWithFormat:@"%@.update:error:", NSStringFromClass(self.class)];
    [LoggingHelper logMethodEntrance:methodName paramNames:nil params:nil];
    // Create SMBClient and connect to the shared file server
    NSError *e = nil;
    id<SMBClient> smbClient = [self createSMBClient:&e];
    CHECK_ERROR_AND_RETURN(e, error, @"Cannot create SMBClient.", ConnectionErrorCode, NO, NO);
    
    // Lock on the managedObjectContext
    [[self managedObjectContext] lock];
    
    NSString* deviceID = [DataHelper getDeviceIdentifier];
    e = nil;
    /* Do not delete the files now ISSFIT-44
    NSArray* deviceRegistry = [smbClient listFiles:@"device_registry" error:&e];
    CHECK_ERROR_AND_RETURN(e, error, @"Cannot list 'device_registry' directory.", DataUpdateErrorCode, YES, NO);
     */
    if (!e) {
    
        // Scan /control_files/food_product_inventory for changes that have not been applied yet
        NSArray* ackFiles = [smbClient listFiles:@"control_files/food_product_inventory/ack" error:&e];
        CHECK_ERROR_AND_RETURN(e, error, @"Cannot list 'control_files/food_product_inventory/ack' directory.",
                               DataUpdateErrorCode, YES, NO);
        
        if (![ackFiles containsObject:deviceID] || force) {
            
            NSArray* foodDataFolder = [smbClient listFiles:@"control_files/food_product_inventory/data" error:&e];
            CHECK_ERROR_AND_RETURN(e, error, @"Cannot read food data folder.", DataUpdateErrorCode, YES, NO);
            
            if([foodDataFolder containsObject:@"data.csv"]) {
                // The changes have not been applied yet
                NSData *data = [smbClient readFile:@"control_files/food_product_inventory/data/data.csv" error:&e];
                CHECK_ERROR_AND_RETURN(e, error, @"Cannot read data.csv file.", DataUpdateErrorCode, YES, NO);
                CSVParser *parser = [[CSVParser alloc] init];
                NSMutableArray *foodProductDataArray = [parser parseData:data];
                
                NSMutableArray *foodProductNames = [NSMutableArray array];
                BOOL headerFind = NO;
                for (NSMutableArray* foodProductData in foodProductDataArray) {
                    // skip header
                    if(!headerFind) {
                        headerFind = YES;
                        continue;
                    }
                    NSString *foodProductName = [[foodProductData[0]
                                                 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                                                 stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
                    [foodProductNames addObject:foodProductName];
                    // Try to fetch existing FoodProduct with the foodProductName from Core Data managedObjectContext
                    NSFetchRequest *request = [[NSFetchRequest alloc] init];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name == %@)", foodProductName];
                    NSEntityDescription *description = [NSEntityDescription  entityForName:@"FoodProduct"
                                                                    inManagedObjectContext:self.managedObjectContext];
                    [request setEntity:description];
                    [request setPredicate:predicate];
                    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&e];
                    CHECK_ERROR_AND_RETURN(e, error, @"Cannot fetch FoodProduct.", DataUpdateErrorCode, YES, NO);
                    
                    FoodProduct *foodProduct = result.count > 0? result[0] : nil;
                    if (foodProduct) {
                        // Extract other properties from foodProductData array, and update the foodProduct object
                        // Refer to control_files/food_product_inventory.csv for the file format.
                        foodProduct.barcode = foodProductData[3];
                        foodProduct.images = [DataHelper convertNSStringToNSSet:foodProductData[8]
                                                          withEntityDescription:[NSEntityDescription
                                                                                 entityForName:@"StringWrapper"
                                                                                 inManagedObjectContext:
                                                                                 self.managedObjectContext]
                                                         inManagedObjectContext:self.managedObjectContext
                                                                  withSeparator:@";"];
                        foodProduct.origin = foodProductData[2];
                        foodProduct.category = foodProductData[1];
                        foodProduct.fluid =  @([foodProductData[4] intValue]);
                        foodProduct.energy = @([foodProductData[5] intValue]);
                        foodProduct.sodium = @([foodProductData[6] intValue]);
                        foodProduct.protein =  @([foodProductData[7] intValue]);
                        foodProduct.carb = @([foodProductData[8] intValue]);
                        foodProduct.fat = @([foodProductData[9] intValue]);
                        foodProduct.productProfileImage = foodProductData[10];
                    } else {
                        // Create a new FoodProduct in Core Data managedObjectContext
                        // Extract other properties from foodProductData array, and set the properties to the foodProduct
                        // object
                        NSEntityDescription *entity = [NSEntityDescription entityForName:@"FoodProduct"
                                                                  inManagedObjectContext:[self managedObjectContext]];
                        foodProduct = [[FoodProduct alloc] initWithEntity:entity
                                           insertIntoManagedObjectContext:self.managedObjectContext];
                        foodProduct.name = foodProductName;
                        foodProduct.barcode = foodProductData[3];
                        foodProduct.images = [DataHelper convertNSStringToNSSet:foodProductData[11]
                                                          withEntityDescription:[NSEntityDescription
                                                                                 entityForName:@"StringWrapper"
                                                                                 inManagedObjectContext:
                                                                                 self.managedObjectContext]
                                                         inManagedObjectContext:self.managedObjectContext
                                                                  withSeparator:@";"];
                        foodProduct.origin = foodProductData[2];
                        foodProduct.category = foodProductData[1];
                        foodProduct.fluid =  @([foodProductData[4] intValue]);
                        foodProduct.energy = @([foodProductData[5] intValue]);
                        foodProduct.sodium = @([foodProductData[6] intValue]);
                        foodProduct.protein =  @([foodProductData[7] intValue]);
                        foodProduct.carb = @([foodProductData[8] intValue]);
                        foodProduct.fat = @([foodProductData[9] intValue]);
                        foodProduct.active = @YES;
                        foodProduct.productProfileImage = foodProductData[10];
                        foodProduct.deleted = @NO;
                    }
                }
                // Query Core Data to fetch the existing FoodProduct records with active == YES and name
                // is NOT IN foodProductNames array
                
                NSFetchRequest *request = [[NSFetchRequest alloc] init];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (name IN %@) AND (active == YES)",
                                          foodProductNames];
                NSEntityDescription *description = [NSEntityDescription  entityForName:@"FoodProduct"
                                                                inManagedObjectContext:self.managedObjectContext];
                [request setEntity:description];
                [request setPredicate:predicate];

                NSArray *foodProductsToDeactivate = [[self managedObjectContext] executeFetchRequest:request error:&e];
                CHECK_ERROR_AND_RETURN(e, error, @"Cannot fetch FoodProduct.", DataUpdateErrorCode, YES, NO);

                for (FoodProduct* foodProductToDeactivate in foodProductsToDeactivate) {
                    foodProductToDeactivate.active = NO;
                }
                // Read image recording files in control_files/food_product_inventory/data and save in local file system
                NSArray* dataFiles = [smbClient listFiles:@"control_files/food_product_inventory/data" error:&e];
                CHECK_ERROR_AND_RETURN(e, error, @"Cannot list 'control_files/food_product_inventory/data' directory.",
                                       DataUpdateErrorCode, YES, NO);
                for (NSString *dataFile in dataFiles) {
                    if([dataFile hasSuffix:self.imageFileNameSuffix]
                       || [dataFile hasSuffix:self.voiceRecordingFileNameSuffix]) {
                        NSString *localDataFile = [[DataHelper getAbsoulteLocalDirectory:self.localFileSystemDirectory]
                                                   stringByAppendingPathComponent:dataFile];
                        NSString *smbPath = [NSString stringWithFormat:@"control_files/food_product_inventory/data/%@",
                                             dataFile];
                        NSData *data = [smbClient readFile:smbPath error:&e];
                        CHECK_ERROR_AND_RETURN(e, error, @"Cannot read image and recording file.",
                                               DataUpdateErrorCode, YES, NO);
                        [data writeToFile:localDataFile atomically:YES];
                    }
                }
                
                if (![ackFiles containsObject:deviceID]) {
                    // Write acknowledgement file
                    [smbClient writeFile:[NSString stringWithFormat:@"control_files/food_product_inventory/ack/%@", deviceID]
                                    data:[NSData data] error:&e];
                    CHECK_ERROR_AND_RETURN(e, error, @"Cannot write acknowledgement file.", DataUpdateErrorCode, YES, NO);
                }
                
                /* Do not delete the files now ISSFIT-44
                 
                // Check if all devices have acknowledged the update
                BOOL canDelete = YES;
                for (NSString* devID in deviceRegistry) {
                    if (![devID isEqualToString:deviceID] && ![ackFiles containsObject:devID]) {
                        canDelete = NO;
                        break;
                    }
                }
                if (canDelete) {
                    // Received all acknowledgements, delete the whole directory and recreate the control_files
                    // directory hierarchy
                    [smbClient deleteDirectory:@"control_files/food_product_inventory" error:&e];
                    CHECK_ERROR_AND_RETURN(e, error, @"Cannot delete 'food_product_inventory' directory.",
                                           DataUpdateErrorCode, YES, NO);
                    if((![smbClient createDirectory:@"control_files/food_product_inventory" error:&e])
                        ||(![smbClient createDirectory:@"control_files/food_product_inventory/ack" error:&e])
                        ||(![smbClient createDirectory:@"control_files/food_product_inventory/data" error:&e])) {
                        CHECK_ERROR_AND_RETURN(e, error, @"Cannot create  control_files directory and its sub directories.",
                                               DataUpdateErrorCode, YES, NO);
                    }
                }
                */
            }
        }
        
        // Similar to food product inventory, apply the changes for user profiles in control_files/user_management
        // directory
        
        ackFiles = [smbClient listFiles:@"control_files/user_management/ack/" error:&e];
        CHECK_ERROR_AND_RETURN(e, error, @"Cannot list 'control_files/user_management/ack/' directory.",
                               DataUpdateErrorCode, YES, NO);

        if (![ackFiles containsObject:deviceID] || force) {
            
            NSArray* userDataFolder = [smbClient listFiles:@"control_files/user_management/data" error:&e];
            CHECK_ERROR_AND_RETURN(e, error, @"Cannot read user data folder.", DataUpdateErrorCode, YES, NO);
            
            if([userDataFolder containsObject:@"data.csv"]) {
                // The changes have not been applied yet
                NSData *data = [smbClient readFile:@"control_files/user_management/data/data.csv" error:&e];
                CHECK_ERROR_AND_RETURN(e, error, @"Cannot read data.csv.", DataUpdateErrorCode, YES, NO);
                CSVParser *parser = [[CSVParser alloc] init];
                NSMutableArray *userProfileDataArray = [parser parseData:data];
                NSMutableArray *userProfileNames = [NSMutableArray array];
                BOOL headerFind = NO;
                for (NSMutableArray* userProfileData in userProfileDataArray) {
                    // skip header
                    if (!headerFind) {
                        headerFind = YES;
                        continue;
                    }
                    NSString *userFullName = userProfileData[0];
                    [userProfileNames addObject:userFullName];
                    // Try to fetch existing User with the userFullName from Core Data managedObjectContext
                    id<UserService> userService = [[UserServiceImpl alloc] init];
                    
                    // Extract other properties from userProfileData array, and create a User object
                    // Refer to control_files/user_profiles.csv for the file format.
                    User *user = [userService buildUser:&e];
                    CHECK_ERROR_AND_RETURN(e, error, @"Cannot build user.", DataUpdateErrorCode, YES, NO);
                    user.fullName = userProfileData[0];
                    user.admin = [userProfileData[1] isEqualToString:@"YES"]?@YES:@NO;
                    user.dailyTargetFluid = @([userProfileData[2] intValue]);
                    user.dailyTargetEnergy = @([userProfileData[3] intValue]);
                    user.dailyTargetSodium = @([userProfileData[4] intValue]);
                    user.dailyTargetProtein = @([userProfileData[5] intValue]);
                    user.dailyTargetCarb = @([userProfileData[6] intValue]);
                    user.dailyTargetFat = @([userProfileData[7] intValue]);
                    user.maxPacketsPerFoodProductDaily = @([userProfileData[8] intValue]);
                    user.profileImage = userProfileData[9];
                    user.useLastUsedFoodProductFilter = [userProfileData[10] isEqualToString:@"YES"]?@YES:@NO;
                    
                    // saveUser will update existing user or save new user.
                    [userService saveUser:user error:&e];
                    
                    CHECK_ERROR_AND_RETURN(e, error, @"Cannot save user.", DataUpdateErrorCode, YES, NO);
                }

                // Read image recording files in control_files/user_management/data and save in local file system
                NSArray* dataFiles = [smbClient listFiles:@"control_files/user_management/data/" error:&e];
                CHECK_ERROR_AND_RETURN(e, error, @"Cannot list 'data' directory.", DataUpdateErrorCode, YES, NO);
                for (NSString *dataFile in dataFiles) {
                    if([dataFile hasSuffix:self.imageFileNameSuffix]
                       || [dataFile hasSuffix:self.voiceRecordingFileNameSuffix]) {
                        NSString *localDataFile = [[DataHelper getAbsoulteLocalDirectory:self.localFileSystemDirectory]
                                                   stringByAppendingPathComponent:dataFile];
                        NSString *smbPath = [NSString stringWithFormat:@"control_files/user_management/data/%@", dataFile];
                        NSData *data = [smbClient readFile:smbPath error:&e];
                        CHECK_ERROR_AND_RETURN(e, error, @"Cannot read image and recording file.",
                                               DataUpdateErrorCode, YES, NO);
                        [data writeToFile:localDataFile atomically:YES];
                    }
                }
                
                if (![ackFiles containsObject:deviceID]) {
                    // Write acknowledgement file
                    [smbClient writeFile:[NSString stringWithFormat:@"control_files/user_management/ack/%@", deviceID]
                                    data:[NSData data] error:&e];
                    CHECK_ERROR_AND_RETURN(e, error, @"Cannot write ack file.", DataUpdateErrorCode, YES, NO);
                }
                
                /* Do not delete the files now ISSFIT-44
                
                // Check if all devices have acknowledged the update
                BOOL canDelete = YES;
                for (NSString* devID in deviceRegistry) {
                    if (![devID isEqualToString:deviceID] && ![ackFiles containsObject:devID]) {
                        canDelete = NO;
                        break;
                    }
                }
                if (canDelete) {
                    // Received all acknowledgements, delete the whole directory and recreate the control_files
                    // directory hierarchy
                    [smbClient deleteDirectory:@"control_files/user_management" error:&e];
                    CHECK_ERROR_AND_RETURN(e, error, @"Cannot delete 'control_files/user_management' directory.",
                                           DataUpdateErrorCode, YES, NO);
                    [smbClient createDirectory:@"control_files/user_management" error:&e];
                    CHECK_ERROR_AND_RETURN(e, error, @"Cannot create 'control_files/user_management' directory.",
                                           DataUpdateErrorCode, YES, NO);
                    [smbClient createDirectory:@"control_files/user_management/ack" error:&e];
                    CHECK_ERROR_AND_RETURN(e, error, @"Cannot create 'control_files/user_management/ack' directory.",
                                           DataUpdateErrorCode, YES, NO);
                    [smbClient createDirectory:@"control_files/user_management/data" error:&e];
                    CHECK_ERROR_AND_RETURN(e, error, @"Cannot create 'control_files/user_management/data' directory.",
                                           DataUpdateErrorCode, YES, NO);
                }
                */
            }
        }
        
        // Save changes in the managedObjectContext
        [[self managedObjectContext] save:&e];
        CHECK_ERROR_AND_RETURN(e, error, @"Cannot save managed object context.", DataUpdateErrorCode, YES, NO);
    }
    
    // Unlock the managedObjectContext
    [[self managedObjectContext] unlock];
    
    // Finally disconnect from shared file server
    [smbClient disconnect:&e];
    CHECK_ERROR_AND_RETURN(e, error, @"Cannot disconnect.", DataUpdateErrorCode, NO, NO);
    [LoggingHelper logMethodExit:methodName returnValue:@YES];
    return YES;
}

@end
