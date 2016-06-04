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
//  FoodConsumptionRecordServiceImpl.m
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 2013-07-13.
//
//  Updated by pvmagacho on 05/07/2014
//  F2Finish - NASA iPad App Updates
//

#import "FoodConsumptionRecordServiceImpl.h"
#import "LoggingHelper.h"
#import "DataHelper.h"

@implementation FoodConsumptionRecordServiceImpl

@synthesize modifiablePeriodInDays;
@synthesize recordKeptPeriodInDays;
@synthesize localFileSystemDirectory;

-(id)initWithConfiguration:(NSDictionary *)configuration {
    self = [super initWithConfiguration:configuration];
    if (self) {
        localFileSystemDirectory = [configuration valueForKey:@"LocalFileSystemDirectory"];
        modifiablePeriodInDays = [configuration valueForKey:@"FoodConsumptionRecordModifiablePeroidInDays"];
        recordKeptPeriodInDays = [configuration valueForKey:@"FoodConsumptionRecordKeptPeriodInDays"];
    }
    return self;
}

-(FoodConsumptionRecord *)buildFoodConsumptionRecord:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.buildFoodConsumptionRecord:", NSStringFromClass(self.class)];
    [LoggingHelper logMethodEntrance:methodName paramNames:nil params:nil];
    
    //Create FoodConsumptionRecord instance
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FoodConsumptionRecord"
                                              inManagedObjectContext:[self managedObjectContext]];
    FoodConsumptionRecord *record = [[FoodConsumptionRecord alloc]
                                     initWithEntity:entity insertIntoManagedObjectContext:nil];
    record.foodProduct = nil;
    record.timestamp = [NSDate date];
    record.quantity = @0;
    record.comment = @"";
    record.images = [NSMutableSet set];
    record.voiceRecordings = [NSMutableSet set];
    record.fluid = @0;
    record.energy = @0;
    record.sodium = @0;
    record.user = nil;
    record.removed = @NO;
    record.adhocOnly = @NO;
    
    [LoggingHelper logMethodExit:methodName returnValue:record];
    return record;
}

-(FoodConsumptionRecord *)copyFoodConsumptionRecord:(FoodConsumptionRecord *)record
                                          copyToDay:(NSDate *)copyToDay error:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.copyFoodConsumptionRecord:copyToDay:error:",
                            NSStringFromClass(self.class)];
    
    //Check record or copyToDay == nil?
    if(record == nil || copyToDay == nil){
        if(error) {
            *error = [NSError errorWithDomain:@"FoodConsumptionRecordServiceImpl" code:IllegalArgumentErrorCode
                                     userInfo:@{NSUnderlyingErrorKey: @"record or copyToDay should not be nil"}];
            
            [LoggingHelper logError:methodName error:*error];
        }
        return nil;
    }
    
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"record", @"copyToDay"] params:@[record, copyToDay]];
    
    //Copy
    FoodConsumptionRecord *copy = [self buildFoodConsumptionRecord:error];
    [self.managedObjectContext lock];
    copy.quantity = record.quantity;
    copy.fluid = record.fluid;
    copy.energy = record.energy;
    copy.sodium = record.sodium;
    copy.protein = record.protein;
    copy.carb = record.carb;
    copy.fat = record.fat;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSDateComponents *copyToDayComponents =[gregorian components:(NSYearCalendarUnit
                                                                  | NSMonthCalendarUnit
                                                                  | NSDayCalendarUnit )
                                                        fromDate:copyToDay];
    [copyToDayComponents setCalendar:gregorian];
    NSDateComponents *sourceDayComponents =[gregorian components:(NSHourCalendarUnit
                                                                  | NSMinuteCalendarUnit
                                                                  | NSSecondCalendarUnit )
                                                        fromDate:[NSDate date]];
    [sourceDayComponents setCalendar:gregorian];
    [copyToDayComponents setHour:[sourceDayComponents hour]];
    [copyToDayComponents setMinute:[sourceDayComponents minute]];
    [copyToDayComponents setSecond:[sourceDayComponents second]];
    copy.timestamp = [copyToDayComponents date];
    copy.synchronized = @NO;
    copy.removed = @NO;
    copy.comment = @"";
    [self.managedObjectContext insertObject:copy];
    [self.managedObjectContext save:error];
    copy.foodProduct = record.foodProduct;
    
    NSMutableSet *set = [NSMutableSet set];
    for (Media *media in record.images) {
        Media *newMedia = [[Media alloc] initWithEntity:[NSEntityDescription entityForName:@"Media"
                                                                    inManagedObjectContext:self.managedObjectContext]
                         insertIntoManagedObjectContext:nil];
        newMedia.filename = [media.filename copy];
        newMedia.removed = @NO;
        newMedia.synchronized = @YES;

        [set addObject:newMedia];
        [self.managedObjectContext insertObject:newMedia];
    }
    [self.managedObjectContext save:error];
    
    copy.images = [NSSet setWithSet:set];
    
    set = [NSMutableSet set];
    for (Media *media in record.voiceRecordings) {
        Media *newMedia = [[Media alloc] initWithEntity:[NSEntityDescription entityForName:@"Media"
                                                                    inManagedObjectContext:self.managedObjectContext]
                         insertIntoManagedObjectContext:nil];
        newMedia.filename = [media.filename copy];
        newMedia.removed = @NO;
        newMedia.synchronized = @YES;

        [set addObject:newMedia];
        [self.managedObjectContext insertObject:newMedia];
    }
    [self.managedObjectContext save:error];
    
    copy.voiceRecordings = [NSSet setWithSet:set];
    
    copy.user = record.user;
    [self.managedObjectContext save:error];
    [LoggingHelper logError:methodName error:*error];
    [self.managedObjectContext unlock];
    
    [LoggingHelper logMethodExit:methodName returnValue:copy];
    return copy;
}

