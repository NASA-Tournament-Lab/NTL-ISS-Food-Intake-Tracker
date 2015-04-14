//
//  PGCoreData.m
//  PGCoreData
//
//  Created by pvmagacho on 8/4/14.
//  Copyright (c) 2014 Topcoder Inc. All rights reserved.
//

#import "PGCoreData.h"
#import "Reachability.h"
#import "Helper.h"

static PGCoreData *instance;
static Reachability* reach;
static NSString* reachHostName = @"";

@implementation PGCoreData {
    BOOL canConnect;
}

@synthesize pgConnection = _pgConnection;

+ (PGCoreData *)instance {
    if (!instance) {
        instance = [[PGCoreData alloc] init];
        instance.pgConnection = [[PGConnection alloc] init];
    }
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        canConnect = YES;
    }
    return self;
}

- (BOOL)connect {
    [self disconnect];
    
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *ipAddress = [standardUserDefaults objectForKey:@"address_preference"];
    NSString *username = [standardUserDefaults objectForKey:@"user_preference"];
    NSString *database = [standardUserDefaults objectForKey:@"database_preference"];
    NSString *password = [standardUserDefaults objectForKey:@"password_preference"];
    
    if (![reachHostName isEqualToString:ipAddress]) {
        reachHostName = [NSString stringWithString:ipAddress];
        
        if (reach) {
            [reach stopNotifier];
            
            // wait 500ms
            [NSThread sleepForTimeInterval:0.5];
        }
        
        // Allocate a reachability object
        reach = [Reachability reachabilityWithHostname:reachHostName];
        
        // Tell the reachability that we DON'T want to be reachable on 3G/EDGE/CDMA
        reach.reachableOnWWAN = NO;
        
        // Update connect flag
        reach.reachableBlock = ^(Reachability*reach) {
            @synchronized(self) {
                canConnect = YES;
            }
            
            [Helper showAlert:@"Success" message:@"The device has re-established the connection to the database server."];
        };
        
        // Update connect flag and disconnect from server (this actualy is a clean up of the
        // libary.
        reach.unreachableBlock = ^(Reachability*reach) {
            @synchronized(self) {
                canConnect = NO;
                
                [self.pgConnection disconnect];
            }
            
            [Helper showAlert:@"Error" message:@"The device has lost connection to the database server. \n"
             "Don’t worry! You can still use the ISS FIT app and we will attempt to sync with the central food repository"
             " when it is available."];
        };
        
        // Start the notifier, which will cause the reachability object to retain itself!
        [reach startNotifier];
        
        // Wait 500ms
        [NSThread sleepForTimeInterval:0.5];
        
        // query status at first try
        canConnect = [reach isReachable];
    }
    
    @synchronized(self) {
        if (!canConnect) {
            NSLog(@"UNREACHABLE");
            return NO;
        }
    }
    
    NSError *connError = nil;
    NSURL *url = [NSURL URLWithHost:ipAddress ssl:YES username:username password:password database:database params:nil];
    [self.pgConnection connectWithURL:url error:&connError];
    if (connError) {
        NSLog(@"Connection error: %@", connError);
        return NO;
    }
    
    return [self isConnected];
}

- (void)disconnect {
    [self.pgConnection disconnect];
}

- (BOOL)isConnected {
    return self.pgConnection.status == PGConnectionStatusConnected;
}

- (BOOL)registerDevice {
    NSString *deviceUuid = [[NSUserDefaults standardUserDefaults] stringForKey:@"UUID"];
    NSError *error = nil;
    NSArray *values = [NSArray arrayWithObjects:deviceUuid, nil];
    PGResult *result = [self execute:@"INSERT INTO devices values($1::varchar)" format:PGClientTupleFormatText
                              values:values error:&error];
    if (result == nil || result.affectedRows != 1 || error) {
        return NO;
    }
    
    return YES;
}

