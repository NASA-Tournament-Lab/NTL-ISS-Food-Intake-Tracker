//
//  NSError+Extension.m
//  Hercules Personal Content DVR
//
//  Created by namanhams on 3/9/13.
//  Copyright (c) 2013 TopCoder. All rights reserved.
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
