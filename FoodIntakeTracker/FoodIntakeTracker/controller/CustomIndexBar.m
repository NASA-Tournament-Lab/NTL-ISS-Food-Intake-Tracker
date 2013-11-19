//
//  CustomIndexBar.m
//  FoodIntakeTracker
//
//  Created by lofzcx 06/12/2013
//  Copyright (c) 2013 Topcoder. All rights reserved.
//

#import "CustomIndexBar.h"
#import <QuartzCore/QuartzCore.h>

/**
 * @class CustomIndexBar
 * implement a index bar view to meet the design.
 *
 * @author lofzcx
 * @version 1.0
 */
@implementation CustomIndexBar

/**
 * set default color here.
 */
- (id)init{
    self = [super init];
    if (self) {
        // Default colors.
        self.backgroundColor = [UIColor clearColor];
        textColor = [UIColor colorWithRed:0.48 green:0.78 blue:1 alpha:1];
        highlightedBackgroundColor = [UIColor clearColor];
    }
    return self;
}

/**
 * set default color here.
 * @param frame The frame rectangle for the view.
 */
- (id)initWithFrame:(CGRect)frame{
    if ((self = [super initWithFrame:frame])){
        // Default colors.
        self.backgroundColor = [UIColor clearColor];
        textColor = [UIColor colorWithRed:0.48 green:0.78 blue:1 alpha:1];
        highlightedBackgroundColor = [UIColor clearColor];
    }
    return self;
}

/**
 * set the indexes and update the index bar view.
 * @param indexes the new index array.
 */
- (void) setIndexes:(NSArray*)indexes
{
    [self clearIndex];
    int i;
    float sectionheight = 20;
    visibleIndexBackground = [[UIImageView alloc] initWithFrame:CGRectZero];
    visibleIndexBackground.backgroundColor = [UIColor colorWithRed:0.2 green:0.43 blue:0.62 alpha:1];
    [self addSubview:visibleIndexBackground];
    for (i=0; i<[indexes count]; i++){
        float ypos = i * sectionheight;
        
        UILabel *alphaLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, ypos, self.frame.size.width, 20.0)];
        alphaLabel.textAlignment = UITextAlignmentCenter;
        alphaLabel.text = [indexes objectAtIndex:i];
        alphaLabel.tag = 100 + i;
        alphaLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0];
        alphaLabel.backgroundColor = [UIColor clearColor];
        alphaLabel.textColor = textColor;
        [self addSubview:alphaLabel];
    }
    totalIndex = indexes.count;
}

/**
 * set the visible index by start and end and make then highlight.
 * @param start the start index.
 * @param end the end index.
 */
- (void)setVisibleStartIndex:(int)start EndIndex:(int)end{
    visibleIndexBackground.frame = CGRectMake(0, start * 20, self.frame.size.width, (end - start) * 20);
    int count = 0;
    for(UIView *v in self.subviews){
        if([v isKindOfClass:[UILabel class]]){
            if(count >= start && count < end){
                [(UILabel *)v setTextColor:[UIColor whiteColor]];
            }
            else{
                [(UILabel *)v setTextColor:textColor];
            }
            count++;
        }
    }
}

/**
 * clear all subviews.
 */
- (void) clearIndex{
    totalIndex = 0;
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
}

#pragma mark - touch events
/**
 * remove highlighted view here.
 * @param touches A set of UITouch instances that represent the touches.
 * @param event An object representing the event to which the touches belong.
 */
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    [self touchesEndedOrCancelled:touches withEvent:event];
}

/**
 * remove highlighted view here.
 * @param touches A set of UITouch instances that represent the touches.
 * @param event An object representing the event to which the touches belong.
 */
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
    [self touchesEndedOrCancelled:touches withEvent:event];
}

/**
 * remove highlighted view here.
 * @param touches A set of UITouch instances that represent the touches.
 * @param event An object representing the event to which the touches belong.
 */
- (void) touchesEndedOrCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
     UIView *backgroundView = (UIView*)[self viewWithTag:767];
    [backgroundView removeFromSuperview];
}

/**
 * add highlighted view and check the touch position to info the select index.
 * @param touches A set of UITouch instances that represent the touches.
 * @param event An object representing the event to which the touches belong.
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    
    UIView *backgroundview = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                      0,
                                                                      self.bounds.size.width,
                                                                      self.bounds.size.height)];
    [backgroundview setBackgroundColor:highlightedBackgroundColor];
    backgroundview.layer.masksToBounds = YES;
    backgroundview.tag = 767;
    [self addSubview:backgroundview];
    [self sendSubviewToBack:backgroundview];
    
    if (!self.delegate) return;
    
    CGPoint touchPoint = [[[event touchesForView:self] anyObject] locationInView:self];
    
    if(touchPoint.x < 0){
        return;
    }
    
    int count = touchPoint.y / 20;
    if(count < totalIndex){
        if(self.delegate && [self.delegate respondsToSelector:@selector(indexBar:DidChangeIndexSelection:)]){
            [self.delegate indexBar:self DidChangeIndexSelection:count];
        }
    }
}


/**
 * check the touch position to info the select index.
 * @param touches A set of UITouch instances that represent the touches.
 * @param event An object representing the event to which the touches belong.
 */
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    
    if (!self.delegate){
        return;
    }
    
    CGPoint touchPoint = [[[event touchesForView:self] anyObject] locationInView:self];
    
    if(touchPoint.x < 0){
        return;
    }
    
    int count = touchPoint.y / 20;
    if(count < totalIndex && count >= 0){
        if(self.delegate && [self.delegate respondsToSelector:@selector(indexBar:DidChangeIndexSelection:)]){
            [self.delegate indexBar:self DidChangeIndexSelection:count];
        }
    }
}

@end

