//
//  WebserviceCoreData.m
//  FoodIntakeTracker
//
//  Created by pvmagacho on 5/31/16.
//  Copyright © pvmagacho All rights reserved.
//

#import "WebserviceCoreData.h"
#import "Reachability.h"
#import "Helper.h"
#import "Settings.h"
#import "AppDelegate.h"
#import "SLStreamParam.h"

#define kTimerInterval 30

@interface NSString (JRStringAdditions)

- (BOOL)containsString:(NSString *)string;
- (BOOL)containsString:(NSString *)string
               options:(NSStringCompareOptions)options;

@end

@implementation NSString (JRStringAdditions)

- (BOOL)containsString:(NSString *)string
               options:(NSStringCompareOptions)options {
    NSRange rng = [self rangeOfString:string options:options];
    return rng.location != NSNotFound;
}

- (BOOL)containsString:(NSString *)string {
    return [self containsString:string options:0];
}

@end

static WebserviceCoreData *instance;
static Reachability* reach;
static NSString* reachHostName = @"";

@interface NSURLRequest (DummyInterface)
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;
@end

@implementation WebserviceCoreData {
    BOOL canConnect;

    BOOL alertShow;

    UIAlertView *popupAlertView;

    NSTimer *pingTimer;

    NSDate *lastSync;

    NSMutableArray *mediaArray;

    NSInteger currentMedia;
}

+ (NSString *) base64EncodedStringFromString:(NSString *) string {
    NSData *data = [NSData dataWithBytes:[string UTF8String] length:[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    NSUInteger length = [data length];
    NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];

    uint8_t *input = (uint8_t *)[data bytes];
    uint8_t *output = (uint8_t *)[mutableData mutableBytes];

    for (NSUInteger i = 0; i < length; i += 3) {
        NSUInteger value = 0;
        for (NSUInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }

        static uint8_t const kAFBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

        NSUInteger idx = (i / 3) * 4;
        output[idx + 0] = kAFBase64EncodingTable[(value >> 18) & 0x3F];
        output[idx + 1] = kAFBase64EncodingTable[(value >> 12) & 0x3F];
        output[idx + 2] = (i + 1) < length ? kAFBase64EncodingTable[(value >> 6)  & 0x3F] : '=';
        output[idx + 3] = (i + 2) < length ? kAFBase64EncodingTable[(value >> 0)  & 0x3F] : '=';
    }

    return [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
}

+ (WebserviceCoreData *)instance {
    if (!instance) {
        NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
        NSString *ipAddress = [standardUserDefaults objectForKey:@"address_preference"];
        NSString *username = [standardUserDefaults objectForKey:@"user_preference"];
        NSString *password = [standardUserDefaults objectForKey:@"password_preference"];
        NSInteger port = [[standardUserDefaults objectForKey:@"port_preference"] integerValue];
        NSString *url = [NSString stringWithFormat:@"https://%@:%d/api", ipAddress, port];

        NSString *base64token = [WebserviceCoreData base64EncodedStringFromString:[NSString stringWithFormat:@"%@:%@", username, password]];

        instance = [[WebserviceCoreData alloc] init];
        instance.adapter = [LBRESTAdapter adapterWithURL:[NSURL URLWithString:url] allowsInvalidSSLCertificate:YES];
        [instance.adapter setAccessToken:[NSString stringWithFormat:@"Basic %@", base64token]];
    }

    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        [self startReachbility];
    }
    return self;
}

- (BOOL)connect_url {
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *ipAddress = [standardUserDefaults objectForKey:@"address_preference"];
    NSString *username = [standardUserDefaults objectForKey:@"user_preference"];
    NSString *password = [standardUserDefaults objectForKey:@"password_preference"];
    NSInteger port = [[standardUserDefaults objectForKey:@"port_preference"] integerValue];
    NSString *url = [NSString stringWithFormat:@"https://%@:%d/api/Categories", ipAddress, port];

    NSString *token = [WebserviceCoreData base64EncodedStringFromString:[NSString stringWithFormat:@"%@:%@", username, password]];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", token];


    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:30];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];

    NSError *error = nil;
    NSURLResponse *response = nil;
    [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[[NSURL URLWithString:url] host]];
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        NSLog(@"Connect error: %@", error);
    }
    return error == nil;
}

