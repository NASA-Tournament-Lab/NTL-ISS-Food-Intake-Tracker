//
//  WebserviceCoreData.h
//  FoodIntakeTracker
//
//  Created by pvmagacho on 5/31/16.
//  Copyright © pvmagacho All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LoopBack/LoopBack.h>

@interface WebserviceCoreData : NSObject<UIAlertViewDelegate>

@property(nonatomic) LBRESTAdapter *adapter;

+ (WebserviceCoreData *) instance;

- (BOOL)canConnect;
- (BOOL)connect;
- (BOOL)registerDevice;
- (BOOL)checkDeviceId;
- (BOOL)checkId:(NSString *) theId;
- (NSArray *)fetchAllObjects;
- (NSArray *)fetchAllMedia;
- (NSArray *)fetchObjects;
- (NSArray *)fetchMedias;
- (NSInteger)insertUserLock:(NSString *) userId;
- (BOOL)removeUserLock;
- (NSArray *)fetchUserLocks;
- (BOOL)startFetchMedia;
- (BOOL)endFetchMedia;
- (NSArray *)fetchNextMedia;
- (NSInteger)fetchMediaCount;
- (BOOL)clearMediaSyncData;
- (BOOL)clearObjectSyncData;

- (NSString *)insertMediaRecord:(NSDictionary *) dict foodConsumptionId:(NSString *)foodConsumptionId pattern:(NSString *) pattern;
- (BOOL)uploadMedia:(NSString *) theId withData:(NSData *) data withFilename:(NSString *) filename;
- (NSString *)saveMedia:(NSDictionary *) dict;
- (NSString *)insertObject:(NSString *)prototypeName model:(NSDictionary *) dict;

@end
