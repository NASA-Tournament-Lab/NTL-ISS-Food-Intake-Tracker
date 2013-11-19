//
//  SMBClientImpl.h
//  ISSFoodIntakeTracker
//
//  Created by LokiYang on 2013-07-27.
//  Copyright (c) 2013 TopCoder Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMBClient.h"
#import "KxSMBProvider.h"

/*!
 @class LockServiceImpl
 @discussion This is the default implementation of SMBClient protocol.
 @author flying2hk, LokiYang
 @version 1.0
 */
@interface SMBClientImpl : NSObject<SMBClient>

/*!
 @discussion Represents the path of the shared file server.
 */
@property (nonatomic, strong, readonly) NSString *serverRootPath;
@end