- (void)testPing {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Test ping");
        if ([self connect_url]) {
            @synchronized(self) {
                if (!canConnect) {
                    [self closeAllAlerts];
                    popupAlertView = [Helper showAlert:@"Connection Re-established"
                                               message:@"This iPad now has a network connection. Any food that you've entered will now be saved to the database."
                                              delegate:self];
                }
                canConnect = YES;
            }
        } else {
            @synchronized(self) {
                if (canConnect) {
                    [self closeAllAlerts];
                    popupAlertView = [Helper showAlert:@"Network Connection Error"
                                               message:@"This iPad has lost its network connection. You can still use the ISS FIT app, and we will attempt to sync with the central food database when it's available."
                                              delegate:self];
                }
                canConnect = NO;
            }
        }
    });
}

- (void)startReachbility {
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *ipAddress = [standardUserDefaults objectForKey:@"address_preference"];

    canConnect = YES;
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

        alertShow = false;

        // Update connect flag
        reach.reachableBlock = ^(Reachability*reach) {
            @synchronized(self) {
                if (canConnect) {
                    return;
                }

                canConnect = YES;
                NSLog(@"This iPad now has a network connection.");

                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    int retries = 3;
                    while (canConnect && retries > 0) {
                        // wait 500ms
                        [NSThread sleepForTimeInterval:0.5];

                        AppDelegate *appDelegate = AppDelegate.shareDelegate;
                        if (appDelegate.loggedInUser) {
                            NSInteger result = [appDelegate acquireLock:appDelegate.loggedInUser];
                            if (result == 0) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [[NSNotificationCenter defaultCenter] postNotificationName:ForceLogoutEvent object:nil];

                                    [Helper showAlert:@"Error"
                                              message:@"User already logged in another device."];
                                });
                                return;
                            } else if (result == -1) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [[appDelegate.loggedInUser managedObjectContext] lock];
                                    [[appDelegate.loggedInUser managedObjectContext] deleteObject:appDelegate.loggedInUser];
                                    [[appDelegate.loggedInUser managedObjectContext] save:nil];
                                    [[appDelegate.loggedInUser managedObjectContext] unlock];

                                    [[NSNotificationCenter defaultCenter] postNotificationName:ForceLogoutEvent object:nil];

                                    [Helper showAlert:@"Error" message:@"User was removed from database."];
                                });
                                return;
                            }
                        }

                        // sync to database
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"DataSyncUpdate" object:[NSDate date]];

                        retries--;
                    }
                });

                [self closeAllAlerts];
                popupAlertView = [Helper showAlert:@"Connection Re-established"
                                           message:@"This iPad now has a network connection. Any food that you've entered will now be saved to the database."
                                          delegate:self];
            }
        };

        // Update connect flag and disconnect from server (this actualy is a clean up of the
        // library.
        reach.unreachableBlock = ^(Reachability*reach) {
            @synchronized(self) {
                if (!canConnect) {
                    return;
                }

                canConnect = NO;
                NSLog(@"This iPad has lost its network connection.");

                [self closeAllAlerts];
                popupAlertView = [Helper showAlert:@"Network Connection Error"
                                           message:@"This iPad has lost its network connection. You can still use the ISS FIT app, and we will attempt to sync with the central food database when it's available."
                                          delegate:self];
            }
        };

        // Start the notifier, which will cause the reachability object to retain itself!
        [reach startNotifier];

        // Wait 500ms
        [NSThread sleepForTimeInterval:0.5];

        // query status at first try
        canConnect = [reach isReachable];
    }

    if (!pingTimer) {
        pingTimer = [NSTimer timerWithTimeInterval:kTimerInterval target:self selector:@selector(testPing) userInfo:nil
                                           repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:pingTimer forMode:NSDefaultRunLoopMode];
    }
}

- (BOOL)connect {
    if (canConnect) {
        [self closeAllAlerts];
        canConnect = [self connect_url];
    } else {
        NSLog(@"Unreachable");
    }
    return canConnect;
}

