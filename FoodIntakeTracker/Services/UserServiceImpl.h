//
//  UserService.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 2013-07-10.
//  Copyright (c) 2013 TopCoder. All rights reserved.
//

#import "BaseDataService.h"
#import "Models.h"
#import "LockService.h"
#import "UserService.h"

/*!
 @class UserServiceImpl
 @discussion This class is the default implementation which conform to UserService protocol.
 @author flying2hk, duxiaoyang, LokiYang
 @version 1.1
 @changes from 1.0
    1.Fixed " Method accepting NSError** should have a non-void return value to indicate whether or not an error
    occurred". Add a BOOL return to indicate whether the operation succeeds.
 */
@interface UserServiceImpl : BaseDataService<UserService>

/*!
 @property Represent the lock service.
 */
@property (nonatomic, readonly, strong) id<LockService> lockService;

/*!
 @property Represent the permission dictionary.
 */
@property (nonatomic, readonly, strong) NSDictionary *permissions;

/*!
 @discussion Initialize the class instance with given parameters.
 @param context The NSManagedObjectContext.
 @param configuration The configuration.
 @param lockService The LockService.
 @return The newly created object.
 */
-(id)initWithConfiguration:(NSDictionary *)configuration
               lockService:(id<LockService>)lockService;

@end
