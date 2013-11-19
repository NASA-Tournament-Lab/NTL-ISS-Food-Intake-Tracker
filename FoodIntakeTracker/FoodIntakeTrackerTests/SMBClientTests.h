//
//  SMBClientTests.h
//  ISSFoodIntakeTracker
//
//  Created by LokiYang on 8/5/13.
//  Copyright (c) 2013 TopCoder Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "BaseTests.h"
#import "SMBClient.h"

/*!
 @class SMBClientTests
 @discussion This is the unit test cases for SMBClient.
 @author LokiYang
 @version 1.0
 */
@interface SMBClientTests : BaseTests

/*!
 @discussion This value represents smbclient instance.
 */
@property (nonatomic, strong) id<SMBClient> smbClient;

/*!
 @discussion This value represents test folder in shared file server.
 */
@property (nonatomic, strong) NSString *testFolder;
@end
