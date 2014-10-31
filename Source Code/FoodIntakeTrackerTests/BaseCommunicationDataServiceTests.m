// Copyright (c) 2013 TopCoder. All rights reserved.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//
//  BaseCommunicationDataServiceTests.m
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 7/12/13.
//

#import "BaseCommunicationDataServiceTests.h"
#import "DataHelper.h"

@implementation BaseCommunicationDataServiceTests

@synthesize service;

//Override setUp method
- (void)setUp
{
    [super setUp];
    
    //init service

    self.service = [[BaseCommunicationDataService alloc] initWithConfiguration:self.configurations];
}

//Override tearDown method
- (void)tearDown
{
    [super tearDown];
}

//Test constructor
- (void)testInitObject
{
    //assert service is not nil
    STAssertNotNil(self.service, @"service should not be nil");
    
    //assert configurations
    STAssertEqualObjects(self.service.sharedFileServerPath,
                         [self.configurations valueForKey:@"SharedFileServerPath"],
                         [@"shared file server path should be "
                          stringByAppendingString:[self.configurations valueForKey:@"SharedFileServerPath"]]);
    STAssertEqualObjects(self.service.sharedFileServerUsername,
                         [self.configurations valueForKey:@"SharedFileServerUsername"],
                         [@"username should be "
                          stringByAppendingString:[self.configurations valueForKey:@"SharedFileServerUsername"]]);
    STAssertEqualObjects(self.service.sharedFileServerPassword,
                         [self.configurations valueForKey:@"SharedFileServerPassword"],
                         [@"password should be "
                          stringByAppendingString:[self.configurations valueForKey:@"SharedFileServerPassword"]]);
}

@end