- (BOOL)checkDeviceId {
    NSString *deviceUuid = [[NSUserDefaults standardUserDefaults] stringForKey:@"UUID"];
    NSArray *values = [NSArray arrayWithObject:deviceUuid];
    return [self checkResultExists:@"SELECT deviceId FROM devices WHERE deviceId = $1::varchar" values:values];
}

- (BOOL)checkId:(NSString *) theId {
    NSArray *values = [NSArray arrayWithObject:theId];
    return [self checkResultExists:@"SELECT id FROM data WHERE id = $1::varchar" values:values];
}

- (BOOL)checkResultExists:(NSString *)query values:(NSArray *) values {
    NSError *error = nil;
    
    PGResult *result = [self execute:query format:PGClientTupleFormatText values:values error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error);
        return NO;
    }
    
    if (result == nil || !result.dataReturned) {
        return NO;
    }
    
    return result.size == 1;
}

- (NSArray *)fetchAllObjects {
    NSError *error = nil;
    
    PGResult *result = [self execute:@"SELECT id, value, name FROM data ORDER BY (CASE WHEN name = 'StringWrapper' THEN 0 WHEN name = 'FoodProductFilter' THEN 1 WHEN name = 'User' THEN 2 WHEN name = 'FoodProduct' THEN 3 WHEN name = 'AdhocFoodProduct' THEN 4 WHEN name = 'FoodConsumptionRecord' THEN 5 END), createDate;" format:PGClientTupleFormatText error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error);
        return nil;
    }
    
    if (!result || !result.dataReturned) {
        return nil;
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:result.size];
    for (int i = 0; i < result.size; i++) {
        [array addObject:[result fetchRowAsDictionary]];
    }
    
    return array;
}

- (NSInteger)fetchMediaCount {
    NSError *error = nil;
    
    PGResult *result = [self execute:@"SELECT count(1) as count FROM media WHERE filename like '%.jpg';"
                              format:PGClientTupleFormatText error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error);
        return -1;
    }
    
    if (!result || !result.dataReturned) {
        return -1;
    }
    
    return [[[result fetchRowAsDictionary] objectForKey:@"count"] integerValue];
}

- (BOOL)startFetchMedia {
    NSError *error = nil;
    
    [self execute:@"BEGIN WORK;" format:PGClientTupleFormatText error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
        return NO;
    }
    
    [self execute:@"DECLARE mediafetch SCROLL CURSOR FOR SELECT filename, data FROM media WHERE filename like '%.jpg';"
           format:PGClientTupleFormatText error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error);
        return NO;
    }
    
    return YES;
}

- (BOOL)endFetchMedia {
    NSError *error = nil;
    
    [self execute:@"CLOSE mediafetch;" format:PGClientTupleFormatText error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
        return NO;
    }
    
    [self execute:@"COMMIT WORK;" format:PGClientTupleFormatText error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
        return NO;
    }
    
    return YES;
}


- (NSDictionary *)fetchNextMedia {
    NSError *error = nil;
    
    PGResult *result = [self execute:@"FETCH FORWARD 1 FROM mediafetch;" format:PGClientTupleFormatBinary error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error);
        return nil;
    }
    
    if (!result || !result.dataReturned) {
        return nil;
    }
    
    return [result fetchRowAsDictionary];
}

- (NSArray *)fetchAllMedia {
    NSError *error = nil;
    
    PGResult *result = [self execute:@"SELECT fileName, data FROM media" format:PGClientTupleFormatBinary error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error);
        return nil;
    }
    
    if (!result || !result.dataReturned) {
        return nil;
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:result.size];
    for (int i = 0; i < result.size; i++) {
        [array addObject:[result fetchRowAsDictionary]];
    }
    
    return array;
}

