//
//  SynchronizationServiceImpl.h
//  ISSFoodIntakeTracker
//
//  Created by LokiYang on 2013-07-27.
//  Copyright (c) 2013 TopCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseCommunicationDataService.h"
#import "SynchronizationService.h"


/*!
 @class SynchronizationServiceImpl
 @discussion This is the default implementation of SynchronizationService protocol.
 @author flying2hk, LokiYang, subchap, supercharger
 @version 1.0
 */
@interface SynchronizationServiceImpl : BaseCommunicationDataService<SynchronizationService>

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
