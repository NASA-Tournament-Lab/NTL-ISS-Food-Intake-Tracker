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
//  DataHelper.m
//  ISSFoodIntakeTracker
//
//  Created by LokiYang on 8/5/13.
//

#import "DataHelper.h"
#import "UserServiceImpl.h"
#import "FoodProductServiceImpl.h"
#import "FoodConsumptionRecordServiceImpl.h"
#import "LoggingHelper.h"

#import <dlfcn.h>
#include <arpa/inet.h>
#include <ifaddrs.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <net/if_dl.h>
#include <sys/sysctl.h>
#include <net/if.h>

@implementation DataHelper

/*!
 @discussion It will convert the NSString to a NSSet with managed objects. The string is separated by the separator.
 @param str The string.
 @param entity The managed object's entity description.
 @param context The entity's context.
 @param separator The separator used to split the string.
 @return The NSSet with manged objects.
 */
+ (NSSet*)convertNSStringToNSSet:(NSString *)str withEntityDescription:(NSEntityDescription *)entity
          inManagedObjectContext:(NSManagedObjectContext*)context withSeparator:(NSString *)separator {
    NSArray *strArray = [str componentsSeparatedByString:separator];
    NSMutableArray *stringWrappersArray = [NSMutableArray array];
    for (NSString *item in strArray) {

        StringWrapper *stringWrapper = [[StringWrapper alloc] initWithEntity:entity
                                              insertIntoManagedObjectContext:context];
        stringWrapper.value = item;
        [stringWrappersArray addObject:stringWrapper];
    }
    
    return [NSSet setWithArray:stringWrappersArray];
}

/*!
 @discussion This method will convert the NSSet of StringWrapper to NSString by using the separator.
 @param set The NSSet.
 @param separator The separator used to join StringWrapper in NSString.
 @return The NSString with joined StringWrapper.
 */
+ (NSString *)convertStringWrapperNSSetToNSString:(NSSet *)set withSeparator:(NSString *)separator {
    NSMutableArray *strArray = [NSMutableArray array];
    for (StringWrapper *s in set) {
        [strArray addObject:[s.value copy]];
    }
    return [strArray componentsJoinedByString:separator];
}

/*!
 @discussion This method will get the device's identifier. It will fetch uniquely identifies a device to the app’s 
 vendor in iOS 6.0 and later, or fetch MAC address as the identifier previous iOS 6.0.
 @return The device's indentifier string.
 */
