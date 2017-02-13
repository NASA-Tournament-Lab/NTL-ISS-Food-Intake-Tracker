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
+ (NSSet *)convertNSStringToNSSet:(NSString *)str withEntityDescription:(NSEntityDescription *)entity
          inManagedObjectContext:(NSManagedObjectContext*)context withSeparator:(NSString *)separator {
    return [[str componentsSeparatedByString:separator] mutableCopy];
}

/*!
 @discussion This method will convert the NSSet of StringWrapper to NSString by using the separator.
 @param set The NSSet.
 @param separator The separator used to join StringWrapper in NSString.
 @return The NSString with joined StringWrapper.
 */
+ (NSString *)convertStringWrapperNSSetToNSString:(NSSet *)set withSeparator:(NSString *)separator {
    NSMutableArray *strArray = [NSMutableArray array];
    for (Category *category in set) {
        [strArray addObject:category.value];
    }
    return [strArray componentsJoinedByString:separator];
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

/*!
 @discussion This method will sort the array by the id of the object.
 @param array The NSArray with the objects
 @return the sorted array
 */
+ (NSArray *)orderByDate:(NSArray *)array {
    if (array == nil || array.count < 2) {
        return array;
    }

    return [array sortedArrayUsingComparator:^NSComparisonResult(SynchronizableModel *obj1, SynchronizableModel *obj2) {
        NSDate *date1 = [obj1 createdDate];
        NSDate *date2 = [obj2 createdDate];

        NSComparisonResult result = [date1 compare:date2];
        if (result == NSOrderedSame) {
            return [[obj1 id] compare:[obj2 id]];
        } else {
            return result;
        }
    }];
}

+ (BOOL)updateObjectWithJSON:(NSDictionary *) dict  object:(NSManagedObject *)object
        managegObjectContext:(NSManagedObjectContext *) managedObjectContext {
    NSEntityDescription *description = object.entity;
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
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
            {
                value = [dateFormatter dateFromString:value];
                if (value != nil) {
                    [object setValue:value forKey:key];
                }
                break;
            }
            case NSDecimalAttributeType:
                break;
            case NSStringAttributeType:
                [object setValue:[NSString stringWithFormat:@"%@", value] forKey:key];
                break;
            case NSInteger16AttributeType:
            case NSInteger32AttributeType:
            {
                if ([value isKindOfClass:[NSString class]]) {
                    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                    value = [f numberFromString:value];
                    if (value == nil) {
                        break;
                    }
                }
            }
            default:
                [object setValue:value forKey:key];
                break;
        }
    }];

    NSDictionary *relationships = [description relationshipsByName];
    [relationships enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *newKey = [key copy];
        if ([key isEqualToString:@"categories"] ) {
            newKey = @"category_uuids";
        } else if ([key isEqualToString:@"origins"]) {
            newKey = @"origin_uuids";
        }

        id tmpKey = [dict objectForKey:newKey];
        if (tmpKey && ![tmpKey isEqual:[NSNull null]]) {
            NSRelationshipDescription *relDescription = (NSRelationshipDescription *) obj;
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            if (relDescription.isToMany) {
                NSArray *extObjects = [dict objectForKey:newKey];

                NSMutableSet *currentSet = [object mutableSetValueForKey:key];
                
                for (id relatDic in extObjects) {
                    NSString *extId = [relatDic isKindOfClass:[NSDictionary class]] ? [relatDic objectForKey:@"id"] : relatDic;
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(id == %@)", extId];
                    [request setEntity:relDescription.destinationEntity];
                    [request setPredicate:predicate];
                    
                    NSArray *objects = [managedObjectContext executeFetchRequest:request error:nil];
                    if (objects.count > 0) {
                        if (!currentSet) {
                            currentSet = [NSMutableSet set];
                        }
                        
                        [currentSet addObject:[objects objectAtIndex:0]];
                    }
                }                
            } else {
                NSString *extId = [dict objectForKey:key];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(id == %@)", extId];
                [request setEntity:relDescription.destinationEntity];
                [request setPredicate:predicate];
                
                NSArray *objects = [managedObjectContext executeFetchRequest:request error:nil];
                if (objects.count > 0) {
                    [object setValue:[objects objectAtIndex:0] forKey:key];
                }
            }
        }
    }];

    if ([object isKindOfClass:[SynchronizableModel class]]) {
        [(SynchronizableModel *)object setSynchronized:@YES];
    }
    
    return YES;
}

+ (BOOL)convertJSONToObject:(NSString *) theId jsonValue:(NSDictionary *) dict name:(NSString *) name
                    managegObjectContext:(NSManagedObjectContext *) managedObjectContext {
    NSEntityDescription *description = [NSEntityDescription entityForName:name
                                                   inManagedObjectContext:managedObjectContext];
    NSManagedObject *object = [[NSManagedObject alloc] initWithEntity:description
                                       insertIntoManagedObjectContext:managedObjectContext];
    if ([object isKindOfClass:[SynchronizableModel class]]) {
        [(SynchronizableModel *)object setPrimitiveValue:@NO forKey:@"removed"];
    }

    [DataHelper updateObjectWithJSON:dict object:object managegObjectContext:managedObjectContext];
    
    [object setPrimitiveValue:theId forKey:@"id"];
    
    return YES;
}


+ (BOOL) checkNameUnique:(NSArray *) array withFood:(FoodProduct *) currentFood {
    NSUInteger index = [array indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
        FoodProduct *food = obj;
        if ([obj isKindOfClass:[FoodConsumptionRecord class]]) {
            food = [obj foodProduct];
        }
        if ([food.name isEqualToString:currentFood.name] &&
            ![food.id isEqualToString:currentFood.id]) {
            *stop = YES;  // keeps us from returning multiple students with same name
            return YES;
        } else
            return NO;
    }];
    
    return index == NSNotFound;
}


@end