-(BOOL)addFoodConsumptionRecord:(User *)user record:(FoodConsumptionRecord *)record error:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.addFoodConsumptionRecord:record:error:",
                            NSStringFromClass(self.class)];
    
    //Check user or record == nil?
    if(user == nil || record == nil){
        if(error) {
            *error = [NSError errorWithDomain:@"FoodConsumptionRecordServiceImpl" code:IllegalArgumentErrorCode
                                 userInfo:@{NSUnderlyingErrorKey: @"user or record should not be nil"}];
           [LoggingHelper logError:methodName error:*error];
        }
        return NO;
    }
    
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"user", @"record"] params:@[user, record]];
    
    //Add food consumption record
    [self.managedObjectContext lock];
    record.synchronized = @NO;
    user.synchronized = @NO;

    if (user.managedObjectContext == nil) {
        [self.managedObjectContext insertObject:user];
    }
    NSSet *voiceRecordings = record.voiceRecordings;
    NSSet *images = record.images;
    record.images = nil;
    record.voiceRecordings = nil;
    [self.managedObjectContext insertObject:record];
    for (Media *s in images) {
        [self.managedObjectContext insertObject:s];
    }
    for (Media *s in voiceRecordings) {
        [self.managedObjectContext insertObject:s];
    }
    // Save changes in the managedObjectContext
    [self.managedObjectContext save:error];

    record.user = user;
    record.images = images;
    record.voiceRecordings = voiceRecordings;
    [self.managedObjectContext save:error];
    
    [LoggingHelper logError:methodName error:*error];
    [self.managedObjectContext unlock];
    
    [LoggingHelper logMethodExit:methodName returnValue:nil];
    return YES;
}

-(BOOL)saveFoodConsumptionRecord:(FoodConsumptionRecord *)record error:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.saveFoodConsumptionRecord:error:",
                            NSStringFromClass(self.class)];
    
    //Check record or record.managedObjectContext == nil?
    if(record == nil || record.managedObjectContext == nil){
        if(error) {
            *error = [NSError errorWithDomain:@"FoodConsumptionRecordServiceImpl" code:IllegalArgumentErrorCode
                                 userInfo:@{NSUnderlyingErrorKey:
                      @"record or its managedObjectContext should not be nil"}];
           [LoggingHelper logError:methodName error:*error];
        }
        return NO;
    }
    
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"record"] params:@[record]];
    
    //Save record
    NSDate *saveDate = [[NSDate date] dateByAddingTimeInterval:3600 * 24 * self.modifiablePeriodInDays.intValue];
    if ([saveDate compare:[NSDate date]] == NSOrderedAscending) {
        if(error) {
            *error = [[NSError alloc] initWithDomain:@"FoodConsumptionRecordService"
                                                code: FoodConsumptionRecordNotModifiableErrorCode
                                            userInfo:@{NSUnderlyingErrorKey:
                      @"The food consumption record can't be modified anymore."}];
        }
    } else {
        [self.managedObjectContext lock];
        
        record.synchronized = @NO;
        record.foodProduct.synchronized = @NO;
        
        [self.managedObjectContext save:error];
        [LoggingHelper logError:methodName error:*error];
        
        [self.managedObjectContext unlock];
    }

    [LoggingHelper logMethodExit:methodName returnValue:nil];
    return YES;
}

-(BOOL)deleteFoodConsumptionRecord:(FoodConsumptionRecord *)record error:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.deleteFoodConsumptionRecord:error:",
                            NSStringFromClass(self.class)];
    
    //Check record == nil?
    if(record == nil){
        if(error) {
            *error = [NSError errorWithDomain:@"FoodConsumptionRecordServiceImpl" code:IllegalArgumentErrorCode
                                 userInfo:@{NSUnderlyingErrorKey: @"record should not be nil"}];
           [LoggingHelper logError:methodName error:*error];
        }
        return NO;
    }
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"record"] params:@[record]];
    
    //Delete food consumption record
    [self.managedObjectContext lock];
    record.synchronized = @NO;
    record.removed = @YES;
    
    record.foodProduct.synchronized = @NO;
    record.foodProduct = nil;
    
    [self.managedObjectContext save:error];
    
    [LoggingHelper logError:methodName error:*error];
    [self.managedObjectContext unlock];
    
    [LoggingHelper logMethodExit:methodName returnValue:nil];
    return YES;
}

