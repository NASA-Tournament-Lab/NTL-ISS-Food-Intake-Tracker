//
//  FoodConsumptionRecordServiceImpl.m
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 2013-07-13.
//  Copyright (c) 2013 TopCoder. All rights reserved.
//

#import "FoodConsumptionRecordServiceImpl.h"
#import "SMBClient.h"
#import "LoggingHelper.h"

@implementation FoodConsumptionRecordServiceImpl

@synthesize modifiablePeriodInDays;
@synthesize recordKeptPeriodInDays;

-(id)initWithConfiguration:(NSDictionary *)configuration {
    self = [super initWithConfiguration:configuration];
    if (self) {
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
    record.comment = nil;
    record.images = [NSMutableSet set];
    record.voiceRecordings = [NSMutableSet set];
    record.fluid = @0;
    record.energy = @0;
    record.sodium = @0;
    record.user = nil;
    record.deleted = @NO;
    
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
    copy.createdDate = [NSDate date];
    copy.lastModifiedDate = copy.createdDate;
    copy.deleted = @NO;
    copy.comment = @"";
    [self.managedObjectContext insertObject:copy];
    [self.managedObjectContext save:error];
    copy.images = record.images;
    copy.foodProduct = record.foodProduct;
    copy.voiceRecordings = record.voiceRecordings;
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
    NSDate *currentDate = [NSDate date];
    record.createdDate = currentDate;
    record.lastModifiedDate = currentDate;
    record.synchronized = @NO;

    if (user.managedObjectContext == nil) {
        [self.managedObjectContext insertObject:user];
    }
    NSSet *voiceRecordings = record.voiceRecordings;
    NSSet *images = record.images;
    record.images = nil;
    record.voiceRecordings = nil;
    [self.managedObjectContext insertObject:record];
    for (StringWrapper *s in images) {
        [self.managedObjectContext insertObject:s];
    }
    for (StringWrapper *s in voiceRecordings) {
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
    if ([[record.createdDate dateByAddingTimeInterval:60 * 60 * 24 * self.modifiablePeriodInDays.intValue]
         compare:[NSDate date]] == NSOrderedAscending) {
        if(error) {
            *error = [[NSError alloc] initWithDomain:@"FoodConsumptionRecordService"
                                                code: FoodConsumptionRecordNotModifiableErrorCode
                                            userInfo:@{NSUnderlyingErrorKey:
                      @"The food consumption record can't be modified anymore."}];
        }
    } else {
        [self.managedObjectContext lock];
        
        NSDate *currentDate = [NSDate date];
        record.lastModifiedDate = currentDate;
        record.synchronized = @NO;
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *description = [NSEntityDescription  entityForName:@"SummaryGenerationHistory"
                                                        inManagedObjectContext:[self managedObjectContext]];
        NSPredicate *predicate = [NSPredicate
                                  predicateWithFormat:@"(user == %@) AND (startDate <= %@) AND (endDate >= %@)",
                                  record.user, record.timestamp, record.timestamp];
        [request setEntity:description];
        [request setPredicate:predicate];
        
        NSArray *result = [[self managedObjectContext] executeFetchRequest:request error:error];
        [LoggingHelper logError:methodName error:*error];
        
        if (result.count > 0) {
            // re-generate summary
            SummaryGenerationHistory *history = result[0];
            [self generateSummary:history.user startDate:history.startDate endDate:history.endDate error:error];
        }
        
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
    NSDate *currentDate = [NSDate date];
    record.synchronized = @NO;
    record.lastModifiedDate = currentDate;
    record.deleted = @YES;
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deleted == NO) AND (user == %@) AND (timestamp >= %@) AND (timestamp <= %@)", user, dayStart, dayEnd];
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

-(BOOL)expireFoodConsumptionRecords:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.expireFoodConsumptionRecords:",
                            NSStringFromClass(self.class)];
    [LoggingHelper logMethodEntrance:methodName paramNames:nil params:nil];
    
    //Expire records that recordKeptPeriodInDays old.
    [self.managedObjectContext lock];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deleted == NO) AND (createdDate < %@)",
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

-(BOOL)generateSummary:(User *)user startDate:(NSDate *)startDate endDate:(NSDate *)endDate error:(NSError **)error {
    NSString *methodName = [NSString stringWithFormat:@"%@.generateSummary:startDate:endDate:error:",
                            NSStringFromClass(self.class)];
   
    //Check user, startDate or endDate == nil?
    if(user == nil || startDate == nil || endDate == nil){
        if(error) {
            *error = [NSError errorWithDomain:@"FoodConsumptionRecordServiceImpl" code:IllegalArgumentErrorCode
                                 userInfo:@{NSUnderlyingErrorKey: @"user, startDate or endDate should not be nil"}];
           [LoggingHelper logError:methodName error:*error];
        }
        return NO;
    }
    
    [LoggingHelper logMethodEntrance:methodName paramNames:nil params:nil];
    
    //Fetch records
    [[self managedObjectContext] lock];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deleted == NO) AND (user == %@) AND "
                              "(timestamp >= %@) AND (timestamp <= %@)", user, startDate, endDate];
    NSEntityDescription *description = [NSEntityDescription  entityForName:@"FoodConsumptionRecord"
                                                    inManagedObjectContext:[self managedObjectContext]];
    [request setEntity:description];
    [request setPredicate:predicate];
    NSArray *result = [[self managedObjectContext] executeFetchRequest:request error:error];
    [LoggingHelper logError:methodName error:*error];
    
    //Write csv header into memory
    NSMutableArray *additionalFiles = [NSMutableArray array];
    NSMutableData *summaryCSVData = [NSMutableData data];
    const char *csvHeader = [@"\"Username\",\"Date Time\",\"Food Product\",\"Quantity\"\r\n" UTF8String];
    [summaryCSVData appendBytes:csvHeader length:strlen(csvHeader)]; // header
    
    //Write csv rows into memory
    for (FoodConsumptionRecord *record in result) {
        NSString* line = [NSString stringWithFormat:@"\"%@\",\"%@\",\"%@\",\"%@\"\r\n",
                          record.user.fullName, record.timestamp, record.foodProduct.name, record.quantity];
        const char *lineString = [line UTF8String];
        // output line for the record
        [summaryCSVData appendBytes:lineString length:strlen(lineString)];
        // add additional files
        for (StringWrapper* imagePath in record.images) {
            [additionalFiles addObject:imagePath];
        }
        for (StringWrapper* voicePath in record.voiceRecordings) {
            [additionalFiles addObject:voicePath];
        }
    }
    
    //Create directory for the output files
    id<SMBClient> smbClient = [self createSMBClient:error];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyyMMdd"];
    NSString *timestamp = [NSString stringWithFormat:@"%@_%@", [dateFormatter stringFromDate:startDate],
                           [dateFormatter stringFromDate:endDate]];
    // Check if the user folder exists.
    NSArray *outputDirectories = [smbClient listDirectories:@"output_files" error:error];
    [LoggingHelper logError:methodName error:*error];
    BOOL userFolderExists = NO;
    for (NSString *directory in outputDirectories) {
        if ([user.fullName isEqualToString:directory]) {
            // No need to initialize.
            userFolderExists = YES;
            break;
        }
    }
    if (!userFolderExists) {
        [smbClient createDirectory:[NSString stringWithFormat:@"output_files/%@", user.fullName] error:error];
        [LoggingHelper logError:methodName error:*error];
    }
    
    NSArray *timestampDirectories = [smbClient listDirectories:[NSString stringWithFormat:@"output_files/%@",
                                                                user.fullName] error:error];
    [LoggingHelper logError:methodName error:*error];
    
    if(![timestampDirectories containsObject:timestamp]) {
        [smbClient createDirectory:[NSString stringWithFormat:@"output_files/%@/%@", user.fullName, timestamp] error:error];
        [LoggingHelper logError:methodName error:*error];
    }
    
    // Write summaryCSVData
    [smbClient writeFile:[NSString stringWithFormat:@"output_files/%@/%@/summary.csv", user.fullName, timestamp]
                    data:summaryCSVData error:error];
    [LoggingHelper logError:methodName error:*error];
    
    // Write additional files
    for (StringWrapper* path in additionalFiles) {
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:path.value];
        if (data) {
            NSArray *pathSegments = [path.value componentsSeparatedByString:@"/"];
            if ([pathSegments count] > 0) {
                NSString *name =  pathSegments[[pathSegments count] - 1];
                [smbClient writeFile:[NSString stringWithFormat:@"output_files/%@/%@/%@", user.fullName, timestamp, name]
                                data:data error:error];
                [LoggingHelper logError:methodName error:*error];
            }
        }
    }
    
    // Create SummaryGenerationHistory record
    SummaryGenerationHistory *history = [NSEntityDescription
                                         insertNewObjectForEntityForName:@"SummaryGenerationHistory"
                                                inManagedObjectContext:[self managedObjectContext]];
    history.user = user;
    history.startDate = startDate;
    history.endDate = endDate;
    history.createdDate = [NSDate date];
    history.lastModifiedDate = history.createdDate;
    history.synchronized = @NO;
    history.deleted = @NO;
    
    // Save changes in the managedObjectContext
    [[self managedObjectContext] save:error];
    [LoggingHelper logError:methodName error:*error];
    
    // Unlock the managedObjectContext
    [[self managedObjectContext] unlock];
    
    [LoggingHelper logMethodExit:methodName returnValue:nil];
    return YES;
}

@end
