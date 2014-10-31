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
//  DataHelperTests.m
//  ISSFoodIntakeTracker
//
//  Created by LokiYang on 2013-08-07.
//

#import "DataHelperTests.h"
#import "DataHelper.h"

@implementation DataHelperTests

/*!
 @discussion Set up testing environment.
 */
- (void)setUp {
    [super setUp];
}

/*!
 @discussion Tear down testing environment.
 */
-(void)tearDown {
    [super tearDown];
}

/*!
 @discussion Test getDeviceIdentifier method.
 */
- (void)testGetDeviceIdentifier {
    NSString *id1 = [DataHelper getDeviceIdentifier];
    NSString *id2 = [DataHelper getDeviceIdentifier];
    STAssertEqualObjects(id1, id2, @"result should be the same.");
    STAssertNotNil(id1, @"result should not be nil.");
    STAssertNotNil(id2, @"result should not be nil.");
}

/*!
 @discussion Test getAbsoulteLocalDirectory method.
 */
- (void)testGetAbsoulteLocalDirectory {
    NSString *id1 = [DataHelper getAbsoulteLocalDirectory:@"local"];
    NSString *id2 = [DataHelper getAbsoulteLocalDirectory:@"local"];
    NSString *id3 = [DataHelper getAbsoulteLocalDirectory:@"local3"];
    STAssertEqualObjects(id1, id2, @"result should be the same.");
    STAssertFalse([id1 isEqualToString:id3], @"result should not be the same.");
    STAssertNotNil(id1, @"result should not be nil.");
    STAssertNotNil(id2, @"result should not be nil.");
    STAssertNotNil(id3, @"result should not be nil.");
}

/*!
 @discussion Test convertNSStringToNSSet method.
 */
- (void)testConvertNSStringToNSSet {
    NSString *string = @"1;2;3";
    NSArray *components = [string componentsSeparatedByString:@";"];
    NSSet *result = [DataHelper convertNSStringToNSSet:string withEntityDescription:
                     [NSEntityDescription entityForName:@"StringWrapper"
                                 inManagedObjectContext:self.managedObjectContext]
                                inManagedObjectContext:self.managedObjectContext withSeparator:@";"];
    for (StringWrapper *c in result) {
        STAssertTrue([components containsObject:c.value], @"The string array should contain the object.");
    }
    STAssertTrue(result.count==3, @"The NSSet should have exactly 3 elements");
}

@end
