//
//  DummyServiceImpl.m
//  ISSFoodIntakeTracker
//
//  Created by Xiaoyang Du on 2013-07-13.
//  Copyright (c) 2013 NASA. All rights reserved.
//

#import "DummyServiceImpl.h"

@implementation DummyServiceImpl

@synthesize lockAcquired;

-(void)acquireLock:(User *)user error:(NSError **)error {
    lockAcquired = YES;
}

-(void) releaseLock:(User*)user error:(NSError**)error {
    lockAcquired = NO;
}

-(void) sendLockHeartbeat:(User*)user error:(NSError**)error {
    
}

@end
