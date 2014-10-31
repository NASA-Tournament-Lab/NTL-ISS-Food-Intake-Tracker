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
//  Updated by pvmagacho on 05/07/2014
//  F2Finish - NASA iPad App Updates
//

#import "DataHelper.h"
#import "DBHelper.h"
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
        // Only add if string is not empty.
        NSString *trimmed = [item stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (trimmed && trimmed.length > 0) {
            StringWrapper *stringWrapper = [[StringWrapper alloc] initWithEntity:entity
                                                  insertIntoManagedObjectContext:context];
            stringWrapper.value = trimmed;
            [stringWrappersArray addObject:stringWrapper];
        }
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

+ (BOOL)updateObjectWithJSON:(NSDictionary *) dict  object:(SynchronizableModel *)object
        managegObjectContext:(NSManagedObjectContext *) managedObjectContext {
    NSEntityDescription *description = object.entity;
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss ZZZ";
    NSDictionary *attributes = [description attributesByName];
    [attributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id value = [dict objectForKey:key];
        if (!value || [value isEqual:[NSNull null]]) {
            return;
        } else if ([value isKindOfClass:[NSString class]] && [value length] == 0) {
            return;
        }
        
        NSAttributeDescription *attrDescription = (NSAttributeDescription *) obj;
        switch (attrDescription.attributeType) {
            case NSDateAttributeType:
                [object setValue:[dateFormatter dateFromString:value] forKey:key];
                break;
            case NSDecimalAttributeType:
                break;
            case NSStringAttributeType:
                [object setValue:[NSString stringWithFormat:@"%@", value] forKey:key];
                break;
            default:
                [object setValue:value forKey:key];
                break;
        }
    }];
    
    NSDictionary *relationships = [description relationshipsByName];
    [relationships enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![dict objectForKey:key]) {
            return;
        }
        
        NSRelationshipDescription *relDescription = (NSRelationshipDescription *) obj;
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        if (relDescription.isToMany) {            
            NSArray *extIds = [[dict objectForKey:key] componentsSeparatedByString:@";"];
            NSMutableSet *currentSet = [object valueForKey:key];
            if (!currentSet) {
                currentSet = [NSMutableSet set];
            }
            
            for (NSString * extId in extIds) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(uuid == %@)", extId];
                [request setEntity:relDescription.destinationEntity];
                [request setPredicate:predicate];
                
                NSArray *objects = [managedObjectContext executeFetchRequest:request error:nil];
                if (objects.count > 0) {
                    [currentSet addObject:[objects objectAtIndex:0]];
                }
            }
        } else {
            NSString *extId = [dict objectForKey:key];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(uuid == %@)", extId];
            [request setEntity:relDescription.destinationEntity];
            [request setPredicate:predicate];
            
            NSArray *objects = [managedObjectContext executeFetchRequest:request error:nil];
            if (objects.count > 0) {
                [object setValue:[objects objectAtIndex:0] forKey:key];
            }
        }
    }];
    
    [object setSynchronized:@YES];
    
    return YES;
}

+ (BOOL)convertJSONToObject:(NSString *) theId jsonValue:(NSDictionary *) dict name:(NSString *) name
                    managegObjectContext:(NSManagedObjectContext *) managedObjectContext {
    NSEntityDescription *description = [NSEntityDescription entityForName:name
                                                   inManagedObjectContext:managedObjectContext];
    SynchronizableModel *object = [[SynchronizableModel alloc] initWithEntity:description
                                               insertIntoManagedObjectContext:managedObjectContext];
    [object setPrimitiveValue:@NO forKey:@"removed"];
    
    [DataHelper updateObjectWithJSON:dict object:object managegObjectContext:managedObjectContext];
    
    [object setPrimitiveValue:theId forKey:@"uuid"];
    
    return YES;
}

@end