- (NSArray *)fetchObjects {
    NSString *deviceUuid = [[NSUserDefaults standardUserDefaults] stringForKey:@"UUID"];
    NSError *error = nil;
    NSArray *values = [NSArray arrayWithObjects:deviceUuid, nil];
    
    PGResult *result = [self
                        execute:@"SELECT id, value, name FROM data WHERE id in (SELECT DISTINCT id FROM sync_data WHERE deviceId = $1::varchar AND type = 'object') ORDER BY (CASE WHEN name = 'StringWrapper' THEN 0 WHEN name = 'FoodProductFilter' THEN 1 WHEN name = 'User' THEN 5 WHEN name = 'FoodProduct' THEN 2 WHEN name = 'AdhocFoodProduct' THEN 3 WHEN name = 'FoodConsumptionRecord' THEN 4 END), createDate;"
                        format:PGClientTupleFormatText values:values error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error);
        return nil;
    }
    
    if (!result.dataReturned) {
        return nil;
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:result.size];
    for (int i = 0; i < result.size; i++) {
        [array addObject:[result fetchRowAsDictionary]];
    }
    
    return array;
}

- (NSArray *)fetchMedias {
    NSString *deviceUuid = [[NSUserDefaults standardUserDefaults] stringForKey:@"UUID"];
    NSError *error = nil;
    NSArray *values = [NSArray arrayWithObjects:deviceUuid, nil];
    
    PGResult *result = [self
                        execute:@"SELECT filename, data FROM media WHERE filename in (SELECT DISTINCT id FROM sync_data WHERE deviceId = $1::varchar AND type = 'media')"
                        format:PGClientTupleFormatBinary values:values error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error);
        return nil;
    }
    
    if (!result.dataReturned) {
        return nil;
    }
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:result.size];
    for (int i = 0; i < result.size; i++) {
        [array addObject:[result fetchRowAsDictionary]];
    }
    
    return array;
}

- (BOOL)clearObjectSyncData {
    NSString *deviceUuid = [[NSUserDefaults standardUserDefaults] stringForKey:@"UUID"];
    
    NSError *error = nil;
    NSArray *values = [NSArray arrayWithObjects:deviceUuid, nil];
    
    [self execute:@"DELETE FROM sync_data WHERE deviceId = $1::varchar AND type = 'object'" format:PGClientTupleFormatText
           values:values error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error);
        return NO;
    }
    
    return YES;
}

- (BOOL)clearMediaSyncData {
    NSString *deviceUuid = [[NSUserDefaults standardUserDefaults] stringForKey:@"UUID"];
    
    NSError *error = nil;
    NSArray *values = [NSArray arrayWithObjects:deviceUuid, nil];
    
    [self execute:@"DELETE FROM sync_data WHERE deviceId = $1::varchar AND type = 'media'" format:PGClientTupleFormatText
           values:values error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error);
        return NO;
    }
    
    return YES;
}

- (BOOL)saveMedia:(NSData *)data fileName:(NSString *)name {
    NSString *deviceUuid = [[NSUserDefaults standardUserDefaults] stringForKey:@"UUID"];
    
    BOOL exists = [self checkResultExists:@"SELECT filename FROM media WHERE filename = $1::varchar"
                                   values:[NSArray arrayWithObject:name]];
    if (!exists) {
        NSString *query = @"INSERT INTO media VALUES($1::varchar, $2::bytea, $3::varchar)";
        
        NSError *error = nil;
        NSArray *values = [NSArray arrayWithObjects:name, data, deviceUuid, nil];
        
        [self execute:query format:PGClientTupleFormatText values:values error:&error];
        
        if (error) {
            NSLog(@"Error: %@", error);
            return NO;
        }
    }
    
    return YES;
}

-(PGResult* )execute:(NSString* )query format:(PGClientTupleFormat)format values:(NSArray* )values error:(NSError** )error {
    if (![self isConnected]) {
        if ([self connect]) {
            PGResult *result = [self.pgConnection execute:query format:format values:values error:error];
            [self disconnect];
            
            return result;
        }
    } else {
        return [self.pgConnection execute:query format:format values:values error:error];
    }
    
    return nil;
}

-(PGResult* )execute:(NSString* )query format:(PGClientTupleFormat)format error:(NSError** )error {
    return [self execute:query format:format values:nil error:error];
}

@end