+ (NSString *)getDeviceIdentifier {
    NSString *reqSysVer = @"6.0";
    // fetch uniquely identifies a device to the app’s vendor in iOS 6.0 and later
    if(([[[UIDevice currentDevice] systemVersion] compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)) {
        return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    // use mac address
    else {
        struct ifaddrs *ifap, *ifaptr;
        unsigned char *ptr;
        char macaddrstr[18];
        
        if (getifaddrs(&ifap) == 0) {
            for(ifaptr = ifap; ifaptr != NULL; ifaptr = (ifaptr)->ifa_next) {
                // mac address
                if (!strcmp((ifaptr)->ifa_name, [@"en0" UTF8String]) && (((ifaptr)->ifa_addr)->sa_family == AF_LINK)) {
                    ptr = (unsigned char *)LLADDR((struct sockaddr_dl *)(ifaptr)->ifa_addr);
                    sprintf(macaddrstr, "%02x:%02x:%02x:%02x:%02x:%02x",
                            *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5));
                    
                    
                }
            }
            freeifaddrs(ifap);
        }
        
        return [DataHelper fillIncompletedHexAddress:[NSString stringWithUTF8String:macaddrstr]];
    }
}

/*!
 @discussion This method will align and fill incompleted the MAC address.
 @param hexAddress The MAC address.
 @return Aligned MAC address
 */
+ (NSString *)fillIncompletedHexAddress:(NSString *)hexAddress
{
    if(hexAddress.length == 0)
    {
        return hexAddress;
    }
    NSArray *components = [hexAddress componentsSeparatedByString:@":"];
    NSMutableArray *parsedComponents = [[NSMutableArray alloc] init];
    for (int i = 0; i < [components count]; i ++)
    {
        if([[components objectAtIndex:i] length] == 1)
        {
            [parsedComponents addObject: [NSString stringWithFormat:@"0%@", [components objectAtIndex:i]]];
        }
        else
        {
            [parsedComponents addObject: [components objectAtIndex:i]];
        }
    }
    
    return [[parsedComponents componentsJoinedByString:@"-"] uppercaseString];
}

/*!
 @discussion This method will build a User instance from the array data.
 @param data The array contains User info.
 @param context The maanged object context the new User belongs to.
 @param error The error.
 @return A new User instance.
 */
+ (User *)buildUserFromData:(NSArray *)data
     inManagedObjectContext:(NSManagedObjectContext *)context
                      error:(NSError **)e{
    
    NSString *methodName = [NSString stringWithFormat:@"%@.buildUserFromData:inManagedObjectContext:error",
                                    NSStringFromClass(self.class)];
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"data"] params:@[data]];
    id<UserService> userService = [[UserServiceImpl alloc] init];
    id<FoodProductService> foodProdcutService = [[FoodProductServiceImpl alloc] init];
    NSError *error = nil;
    User *user = [userService buildUser:&error];
    
    user.admin = [data[0] isEqualToString:@"YES"]?@YES:@NO;
    user.fullName = data[1];
    
    // build filter
    FoodProductFilter *filter = nil;
    
    if([data[2] isEqualToString:@""])
    {
        filter = nil;
    }
    else {
        filter = [foodProdcutService buildFoodProductFilter:&error];
        filter.name = data[2];
        filter.origins = [DataHelper convertNSStringToNSSet:data[3]
                                      withEntityDescription:[NSEntityDescription entityForName:@"StringWrapper"
                                                                        inManagedObjectContext:context]
                                     inManagedObjectContext:nil withSeparator:@";"];
        filter.categories = [DataHelper convertNSStringToNSSet:data[4]
                                         withEntityDescription:[NSEntityDescription entityForName:@"StringWrapper"
                                                                           inManagedObjectContext:context]
                                        inManagedObjectContext:nil withSeparator:@";"];
        filter.favoriteWithinTimePeriod = @([data[5] intValue]);
        filter.sortOption = @([DataHelper buildFoodProductSortOptionFromString:data[6]]);
        if(filter.sortOption.intValue == -1) {
            error = [NSError errorWithDomain:@"DataHelper" code:IllegalArgumentErrorCode
                                    userInfo:@{NSUnderlyingErrorKey: @"Can't build user. FoodProductSortOption is not right."}];
            if(e) {
                *e = error;
            }
            [LoggingHelper logError:methodName error:error];
            [LoggingHelper logMethodExit:methodName returnValue:nil];
            return nil;
        }
    }
    
    
    
    user.lastUsedFoodProductFilter = filter;
    user.useLastUsedFoodProductFilter = [data[7] isEqualToString:@"YES"]?@YES:@NO;
    user.dailyTargetFluid = @([data[8] intValue]);
    user.dailyTargetEnergy = @([data[9] intValue]);
    user.dailyTargetSodium = @([data[10] intValue]);
    user.dailyTargetProtein = @([data[11] intValue]);
    user.dailyTargetCarb = @([data[12] intValue]);
    user.dailyTargetFat = @([data[13] intValue]);
    user.maxPacketsPerFoodProductDaily = @([data[14] intValue]);
    user.profileImage = data[15];
    user.deleted = [data[16] isEqualToString:@"YES"]?@YES:@NO;

    user.lastModifiedDate = [NSDate dateWithTimeIntervalSince1970:[data[17] doubleValue]];
    user.createdDate = [NSDate dateWithTimeIntervalSince1970:[data[18] doubleValue]];
    [LoggingHelper logMethodExit:methodName returnValue:user];
    return user;
}


/*!
 @discussion This method will build a FoodConsumptionRecord instance from the array data.
 @param data The array contains FoodConsumptionRecord info.
 @param context The maanged object context the new FoodConsumptionRecord belongs to.
 @param error The error.
 @return A new FoodConsumptionRecord instance.
 */