- (BOOL)registerDevice {
    NSString *deviceUuid = [[NSUserDefaults standardUserDefaults] stringForKey:@"UUID"];
    LBPersistedModelRepository *rep = [instance.adapter repositoryWithPersistedModelName:@"Devices"];
    LBPersistedModel *model = (LBPersistedModel *) [ rep modelWithDictionary:@{ @"deviceUuid" : deviceUuid } ];

    __block NSInteger result = -1;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [model saveWithSuccess:^{
            [[NSUserDefaults standardUserDefaults] setObject:model._id forKey:@"DEVICE_UUID"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            result = 1;
        } failure:^(NSError *error) {
            NSLog(@"Error at registerDevice: %@", error);
            result = 0;
        }];
    });

    while (result < 0) {
        [NSThread sleepForTimeInterval:0.5];
    }

    return result;
}

- (BOOL)checkId:(NSString *)theId {
    LBPersistedModelRepository *rep = [instance.adapter repositoryWithPersistedModelName:@"Devices"];

    __block NSInteger result = -1;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [rep findById:theId success:^(LBModel *model){
            result = 1;
        } failure:^(NSError *error){
            NSLog(@"Error at checkId: %@", error);
            result = 0;
        }];
    });

    while (result < 0) {
        [NSThread sleepForTimeInterval:0.5];
    }

    return result == 1;
}

- (BOOL)checkDeviceId {
    NSString *deviceUuid = [[NSUserDefaults standardUserDefaults] stringForKey:@"UUID"];
    LBPersistedModelRepository *rep = [instance.adapter repositoryWithPersistedModelName:@"Devices"];

    __block NSInteger result = -1;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [rep allWithSuccess:^(NSArray *models) {
            for (LBModel *model in models) {
                NSDictionary *dict = [model toDictionary];
                if ([[dict objectForKey:@"deviceUuid"] isEqualToString:deviceUuid]) {
                    result = 1;
                    return;
                }
            }
            result = 0;
        } failure:^(NSError *error) {
            NSLog(@"Error checkDeviceId: %@", error);
            result = 0;
        }];
    });

    while (result < 0) {
        [NSThread sleepForTimeInterval:0.5];
    }

    return result == 1;
}

- (NSArray *)fetchAllObjects {
    NSArray *prototypes = @[ @"Categories", @"Origins", @"FoodProductFilters", @"NasaUsers", @"FoodProducts", @"AdhocFoodProducts",
                             @"FoodProductRecords" ];
    NSArray *names = @[ @"Category", @"Origin",  @"FoodProductFilter", @"User",  @"FoodProduct", @"AdhocFoodProduct",
                        @"FoodConsumptionRecord" ];
    NSMutableArray *array = [NSMutableArray array];

    __block NSInteger currentIndex = 0;
    __block NSInteger result = -1;

    SLFailureBlock error = ^(NSError *error) {
        NSLog(@"Error fetchAllObjects: %@", error);
        [array removeAllObjects];
        result = 0;
    };

    __block LBPersistedModelAllSuccessBlock success = ^(NSArray *models) {
        NSString *property = [prototypes objectAtIndex:currentIndex];
        for (LBModel *model in models) {
            [array addObject:@{
                @"name" : names[currentIndex],
                @"id" : [[model toDictionary] objectForKey:@"id"],
                @"value": [model toDictionary]
            }];
        }

        if (++currentIndex < prototypes.count) {
            property = [prototypes objectAtIndex:currentIndex];
            [self getAll:property success:success failure:error];
        } else {
            result = 1;
        }
    };

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *property = [prototypes objectAtIndex:currentIndex];
        [self getAll:property success:success failure:error];
    });

    while (result < 0) {
        [NSThread sleepForTimeInterval:0.5];
    }

    return array;
}

- (NSArray *)fetchAllMedia {
    return [self getModels:@"Media"];
}

