//
//  PGManagedObject.m
//  FoodIntakeTracker
//
//  Created by pvmagacho on 8/7/14.
//  Copyright (c) 2014 topcoder. All rights reserved.
//

#import "PGManagedObject.h"
#import "PGCoreData.h"

#import "DataHelper.h"

@implementation PGManagedObject

@synthesize uuid;

- (void)willSave {
    if (![self isDeleted] && [self.objectID isTemporaryID] && !self.uuid) {
        NSString *newUUID = [[NSUUID UUID] UUIDString];        
        [self setUuid:newUUID];
    }
    
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
        if ([key isEqualToString:@"uuid"]) {
            [mutableAttributes removeObjectForKey:key];
        }
        
        // Use NSString representation of NSDate to avoid NSInvalidArgumentException when serializing JSON
        if ([obj isKindOfClass:[NSDate class]]) {
            [mutableAttributes setObject:[obj description] forKey:key];
        }
    }];
    
    NSDictionary *relationships = [self.entity relationshipsByName];
    keys = [[self.entity relationshipsByName] allKeys];
    attributes = [self dictionaryWithValuesForKeys:keys];
    [attributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        BOOL isToMany = [[relationships objectForKey:key] isToMany];
        if (!isToMany) {
            // Relationship to object
            PGManagedObject *pgObj = (PGManagedObject *) obj;
            if ([obj isEqual:[NSNull null]]) {
                return;
            }

            NSNumber *removed = [pgObj valueForKey:@"removed"];
            if (![removed boolValue] && pgObj.uuid) {
                [mutableAttributes setObject:[pgObj uuid] forKey:key];
            }
        } else {
            // Relationships to NSSet
            NSSet *setObj = (NSSet *) obj;
            NSMutableArray *strArray = [NSMutableArray array];
            for (PGManagedObject *s in setObj) {
                NSNumber *removed = [s valueForKey:@"removed"];
                if (![removed boolValue] && s.uuid) {
                    [strArray addObject:[s uuid]];
                }
            }
            if (strArray.count > 0) {
                [mutableAttributes setObject:[strArray componentsJoinedByString:@";"] forKey:key];
            }
        }
    }];
    
    return mutableAttributes;
}

- (BOOL)insertObjects {
    NSString *deviceUuid = [[NSUserDefaults standardUserDefaults] stringForKey:@"UUID"];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self getAttributes] options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithBytes:jsonData.bytes length:jsonData.length encoding:NSUTF8StringEncoding];

    error = nil;
    NSArray *values = [NSArray arrayWithObjects:self.uuid, self.entity.name, jsonString, deviceUuid, nil];
    PGResult *result = [[PGCoreData instance]
                        execute:@"INSERT INTO data(id, name, value, createdate, modifieddate, modifiedby) VALUES($1::varchar, $2::varchar, $3::varchar, 'now', 'now', $4::varchar)"
                        format:PGClientTupleFormatText values:values error:&error];
    if (error) {
        NSLog(@"Error during insert: %@", error);
        return NO;
    }
    
    if (result && result.affectedRows == 1) {
        // success
        return YES;
    }
    
    return NO;
}

- (BOOL)updateObjects {
    NSString *deviceUuid = [[NSUserDefaults standardUserDefaults] stringForKey:@"UUID"];
    
    NSError *error = nil;
    NSDictionary *attributes = [self getAttributes];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:attributes options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithBytes:jsonData.bytes length:jsonData.length encoding:NSUTF8StringEncoding];
    
    error = nil;
    NSArray *values = [NSArray arrayWithObjects:self.uuid, jsonString, deviceUuid, nil];
    PGResult *result = [[PGCoreData instance]
                        execute:@"UPDATE data SET value = $2::varchar, modifieddate = 'now', modifiedby = $3::varchar WHERE id = $1::varchar"
                        format:(PGClientTupleFormatText) values:values error:&error];

    if (error) {
        NSLog(@"Error during update: %@", error);
        return NO;
    }
    
    if (result) {
        if (result.affectedRows == 0) {
            return [self insertObjects];
        } else if (result.affectedRows == 1) {
            return YES;
        }
    }
    
    return NO;
}

@end
