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
//  CustomIndexBar.h
//  FoodIntakeTracker
//
//  Created by lofzcx 06/12/2013
//

#import <UIKit/UIKit.h>

@protocol CustomIndexBarDelegate;

/**
 * @class CustomIndexBar
 * implement a index bar view to meet the design.
 *
 * @author lofzcx
 * @version 1.0
 */
@interface CustomIndexBar : UIView {
    /* the total index number */
    int totalIndex;
    /* the visible index background image view */
    UIImageView *visibleIndexBackground;
    /* the text color */
    UIColor *textColor;
    /* highlighted background color */
    UIColor *highlightedBackgroundColor;
}

/**
 * set the indexes and update the index bar view.
 * @param indexes the new index array.
 */
- (void) setIndexes:(NSArray*)indexes;

/**
 * clear all subviews.
 */
- (void) clearIndex;

/**
 * set the visible index by start and end and make then highlight.
 * @param start the start index.
 * @param end the end index.
 */
- (void) setVisibleStartIndex:(int)start EndIndex:(int)end;

/* the delegate */
@property (nonatomic, unsafe_unretained) id<CustomIndexBarDelegate> delegate;

@end


/**
 * @protocol CustomIndexBarDelegate
 * Used to catch select index changed in the custom index bar.
 * 
 * @author lofzcx
 * @version 1.0
 */
@protocol CustomIndexBarDelegate<NSObject>
@optional
/**
 * tells the delegate the current index number.
 * @param IndexBar the indexbar.
 * @param index the current index.
 */
- (void)indexBar:(CustomIndexBar *)IndexBar DidChangeIndexSelection:(int)index;
@end