- (NSArray *)fetchObjects {
    NSArray *prototypes = @[ @"NasaUsers", @"FoodProductFilters", @"FoodProducts", @"AdhocFoodProducts", @"FoodProductRecords" ];
    NSArray *names = @[ @"User", @"FoodProductFilter", @"FoodProduct", @"AdhocFoodProduct", @"FoodConsumptionRecord" ];
    __block NSInteger currentIndex = 0;
    __block NSMutableArray *array = [NSMutableArray array];
    __block NSInteger result = -1;

    SLFailureBlock error = ^(NSError *error) {
        NSLog(@"Error fetchObjects: %@", error);
        [array removeAllObjects];
        result = 0;
    };

    __block SLSuccessBlock success = ^(NSArray *models) {
        NSString *property = [prototypes objectAtIndex:currentIndex];
        for (LBModel *model in models) {
            [array addObject:@{
                               @"name" : names[currentIndex],
                               @"id" : [[model toDictionary] objectForKey:@"id"],
                               @"value": [model toDictionary]
                               }];
        }

        if (++currentIndex < prototypes.count) {
            property = [prototypes objectAtIndex:currentIndex];
            [self getFilteredAll:property success:success failure:error];
        } else {
            result = 1;
        }
    };

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *property = [prototypes objectAtIndex:currentIndex];
        [self getFilteredAll:property success:success failure:error];
    });

    while (result < 0) {
        [NSThread sleepForTimeInterval:0.5];
    }
    
    return array;
}


- (NSArray *)fetchMedias {
    NSMutableArray *array = [NSMutableArray array];

    __block NSInteger result = -1;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getFilteredAll:@"Media" success:^(NSArray *models){
            for (LBModel *model in models) {
                [array addObject:[model toDictionary]];
            }
            result = 1;
        } failure:^(NSError *error) {
            NSLog(@"Error fetchMedias: %@", error);
            [array removeAllObjects];
            result = 0;
        }];
    });

    while (result < 0) {
        [NSThread sleepForTimeInterval:0.5];
    }

    return array;
}

- (NSString *)insertMediaRecord:(NSDictionary *)dict foodConsumptionId:(NSString *)foodConsumptionId pattern:(NSString *)pattern {
    LBPersistedModelRepository *rep = [instance.adapter repositoryWithPersistedModelName:@"FoodProductRecords"];
    [instance.adapter.contract addItem:[SLRESTContractItem itemWithPattern:[NSString
                                                                            stringWithFormat:@"/FoodProductRecords/:id/%@", pattern]
                                                                      verb:@"POST"]
                             forMethod:[NSString stringWithFormat:@"FoodProductRecords.%@", pattern]];

    __block LBPersistedModel *model = nil;
    __block NSInteger result = -1;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [rep invokeStaticMethod:pattern parameters:@{ @"id" : foodConsumptionId } bodyParameters:dict
                        success:^ (id value) {
                            LBPersistedModelRepository *mediaRep = [instance.adapter repositoryWithPersistedModelName:@"Media"];
                            model = (LBPersistedModel * ) [mediaRep modelWithDictionary:value];
                            result = 1;
                        } failure:^(NSError *error) {
                            NSLog(@"Error insertMediaRecord: %@", error);
                            result = 0;
                        }];
    });

    while (result < 0) {
        [NSThread sleepForTimeInterval:0.5];
    }

    return [model _id];
}

- (BOOL)uploadMedia:(NSString *) theId withData:(NSData *) data withFilename:(NSString *) filename {
    LBPersistedModelRepository *rep = [instance.adapter repositoryWithPersistedModelName:@"Media"];
    [instance.adapter.contract addItem:[SLRESTContractItem itemWithPattern:@"/media/upload/:id"
                                                                      verb:@"POST"
                                                                 multipart:YES] forMethod:@"Media.upload"];

    __block NSInteger result = -1;
    NSInputStream *inputStream = [[NSInputStream alloc] initWithData:data];
    NSString *contentType = [filename hasSuffix:@"jpg"] ? @"image/jpg" : @"audio/aac";
    SLStreamParam *param = [SLStreamParam streamParamWithInputStream:inputStream
                                                            fileName:filename contentType:contentType
                                                              length:data.length];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [rep.adapter invokeStaticMethod:@"Media.upload" parameters:@{ @"id": theId, @"file": param } bodyParameters:nil
                           outputStream:nil
                                success:^(id values) {
                                    result = 1;
                                } failure:^(NSError *error) {
                                    NSLog(@"Error uploadMedia: %@", error);
                                    result = 0;
                                }];
    });

    while (result < 0) {
        [NSThread sleepForTimeInterval:0.5];
    }

    return result == 1;
}

