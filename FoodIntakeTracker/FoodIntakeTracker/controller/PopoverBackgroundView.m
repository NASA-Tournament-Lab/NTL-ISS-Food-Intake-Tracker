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
//  PopoverBackgroundView.m
//  FoodIntakeTracker
//
//  Created by lofzcx 06/12/2013
//

#import "PopoverBackgroundView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PopoverBackgroundView
@synthesize arrowDirection  = _arrowDirection;
@synthesize arrowOffset     = _arrowOffset;

/**
 * define background color clear here.
 * @param frame the frame size of the view.
 * @return the view.
 */
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

/**
 * The width of the arrow triangle at its base.
 * @return 0 to hide base.
 */
+ (CGFloat)arrowBase{
    return 0.0;
}

/**
 * The height of the arrow (measured in points) from its base to its tip.
 * @return 1 to hide arrow.
 */
+ (CGFloat)arrowHeight{
    return 1.0;
}

/**
 * the insets for the content portion of the popover.
 * @return 0 means no insets.
 */
+ (UIEdgeInsets)contentViewInsets{
    return UIEdgeInsetsMake(1.0f, 0.0f, 0.0f, 0.0f);
}

/**
 * Determines whether the default content appearance should be used for the popover. (ios 6+)
 * @return NO. no using default appearance.
 */
+ (BOOL)wantsDefaultContentAppearance{
    return NO;
}

/**
 * hide border view in ios5 here.
 */
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.backgroundColor = [UIColor clearColor];
    self.layer.shadowOffset = CGSizeMake(1, 1);
    self.layer.shadowPath = nil;
    self.layer.shadowRadius = 1;
    // remove border view in ios5
    for(UIView *v in [[self superview] subviews]){
        for(UIView *popView in v.subviews){
            if ([NSStringFromClass([popView class]) isEqualToString:@"UILayoutContainerView"]){
                popView.layer.cornerRadius = 0;
                popView.layer.shadowRadius = 0;
                popView.layer.backgroundColor = [UIColor clearColor].CGColor;
                for(UIView *img in popView.subviews){
                    if ([NSStringFromClass([img class]) isEqualToString:@"UIImageView"] ){
                        [img removeFromSuperview];
                    }
                }
            }
        }
    }
    
}

@end
