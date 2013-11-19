//
//  SynchronizationService.h
//  ISSFoodIntakeTracker
//
//  Created by LokiYang on 2013-07-27.
//  Copyright (c) 2013 TopCoder Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @protocol SynchronizationService
 @discussion SynchronizationService protocol defines the method to synchronize data between iPad devices.
    Specifically this service is responsible for
    1. Push local data changes to Samba Shared File Server.
    2. Pull data changes from other iPad devices and apply the data changes locally.
 @author flying2hk, LokiYang
 @version 1.0
 */
@protocol SynchronizationService <NSObject>

/*!
 @discussion This method will be used to synchronize the data. If the iPad device is currently not connected to Wi-Fi
    network, then this method will do nothing.
 @parame error The NSError object if any error occurred during the operation
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)synchronize:(NSError **)error;
@end
