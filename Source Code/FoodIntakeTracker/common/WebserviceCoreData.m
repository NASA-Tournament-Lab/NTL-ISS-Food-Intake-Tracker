//
//  WebserviceCoreData.m
//  FoodIntakeTracker
//
//  Created by PAULO VITOR MAGACHO DA SILVA on 5/31/16.
//  Copyright © 2016 topcoder. All rights reserved.
//

#import "WebserviceCoreData.h"
#import "Reachability.h"
#import "Helper.h"
#import "Settings.h"
#import "AppDelegate.h"

#define kTimerInterval 60

static WebserviceCoreData *instance;
static Reachability* reach;
static NSString* reachHostName = @"";

@implementation WebserviceCoreData {
    BOOL canConnect;

    BOOL alertShow;

    NSTimer *pingTimer;

    NSInteger currentMedia;

    NSDate *lastSync;
}

+ (WebserviceCoreData *)instance {
    if (!instance) {
        NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
        NSString *ipAddress = [standardUserDefaults objectForKey:@"address_preference"];
        NSInteger port = [[standardUserDefaults objectForKey:@"port_preference"] integerValue];
        NSString *url = [NSString stringWithFormat:@"http://%@:%d/api", ipAddress, port];

        instance = [[WebserviceCoreData alloc] init];
        instance.adapter = [LBRESTAdapter adapterWithURL:[NSURL URLWithString:url]];
    }
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLastSync:) name:UpdateLastSync object:nil];
        [self startReachbility];
    }
    return self;
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
                        if (![appDelegate acquireLock:appDelegate.loggedInUser]) {
                            [Helper showAlert:@"Error"
                                      message:@"User already logged in another device."];

                            [[NSNotificationCenter defaultCenter] postNotificationName:ForceLogoutEvent object:nil];
                            return;
                        }

                        // sync to database
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"DataSyncUpdate" object:[NSDate date]];

                        retries--;
                    }
                });

                if (!alertShow) {
                    alertShow = YES;
                    [Helper showAlert:@"Connection Re-established"
                              message:@"This iPad now has a network connection. Any food that you've entered will now be saved to the database."
                             delegate:self];
                }
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

                if (!alertShow) {
                    alertShow = YES;
                    [Helper showAlert:@"Network Connection Error"
                              message:@"This iPad has lost its network connection. You can still use the ISS FIT app, and we will attempt to sync with the central food database when it's available."
                             delegate:self];
                }
            }
        };

        // Start the notifier, which will cause the reachability object to retain itself!
        [reach startNotifier];

        // Wait 500ms
        [NSThread sleepForTimeInterval:0.5];

        // query status at first try
        canConnect = [reach isReachable];
    }
}

- (BOOL)connect {
    if (!canConnect) {
        NSLog(@"Unreachable");
    } else {
        NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
        NSString *ipAddress = [standardUserDefaults objectForKey:@"address_preference"];
        NSInteger port = [[standardUserDefaults objectForKey:@"port_preference"] integerValue];
        NSString *url = [NSString stringWithFormat:@"http://%@:%d/api", ipAddress, port];

        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                                 cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                             timeoutInterval:30];
        NSError *error = nil;
        NSURLResponse *response = nil;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (error) {
            canConnect = NO;
        }
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
            NSLog(@"Error: %@", error);
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
            NSLog(@"Error: %@", error);
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
            NSLog(@"Error: %@", error);
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
        NSLog(@"Error: %@", error);
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
        NSLog(@"Error: %@", error);
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
            NSLog(@"Error: %@", error);
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
    [instance.adapter.contract addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/FoodProductRecords/:id/%@", pattern] verb:@"POST"]
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
                            NSLog(@"Error: %@", error);
                            result = 0;
                        }];
    });

    while (result < 0) {
        NSLog(@"waiting");
        [NSThread sleepForTimeInterval:0.5];
    }

    return [model _id];
}

- (NSString *)saveMedia:(NSDictionary *) dict {
    return [self inserObject:@"Media" model:dict];
}