+ (FoodConsumptionRecord *)buildFoodConsumptionRecordFromData:(NSArray *)data
                                       inManagedObjectContext:(NSManagedObjectContext *)context
                                                        error:(NSError **)e {
    NSString *methodName = [NSString
                            stringWithFormat:@"%@.buildFoodConsumptionRecordFromData:inManagedObjectContext:error",
                            NSStringFromClass(self.class)];
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"data", @"context"] params:@[data, context]];
    id<FoodConsumptionRecordService> foodConsumptionRecordService = [[FoodConsumptionRecordServiceImpl alloc] init];
    NSError *error = nil;
    FoodConsumptionRecord *record = [foodConsumptionRecordService buildFoodConsumptionRecord:&error];

    record.timestamp = [NSDate dateWithTimeIntervalSince1970:[data[2] doubleValue]];
    record.quantity = @([data[3] floatValue]);
    record.comment = data[4];
    
    record.images = [DataHelper convertNSStringToNSSet:data[5]
                                 withEntityDescription:[NSEntityDescription entityForName:@"StringWrapper"
                                                                   inManagedObjectContext:context]
                                inManagedObjectContext:nil withSeparator:@";"];;
    record.voiceRecordings = [DataHelper convertNSStringToNSSet:data[6]
                                          withEntityDescription:[NSEntityDescription entityForName:@"StringWrapper"
                                                                            inManagedObjectContext:context]
                                         inManagedObjectContext:nil withSeparator:@";"];
    record.fluid = @([data[7] intValue]);
    record.energy = @([data[8] intValue]);
    record.sodium = @([data[9] intValue]);
    record.protein = @([data[10] intValue]);
    record.carb = @([data[11] intValue]);
    record.fat = @([data[12] intValue]);
    record.deleted = [data[13] isEqualToString:@"YES"]?@YES:@NO;
    
    record.lastModifiedDate = [NSDate dateWithTimeIntervalSince1970:[data[14] doubleValue]];
    record.createdDate = [NSDate dateWithTimeIntervalSince1970:[data[15
                                                                     ] doubleValue]];
    [LoggingHelper logMethodExit:methodName returnValue:record];
    return record;
}


/*!
 @discussion This method will build a AdhocFoodProduct instance from the array data.
 @param data The array contains AdhocFoodProduct info.
 @param context The maanged object context the newAdhocFoodProductUser belongs to.
 @param error The error.
 @return A new AdhocFoodProduct instance.
 */
+ (AdhocFoodProduct *)buildAdhocFoodProductFromData:(NSArray *)adhocFoodProductData
                             inManagedObjectContext:(NSManagedObjectContext *)context
                                              error:(NSError **)e {
    NSString *methodName = [NSString stringWithFormat:@"%@.buildAdhocFoodProductFromData:inManagedObjectContext:error",
                            NSStringFromClass(self.class)];
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"adhocFoodProductData", @"context"]
                              params:@[adhocFoodProductData, context]];
    id<FoodProductService> foodProdcutService = [[FoodProductServiceImpl alloc] init];
    NSError *error = nil;
    AdhocFoodProduct *localFoodProduct = [foodProdcutService buildAdhocFoodProduct:&error];
    localFoodProduct.name = adhocFoodProductData[0];
    localFoodProduct.barcode = adhocFoodProductData[1];
    localFoodProduct.images = [DataHelper convertNSStringToNSSet:adhocFoodProductData[2]
                                           withEntityDescription:[NSEntityDescription entityForName:@"StringWrapper"
                                                                             inManagedObjectContext:context]
                                          inManagedObjectContext:nil withSeparator:@";"];
    localFoodProduct.origin = adhocFoodProductData[3];
    localFoodProduct.category = adhocFoodProductData[4];
    localFoodProduct.fluid = @([adhocFoodProductData[5] intValue]);
    localFoodProduct.energy = @([adhocFoodProductData[6] intValue]);
    localFoodProduct.sodium = @([adhocFoodProductData[7] intValue]);
    localFoodProduct.protein = @([adhocFoodProductData[8] intValue]);
    localFoodProduct.carb = @([adhocFoodProductData[9] intValue]);
    localFoodProduct.fat = @([adhocFoodProductData[10] intValue]);
    localFoodProduct.productProfileImage = adhocFoodProductData[11];
    localFoodProduct.deleted =  [adhocFoodProductData[13] isEqualToString:@"YES" ] ? @YES :@NO;
    localFoodProduct.lastModifiedDate = [NSDate dateWithTimeIntervalSince1970:[adhocFoodProductData[14] doubleValue]];
    localFoodProduct.createdDate = [NSDate dateWithTimeIntervalSince1970:[adhocFoodProductData[15] doubleValue]];
    [LoggingHelper logMethodExit:methodName returnValue:localFoodProduct];
    return localFoodProduct;

}

