//
//  PGManagedObject.m
//  FoodIntakeTracker
//
//  Created by pvmagacho on 8/7/14.
//  Copyright (c) 2014 topcoder. All rights reserved.
//

#import "PGManagedObject.h"
#import "Helper.h"
#import "DataHelper.h"
#import "WebserviceCoreData.h"

@implementation PGManagedObject

@synthesize id = _id;

- (void)setId:(NSString *)theId {
    _id = theId;
}

- (void)willSave {
    /*if (![self isDeleted] && [self.objectID isTemporaryID] && !_id) {
        NSString *newUUID = [[NSUUID UUID] UUIDString];        
        _id = [newUUID copy];
    }*/

    if ([self isDeleted]) {
        [self setPrimitiveValue:@YES forKey:@"removed"];
    }
    
    [super willSave];
}

- (NSDictionary *)getAttributes {
    NSArray *keys = [[self.entity attributesByName] allKeys];
    NSDictionary *attributes = [self dictionaryWithValuesForKeys:keys];
    NSMutableDictionary *mutableAttributes = [attributes mutableCopy];
    [attributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isEqualToString:@"synchronized"]) {
            [mutableAttributes setObject:@YES forKey:@"synchronized"];
        }
    }];

    if (!_id) {
        [mutableAttributes removeObjectForKey:@"id"];
    }

    NSDictionary *relationships = [self.entity relationshipsByName];
    keys = [[self.entity relationshipsByName] allKeys];
    attributes = [self dictionaryWithValuesForKeys:keys];
    [attributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        BOOL isToMany = [[relationships objectForKey:key] isToMany];
        if (!isToMany) {
            // Relationship to object
            PGManagedObject *pgObj = (PGManagedObject *) obj;
            if (!obj || [obj isEqual:[NSNull null]]) {
                return;
            }

            if ([pgObj isKindOfClass:[SynchronizableModel class]]) {
                NSNumber *removed = [pgObj valueForKey:@"removed"];
                if (![removed boolValue] && pgObj.id) {
                    [mutableAttributes setObject:[pgObj id] forKey:key];
                }
            }
        } else {
            // Relationships to NSSet
            NSSet *setObj = (NSSet *) obj;
            NSMutableArray *strArray = [NSMutableArray array];
            for (PGManagedObject *s in setObj) {
                if ([setObj isKindOfClass:[SynchronizableModel class]]) {
                    NSNumber *removed = [s valueForKey:@"removed"];
                    if (![removed boolValue] && s.id) {
                        [strArray addObject:[s id]];
                    }
                }
            }
            NSString *newKey = [key copy];
            if ([key isEqualToString:@"categories"]) {
                newKey = @"category_uuids";
            } else if ([key isEqualToString:@"origins"]) {
                newKey = @"origin_uuids";
            }
            [mutableAttributes setObject:strArray forKey:newKey];
        }
    }];
    
    return mutableAttributes;
}

- (BOOL)updateObjects {
    WebserviceCoreData *coreData = [WebserviceCoreData instance];
    NSDictionary *names = @{
                            @"User" : @"NasaUsers",
                            @"Media" : @"Media",
                            @"FoodProductFilter": @"FoodProductFilters",
                            @"FoodProduct": @"FoodProducts",
                            @"AdhocFoodProduct": @"AdhocFoodProducts",
                            @"FoodConsumptionRecord": @"FoodProductRecords"
                            };

    NSString *name = names[self.entity.name];
    if (!name) {
        return NO;
    }

    NSString *newId = [coreData insertObject:name model:[self getAttributes]];
    if (!newId) {
        return NO;
    }
    [self setId:newId];

    return YES;
}


@end
