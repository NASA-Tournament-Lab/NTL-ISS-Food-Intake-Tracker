//
//  BaseCommunicationDataServiceTests.h
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 7/12/13.
//  Copyright (c) 2013 tc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "BaseCommunicationDataService.h"
#import "BaseTests.h"

/*!
 @class BaseCommunicationDataServiceTests
 @discussion This is the unit test cases for BaseCommunicationDataService.
 @author duxiaoyang, LokiYang
 @version 1.1
 @changes from 1.0
    1. Add SMBClient support.
 */
@interface BaseCommunicationDataServiceTests : BaseTests

//Represents BaseCommunicationDataService instance for test
@property (nonatomic, strong) BaseCommunicationDataService *service;


@end
