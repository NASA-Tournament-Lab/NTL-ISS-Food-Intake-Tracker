//
//  DataUpdateService.h
//  ISSFoodIntakeTracker
//
//  Created by LokiYang on 2013-07-27.
//  Copyright (c) 2013 TopCoder Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @protocol DataUpdateService
 @discussion DataUpdateService protocol defines the method to apply data changes (control files) pushed
 from Earth Laboratory.
 @author flying2hk, LokiYang
 @version 1.0
 */
@protocol DataUpdateService <NSObject>

/*!
 @discussion This method will be used to apply data changes (control files) pushed from Earth Laboratory.
 @parame error The NSError object if any error occurred during the operation
 @return YES if the operation succceeds, otherwise NO.
 */
-(BOOL)update:(NSError **)error;
@end