/*!
 @discussion This method will get the LocalFileSystemDirectory absolute directory in "Document" folder.
 @return The absolute directory of the LocalFileSystemDirectory.
 */
+ (NSString *)getAbsoulteLocalDirectory:(NSString *)localDirectory {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *localDirFullPath = [documentsDirectory stringByAppendingPathComponent:localDirectory];

    if(![[NSFileManager defaultManager] fileExistsAtPath:localDirFullPath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:localDirFullPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    return localDirFullPath;
}


/*!
 @discussion This method will build a FoodProductSortOption from string.
 @param str The string representation of FoodProductSortOption
 @return The FoodProductSortOption enum
 */
+ (FoodProductSortOption)buildFoodProductSortOptionFromString:(NSString *)str {
    if ([str isEqualToString:@"FREQUENCY_HIGH_TO_LOW"]) {
        return FREQUENCY_HIGH_TO_LOW;
    }
    else if ([str isEqualToString:@"FREQUENCY_LOW_TO_HIGH"]) {
        return FREQUENCY_LOW_TO_HIGH;
    }
    else if ([str isEqualToString:@"A_TO_Z"]) {
        return A_TO_Z;
    }
    else if ([str isEqualToString:@"Z_TO_A"]) {
        return Z_TO_A;
    }
    else if ([str isEqualToString:@"ENERGY_HIGH_TO_LOW"]) {
        return ENERGY_HIGH_TO_LOW;
    }
    else if ([str isEqualToString:@"ENERGY_LOW_TO_HIGH"]) {
        return ENERGY_LOW_TO_HIGH;
    }
    else if ([str isEqualToString:@"FLUID_HIGH_TO_LOW"]) {
        return FLUID_HIGH_TO_LOW;
    }
    else if ([str isEqualToString:@"FLUID_LOW_TO_HIGH"]) {
        return FLUID_LOW_TO_HIGH;
    }
    else if ([str isEqualToString:@"SODIUM_HIGH_TO_LOW"]) {
        return SODIUM_HIGH_TO_LOW;
    }
    else if ([str isEqualToString:@"SODIUM_LOW_TO_HIGH"]) {
        return SODIUM_LOW_TO_HIGH;
    }
    else {
        return -1;
    }
}

/*!
 @discussion This method will format a FoodProductSortOption to string.
 @param The NSNumber stores FoodProductSortOption enum
 @return str The string representation of FoodProductSortOption
 */
+ (NSString*)formatFoodProductSortOptionToString:(NSNumber *)sortOption {
    NSString *result = nil;
    
    switch([sortOption intValue]) {
        case FREQUENCY_HIGH_TO_LOW:
            result = @"FREQUENCY_HIGH_TO_LOW";
            break;
        case FREQUENCY_LOW_TO_HIGH:
            result = @"FREQUENCY_LOW_TO_HIGH";
            break;
        case Z_TO_A:
            result = @"Z_TO_A";
            break;
        case A_TO_Z:
            result = @"A_TO_Z";
            break;
        case ENERGY_HIGH_TO_LOW:
            result = @"ENERGY_HIGH_TO_LOW";
            break;
        case ENERGY_LOW_TO_HIGH:
            result = @"ENERGY_LOW_TO_HIGH";
            break;
        case FLUID_HIGH_TO_LOW:
            result = @"FLUID_HIGH_TO_LOW";
            break;
        case FLUID_LOW_TO_HIGH:
            result = @"FLUID_LOW_TO_HIGH";
            break;
        case SODIUM_HIGH_TO_LOW:
            result = @"SODIUM_HIGH_TO_LOW";
            break;
        case SODIUM_LOW_TO_HIGH:
            result = @"SODIUM_LOW_TO_HIGH";
            break;
        default:
            result = @"Unexpected FoodProductSortOption";
            break;
    }
    
    return result;
}
@end
