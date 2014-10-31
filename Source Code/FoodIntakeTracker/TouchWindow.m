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
//  TouchWindow.m
#import <UIKit/UIKit.h>
#import "TouchWindow.h"
#import "Settings.h"

@implementation TouchWindow
- (void)sendEvent:(UIEvent *)event
{
    [super sendEvent:event];
    [[NSNotificationCenter defaultCenter] postNotificationName:AutoLogoutRenewEvent object:nil];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(systemVersion < 7) {
        self.frame = [[UIScreen mainScreen] bounds];
    }
    else {
        CGRect bounds = [[UIScreen mainScreen] bounds];
        CGFloat diff = 20;
        self.frame = CGRectMake(bounds.origin.x, bounds.origin.y + diff, bounds.size.width, bounds.size.height - diff);
        self.bounds = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height - diff);
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
}
@end