- (BOOL)insertUserLock:(User *) user {
    NSString *deviceUuid = [[NSUserDefaults standardUserDefaults] stringForKey:@"DEVICE_UUID"];
    LBPersistedModelRepository *rep = [instance.adapter repositoryWithPersistedModelName:@"UserLocks"];
    LBPersistedModel *model = (LBPersistedModel *) [ rep modelWithDictionary:@{ @"userId" : user.id, @"deviceId" : deviceUuid } ];

    __block NSInteger result = -1;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [model saveWithSuccess:^{
            result = 1;
        } failure:^(NSError *error) {
            NSLog(@"Error: %@", error);
            result = 0;
        }];
    });

    while (result < 0) {
        [NSThread sleepForTimeInterval:0.5];
    }

    return result == 1;
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
    LBPersistedModelRepository *rep = [instance.adapter repositoryWithPersistedModelName:@"Media"];
    [instance.adapter.contract addItem:[SLRESTContractItem itemWithPattern:@"/media" verb:@"GET"] forMethod:@"Media.filter"];

    __block NSInteger result = -1;
    NSNumber *skip = [NSNumber numberWithInteger:currentMedia];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [rep invokeStaticMethod:@"filter" parameters:@{ @"filter[limit]": @10, @"filter[skip]": skip }
                        success:^(id value) {
            NSAssert([[value class] isSubclassOfClass:[NSArray class]], @"Received non-Array: %@", value);

            NSMutableArray *models = [NSMutableArray array];

            [value enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [array addObject:obj];
            }];

            currentMedia += models.count;
            result = 1;
        } failure:^(NSError *error) {
            NSLog(@"Error: %@", error);
            [array removeAllObjects];
            result = 0;
        }];
    });

    while (result < 0) {
        [NSThread sleepForTimeInterval:0.5];
    }

    return array;
}

- (NSInteger)fetchMediaCount {
    LBPersistedModelRepository *rep = [instance.adapter repositoryWithPersistedModelName:@"Media"];
    [instance.adapter.contract addItem:[SLRESTContractItem itemWithPattern:@"/media" verb:@"GET"] forMethod:@"Media.count"];

    __block NSInteger count = 0;
    __block NSInteger result = -1;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [rep invokeStaticMethod:@"count" parameters:nil success:^(NSArray *value){
            count = [[value.lastObject objectForKey:@"count"] integerValue];
            result = 1;
        } failure:^(NSError *error){
            NSLog(@"Error: %@", error);
            result = 0;
        }];
    });

    while (result < 0) {
        [NSThread sleepForTimeInterval:0.5];
    }

    return count;
}

- (BOOL)clearMediaSyncData {
    return YES;
}

- (BOOL)clearObjectSyncData {
    return YES;
}

- (NSString *)inserObject:(NSString *)prototypeName model:(NSDictionary *) dict {
    LBPersistedModelRepository *rep = [instance.adapter repositoryWithPersistedModelName:prototypeName];
    LBPersistedModel *model = (LBPersistedModel *) [rep modelWithDictionary:dict];

    __block NSInteger result = -1;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{


        SLFailureBlock failure = ^(NSError *error) {
            NSLog(@"Error: %@", error);
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

- (void)updateLastSync:(NSNotification *) notif {
    lastSync = notif.object;
}

- (void)getFilteredAll:(NSString *) prototypename success:(SLSuccessBlock)success failure:(SLFailureBlock)failure {
    NSString *pattern = [NSString stringWithFormat:@"/%@", [prototypename lowercaseString]];
    NSString *method = [NSString stringWithFormat:@"%@.filterAll", prototypename];
    LBPersistedModelRepository *rep = [instance.adapter repositoryWithPersistedModelName:prototypename];
    [instance.adapter.contract addItem:[SLRESTContractItem itemWithPattern:pattern verb:@"GET"] forMethod:method];

    if (!lastSync) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *lastSyncTime = [defaults objectForKey:@"LastSynchronizedTime"];
        if (lastSyncTime != nil) {
            lastSync = [NSDate dateWithTimeIntervalSince1970:[lastSyncTime longLongValue]/1000];
        }
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

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    alertShow = NO;
}

@end
