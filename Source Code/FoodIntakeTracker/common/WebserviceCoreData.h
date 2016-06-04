//
//  WebserviceCoreData.h
//  FoodIntakeTracker
//
//  Created by PAULO VITOR MAGACHO DA SILVA on 5/31/16.
//  Copyright © 2016 topcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LoopBack/LoopBack.h>

@interface WebserviceCoreData : NSObject<UIAlertViewDelegate>

@property(nonatomic) LBRESTAdapter *adapter;

+ (WebserviceCoreData *) instance;

- (BOOL)connect;
- (BOOL)registerDevice;
- (BOOL)checkDeviceId;
- (BOOL)checkId:(NSString *) theId;
- (NSArray *)fetchAllObjects;
- (NSArray *)fetchAllMedia;
- (NSArray *)fetchObjects;
- (NSArray *)fetchMedias;
- (BOOL)insertUserLock:(User *) user;
- (BOOL)removeUserLock;
- (NSArray *)fetchUserLocks;
- (BOOL)startFetchMedia;
- (BOOL)endFetchMedia;
- (NSArray *)fetchNextMedia;
- (NSInteger)fetchMediaCount;
- (BOOL)clearMediaSyncData;
- (BOOL)clearObjectSyncData;

- (NSString *)insertMediaRecord:(NSDictionary *) dict foodConsumptionId:(NSString *)foodConsumptionId pattern:(NSString *) pattern;
- (NSString *)saveMedia:(NSDictionary *) dict;
- (NSString *)inserObject:(NSString *)prototypeName model:(NSDictionary *) dict;

@end
