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
@end