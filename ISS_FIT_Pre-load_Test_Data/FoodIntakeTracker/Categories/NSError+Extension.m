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
//  NSError+Extension.m
//  Hercules Personal Content DVR
//
//  Created by namanhams on 3/9/13.
//

#import "NSError+Extension.h"

@implementation NSError (Extension)

- (void) showAllDetails {
	NSArray* detailedErrors = [[self userInfo] objectForKey:NSDetailedErrorsKey];
	if(detailedErrors != nil && [detailedErrors count] > 0) {
		for(NSError* detailedError in detailedErrors) {
			NSLog(@" DetailedError: %@", [detailedError userInfo]);
		}
	}
	else {
		NSLog(@"%@", [self localizedDescription]);
	}
}


@end