-(NSArray *)getFoodConsumptionRecords:(User *)user date:(NSDate *)date error:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.getFoodConsumptionRecords:date:error:",
                            NSStringFromClass(self.class)];
    
    //Check user or date == nil?
    if(user == nil || date == nil){
        if(error) {
            *error = [NSError errorWithDomain:@"FoodConsumptionRecordServiceImpl" code:IllegalArgumentErrorCode
                                 userInfo:@{NSUnderlyingErrorKey: @"user or date should not be nil"}];
           [LoggingHelper logError:methodName error:*error];
        }
        return nil;
    }
    
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"user", @"date"] params:@[user, date]];
    
    //Fetch records by user and date
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit ) fromDate:date];
    // calculate the first second of the day indicated by "date" parameter
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *dayStart = [calendar dateFromComponents:components];
    // calculate the last second of the day indicated by "date" parameter
    [components setHour:23];
    [components setMinute:59];
    [components setSecond:59];
    NSDate *dayEnd = [calendar dateFromComponents:components];
    [self.managedObjectContext lock];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(removed == NO) AND (user == %@) AND (timestamp >= %@) AND (timestamp <= %@)", user, dayStart, dayEnd];
    NSEntityDescription *description = [NSEntityDescription  entityForName:@"FoodConsumptionRecord"
                                                    inManagedObjectContext:[self managedObjectContext]];
    [request setEntity:description];
    [request setPredicate:predicate];
    NSArray *result = [[self managedObjectContext] executeFetchRequest:request error:error];
    [LoggingHelper logError:methodName error:*error];
    [self.managedObjectContext unlock];
    [LoggingHelper logMethodExit:methodName returnValue:result];
    return result;
}

-(NSArray *)getFoodConsumptionRecords:(User *)user error:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.getFoodConsumptionRecords:error:",
                            NSStringFromClass(self.class)];
    
    //Check user == nil?
    if(user == nil){
        if(error) {
            *error = [NSError errorWithDomain:@"FoodConsumptionRecordServiceImpl" code:IllegalArgumentErrorCode
                                     userInfo:@{NSUnderlyingErrorKey: @"user should not be nil"}];
            [LoggingHelper logError:methodName error:*error];
        }
        return nil;
    }
    
    [LoggingHelper logMethodEntrance:methodName paramNames:@[@"user"] params:@[user]];
    
    [self.managedObjectContext lock];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(removed == NO) AND (user == %@)", user];
    NSEntityDescription *description = [NSEntityDescription  entityForName:@"FoodConsumptionRecord"
                                                    inManagedObjectContext:[self managedObjectContext]];
    [request setEntity:description];
    [request setPredicate:predicate];
    [request setSortDescriptors:@[sortDescriptor]];
    NSArray *result = [[self managedObjectContext] executeFetchRequest:request error:error];
    [LoggingHelper logError:methodName error:*error];
    [self.managedObjectContext unlock];
    [LoggingHelper logMethodExit:methodName returnValue:result];
    return result;
}

-(BOOL)expireFoodConsumptionRecords:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.expireFoodConsumptionRecords:",
                            NSStringFromClass(self.class)];
    [LoggingHelper logMethodEntrance:methodName paramNames:nil params:nil];
    
    //Expire records that recordKeptPeriodInDays old.
    [self.managedObjectContext lock];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(removed == NO) AND (createdDate < %@)",
                              [[NSDate date] dateByAddingTimeInterval:-60 * 60 * 24 * recordKeptPeriodInDays.intValue]];
    NSEntityDescription *description = [NSEntityDescription  entityForName:@"FoodConsumptionRecord"
                                                    inManagedObjectContext:[self managedObjectContext]];
    [request setEntity:description];
    [request setPredicate:predicate];
    NSArray *result = [[self managedObjectContext] executeFetchRequest:request error:error];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    for (FoodConsumptionRecord* record in result) {
        // remove related images
        for (NSString *path in [record.images allObjects]) {
            [fileManager removeItemAtPath:path error:error];
            [LoggingHelper logError:methodName error:*error];
        }
        // remove related recordings
        for (NSString *path in [record.voiceRecordings allObjects]) {
            [fileManager removeItemAtPath:path error:error];
            [LoggingHelper logError:methodName error:*error];
        }
        // delete record
        [[self managedObjectContext] deleteObject:record];
    }
    [self.managedObjectContext save:error];
    [LoggingHelper logError:methodName error:*error];
    [self.managedObjectContext unlock];
    
    [LoggingHelper logMethodExit:methodName returnValue:nil];
    return error?NO:YES;
}

@end
