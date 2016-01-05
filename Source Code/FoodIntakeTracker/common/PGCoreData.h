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

@interface PGCoreData : NSObject<UIAlertViewDelegate, PGConnectionDelegate>

@property PGConnection *pgConnection;

+ (PGCoreData *) instance;
+ (void)deleteInstance;

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
- (BOOL)insertUserLock:(User *) user;
- (BOOL)removeUserLock;
- (NSArray *)fetchUserLocks;
- (BOOL)startFetchMedia;
- (BOOL)endFetchMedia;
- (NSArray *)fetchNextMedia;
- (NSInteger)fetchMediaCount;
- (BOOL)clearMediaSyncData;
- (BOOL)clearObjectSyncData;
- (BOOL)saveMedia:(NSData *)data fileName:(NSString *)name;
-(PGResult* )execute:(NSString* )query format:(PGClientTupleFormat)format values:(NSArray* )values error:(NSError** )error;

@end
