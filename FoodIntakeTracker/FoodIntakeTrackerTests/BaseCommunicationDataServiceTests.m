//
//  BaseCommunicationDataServiceTests.m
//  ISSFoodIntakeTracker
//
//  Created by duxiaoyang on 7/12/13.
//  Copyright (c) 2013 tc. All rights reserved.
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
    STAssertEqualObjects(self.service.sharedFileServerWorkgroup,
                         [self.configurations valueForKey:@"SharedFileServerWorkgroup"],
                         [@"shared file server workgroup should be "
                          stringByAppendingString:[self.configurations valueForKey:@"SharedFileServerWorkgroup"]]);
    STAssertEqualObjects(self.service.sharedFileServerUsername,
                         [self.configurations valueForKey:@"SharedFileServerUsername"],
                         [@"username should be "
                          stringByAppendingString:[self.configurations valueForKey:@"SharedFileServerUsername"]]);
    STAssertEqualObjects(self.service.sharedFileServerPassword,
                         [self.configurations valueForKey:@"SharedFileServerPassword"],
                         [@"password should be "
                          stringByAppendingString:[self.configurations valueForKey:@"SharedFileServerPassword"]]);
}

/*!
 @discussuion Test createSMBClient method
 */
- (void)testCreateSMBClient
{
    //assert that smb client is created when local wifi is reachable.
    NSError *error = nil;
    id<SMBClient> client = [self.service createSMBClient:&error];
    STAssertNotNil(client, @"client should not be nil, if local wifi is reachable");
}

/*!
 @discussuion Test createSMBClient method returns nil
 */
- (void)testCreateSMBClient_Error {
    NSError *error = nil;
    self.configurations[@"SharedFileServerPassword"] = @"This_is_an_invalid_password";
    id<SMBClient> client = [[[BaseCommunicationDataService alloc] initWithConfiguration:self.configurations] createSMBClient:&error];
    STAssertNil(client, @"client should be nil.");
    STAssertNotNil(error, @"error should not be nil.");
}



@end
