//
//  CustomIndexBar.h
//  FoodIntakeTracker
//
//  Created by lofzcx 06/12/2013
//  Copyright (c) 2013 Topcoder. All rights reserved.
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