- (NSString *)saveMedia:(NSDictionary *) dict {
    NSData *data = [dict objectForKey:@"data"];

    NSMutableDictionary *mDict = [dict mutableCopy];
    [mDict removeObjectForKey:@"data"];

    // save the media
    NSString *newId = [self insertObject:@"Media" model:mDict];

    // save the data
    if (newId && data) {
        [self uploadMedia:newId withData:data withFilename:dict[@"filename"]];
    }
    
    return newId;
}

- (NSInteger)insertUserLock:(NSString *) userId {
    NSString *deviceUuid = [[NSUserDefaults standardUserDefaults] stringForKey:@"DEVICE_UUID"];
    LBPersistedModelRepository *rep = [instance.adapter repositoryWithPersistedModelName:@"UserLocks"];
    LBPersistedModel *model = (LBPersistedModel *) [ rep modelWithDictionary:@{ @"userId" : userId, @"deviceId" : deviceUuid } ];

    __block NSInteger result = -2;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [model saveWithSuccess:^{
            result = 1;
        } failure:^(NSError *error) {
            NSLog(@"Error insertUserLock: %@", error);
            NSError *err = nil;
            NSString *string = [[error userInfo] objectForKey:@"NSLocalizedRecoverySuggestion"];
            if (string.length > 0) {
                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding]
                                                                           options:NSJSONReadingMutableContainers error:&err];
                NSDictionary *error = [dictionary objectForKey:@"error"];
                if (error &&
                    [[error objectForKey:@"routine"] isEqualToString:@"ri_ReportViolation"] &&
                    [[error objectForKey:@"message"] containsString:@"user_user_lock_fk"]) {
                    result = -1;
                    return;
                }
            }

            result = 0;
        }];
    });

    while (result == -2) {
        [NSThread sleepForTimeInterval:0.5];
    }

    return result;
}

- (BOOL)removeUserLock {
    LBPersistedModelRepository *rep = [instance.adapter repositoryWithPersistedModelName:@"UserLocks"];
    [instance.adapter.contract addItem:[SLRESTContractItem itemWithPattern:@"/UserLocks" verb:@"DELETE"] forMethod:@"UserLocks.deleteAll"];

    NSString *deviceUuid = [[NSUserDefaults standardUserDefaults] stringForKey:@"DEVICE_UUID"];
    __block NSInteger result = -1;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [rep invokeStaticMethod:@"deleteAll"
                     parameters:@{ @"filter[where][deviceId]" : deviceUuid } success:^(id value) {
                         result = 1;
                     } failure:^(NSError *error) {
                         NSLog(@"Error removeUserLock: %@", error);
                         result = 0;
                     }];
    });

    while (result < 0) {
        [NSThread sleepForTimeInterval:0.5];
    }

    return result == 1;
}

- (NSArray *)fetchUserLocks {
    return [self getModels:@"UserLocks"];
}

- (NSArray *)getModels:(NSString *) prototypename {
    NSMutableArray *array = [NSMutableArray array];

    __block NSInteger result = -1;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getAll:prototypename success:^(NSArray *models) {
            for (LBModel *model in models) {
                [array addObject:[model toDictionary]];
            }
            result = 1;
        } failure:^(NSError *error) {
            NSLog(@"Error getModels: %@", error);
            [array removeAllObjects];
            result = 0;
        }];
    });

    while (result < 0) {
        [NSThread sleepForTimeInterval:0.5];
    }

    return array;
}

- (BOOL)startFetchMedia {
    currentMedia = 0;
    return YES;
}

- (BOOL)endFetchMedia {
    return YES;
}

- (NSArray *)fetchNextMedia {
    NSMutableArray *array = [NSMutableArray array];
    NSOutputStream *outputStream = [[NSOutputStream alloc] initToMemory];
    LBPersistedModelRepository *rep = [instance.adapter repositoryWithPersistedModelName:@"Media"];
    [instance.adapter.contract addItem:[SLRESTContractItem itemWithPattern:@"/media/download/:id"
                                                                      verb:@"GET"] forMethod:@"Media.download"];

    NSMutableDictionary *objMedia = [[mediaArray objectAtIndex:currentMedia] mutableCopy];
    __block NSInteger result = -1;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [rep invokeStaticMethod:@"download"
                     parameters:@{ @"id": [objMedia objectForKey:@"id"] }
                   outputStream:outputStream
                        success:^(id values) {
                [objMedia setObject:values forKey:@"data"];
                [array addObject:objMedia];
                result = 1;
           } failure:^(NSError *error) {
                NSLog(@"Error fetchNextMedia: %@", error);
                [array removeAllObjects];
                result = 0;
           }];
    });

    while (result < 0) {
        [NSThread sleepForTimeInterval:0.5];
    }
    
    currentMedia++;

    return array;
}

