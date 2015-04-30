//
//  PGCoreData.h
//  PGCoreData
//
//  Created by pvmagacho on 8/4/14.
//  Copyright (c) 2014 Topcoder Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "PGClientKit.h"

@interface PGCoreData : NSObject<UIAlertViewDelegate>

@property PGConnection *pgConnection;

+ (PGCoreData *) instance;

- (BOOL)connect;
- (void)disconnect;
- (BOOL)isConnected;
- (BOOL)registerDevice;
- (BOOL)checkDeviceId;
- (BOOL)checkId:(NSString *) theId;
- (BOOL)checkResultExists:(NSString *)query values:(NSArray *) values;
- (NSArray *)fetchAllObjects;
- (NSArray *)fetchObjects;
- (NSArray *)fetchMedias;
- (NSArray *)fetchAllMedia;
- (BOOL)startFetchMedia;
- (BOOL)endFetchMedia;
- (NSDictionary *)fetchNextMedia;
- (NSInteger)fetchMediaCount;
- (BOOL)clearMediaSyncData;
- (BOOL)clearObjectSyncData;
- (BOOL)saveMedia:(NSData *)data fileName:(NSString *)name;

@end
