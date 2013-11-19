//
//  DataUpdateServiceImpl.h
//  ISSFoodIntakeTracker
//
//  Created by LokiYang on 2013-07-27.
//  Copyright (c) 2013 TopCoder Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseCommunicationDataService.h"
#import "DataUpdateService.h"

/*!
 @class DataUpdateServiceImpl
 @discussion This is the default implementation of DataUpdateService protocol.
 @author flying2hk, LokiYang
 @version 1.0
 */
@interface DataUpdateServiceImpl : BaseCommunicationDataService<DataUpdateService>

/*!
 @discussion This value represents the local file system directory to save the image and voice recording files. 
 Can't be null or empty.
 */
@property (nonatomic, readonly, strong) NSString *localFileSystemDirectory;

/*!
 @discussion This value represents image file name suffix.
 */
@property (nonatomic, readonly, strong) NSString *imageFileNameSuffix;

/*!
 @discussion This value represents voice recording file name suffix.
 */
@property (nonatomic, readonly, strong) NSString *voiceRecordingFileNameSuffix;
@end
