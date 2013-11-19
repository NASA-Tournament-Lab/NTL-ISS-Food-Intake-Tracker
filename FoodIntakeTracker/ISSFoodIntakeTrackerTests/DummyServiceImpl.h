//
//  DummyServiceImpl.h
//  ISSFoodIntakeTracker
//
//  Created by Xiaoyang Du on 2013-07-13.
//  Copyright (c) 2013 NASA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LockService.h"

@interface DummyServiceImpl : NSObject<LockService>

@property (nonatomic) BOOL lockAcquired;

@end