- (NSInteger)fetchMediaCount {
    mediaArray = [NSMutableArray array];
    LBPersistedModelRepository *rep = [instance.adapter repositoryWithPersistedModelName:@"Media"];
    [instance.adapter.contract addItem:[SLRESTContractItem itemWithPattern:@"/media"
                                                                      verb:@"GET"] forMethod:@"Media.filter"];

    __block NSInteger result = -1;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [rep invokeStaticMethod:@"filter" parameters:@{ @"filter[fields][data]": @"false", }
            success:^(id value) {
                NSAssert([[value class] isSubclassOfClass:[NSArray class]], @"Received non-Array: %@", value);

                [value enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [mediaArray addObject:obj];
                }];

                result = 1;
            } failure:^(NSError *error) {
                NSLog(@"Error fetchMediaCount: %@", error);
                mediaArray = nil;
                result = 0;
            }];
    });
    
    while (result < 0) {
        [NSThread sleepForTimeInterval:0.5];
    }
    
    return [mediaArray count];
}

- (BOOL)clearMediaSyncData {
    return YES;
}

- (BOOL)clearObjectSyncData {
    return YES;
}

- (NSString *)insertObject:(NSString *)prototypeName model:(NSDictionary *) dict {
    LBPersistedModelRepository *rep = [instance.adapter repositoryWithPersistedModelName:prototypeName];
    LBPersistedModel *model = (LBPersistedModel *) [rep modelWithDictionary:dict];

    __block NSInteger result = -1;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SLFailureBlock failure = ^(NSError *error) {
            NSLog(@"Error at insertObject: %@", error);
            result = 0;
        };

        [model saveWithSuccess:^{
            result = 1;
        } failure:failure];
    });

    while (result < 0) {
        [NSThread sleepForTimeInterval:0.5];
    }

    return result > 0 ? [model _id] : nil;
}

#pragma mark - private methods

- (void)getFilteredAll:(NSString *) prototypename success:(SLSuccessBlock)success failure:(SLFailureBlock)failure {
    NSString *pattern = [NSString stringWithFormat:@"/%@", [prototypename lowercaseString]];
    NSString *method = [NSString stringWithFormat:@"%@.filterAll", prototypename];
    LBPersistedModelRepository *rep = [instance.adapter repositoryWithPersistedModelName:prototypename];
    [instance.adapter.contract addItem:[SLRESTContractItem itemWithPattern:pattern verb:@"GET"] forMethod:method];

    NSNumber *lastSyncTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastSynchronizedTime"];
    if (lastSyncTime != nil) {
        const NSTimeInterval intervalMin = 10 * 60; // 10 minutes
        lastSync = [NSDate dateWithTimeIntervalSince1970:(lastSyncTime.doubleValue - intervalMin)];
    }

    [rep invokeStaticMethod:@"filterAll" parameters:@{ @"filter[where][modifiedDate][gt]" : lastSync } success:^(id value) {
        NSAssert([[value class] isSubclassOfClass:[NSArray class]], @"Received non-Array: %@", value);

        NSMutableArray *models = [NSMutableArray array];

        [value enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [models addObject:[rep modelWithDictionary:obj]];
        }];

        success(models);
    } failure:failure];
}

- (void)getAll:(NSString *) prototypename success:(LBPersistedModelAllSuccessBlock)success failure:(SLFailureBlock)failure {
    //Error Block
    LBPersistedModelRepository *rep = [instance.adapter repositoryWithPersistedModelName:prototypename];
    [rep allWithSuccess:success failure:failure];
}

- (void)closeAllAlerts {
    if (popupAlertView) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [popupAlertView dismissWithClickedButtonIndex:0 animated:NO];
        });
    }
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    alertShow = NO;
    popupAlertView = nil;
}

@end
