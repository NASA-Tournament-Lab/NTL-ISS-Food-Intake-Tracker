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
//  CalendarViewController.m
//  FoodIntakeTracker
//
//  Created by lofzcx 06/12/2013
//

#import "CalendarViewController.h"
#import "Helper.h"

/**
 * @class CalendarListView
 * The list view for days in a month.
 * 
 * @author lofzcx
 * @version 1.0
 */
@implementation CalendarListView

/**
 * init the month day array here.
 * @param decoder An unarchiver object.
 */
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        prevMonth = [[NSMutableArray alloc] init];
        nextMonth = [[NSMutableArray alloc] init];
        curMonth = [[NSMutableArray alloc] init];
    }
    return self;
}

/**
 * init the month day array here.
 * @param frame The frame rectangle for the view.
 */
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        prevMonth = [[NSMutableArray alloc] init];
        nextMonth = [[NSMutableArray alloc] init];
        curMonth = [[NSMutableArray alloc] init];
    }
    return self;
}

/**
 * get the selected date by the position in the list view.
 * @param pos the position in the view.
 * @return nil if invalid pos. otherwise a NSDate object contains the selected date.
 */
- (NSDate *)selectItemInPos:(CGPoint)pos{
    int x = pos.x / 48;
    int y = pos.y / 40;
    NSInteger index = y * 7 + x - prevMonth.count;
    if(index < 0 || index >= curMonth.count){
        return nil;
    }
    NSDateComponents *info = [[NSDateComponents alloc] init];
    info.year = monthInfo.year;
    info.month = monthInfo.month;
    info.day = [[curMonth objectAtIndex:index] intValue] - [[curMonth objectAtIndex:0] intValue] + 1;
    
    info.hour = info.minute = info.second = 0;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    gregorian.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    return [gregorian dateFromComponents:info];
}

/**
 * update the days in prev month, current month and next month.
 * It will only update the array when different month is set.
 */
- (void)updateDateArray{
    if(self.selectedDate == nil){
        self.selectedDate = [NSDate date];
    }
    if(self.month == nil){
        self.month = [NSDate date];
    }
    int daySeconds = 24 * 60 * 60;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    gregorian.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSDateComponents *info = [gregorian components:(NSYearCalendarUnit |
                                                    NSMonthCalendarUnit |
                                                    NSDayCalendarUnit |
                                                    NSWeekdayCalendarUnit)
                                          fromDate:self.month];
    if(monthInfo.month == info.month && monthInfo.year == info.year){
        return;
    }
    monthInfo = info;
    [prevMonth removeAllObjects];
    [curMonth removeAllObjects];
    [nextMonth removeAllObjects];
    // calculate  before selcted day
    for(int i = 0; ; i++){
        NSDate *prevDate = [NSDate dateWithTimeInterval:(i * -1 * daySeconds) sinceDate:self.month];
        NSDateComponents *preInfo = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit
                                                           | NSDayCalendarUnit | NSWeekdayCalendarUnit)
                                                 fromDate:prevDate];
        
        NSUInteger dayOfYear = [gregorian ordinalityOfUnit:NSDayCalendarUnit
                                                    inUnit:NSYearCalendarUnit
                                                   forDate:prevDate];
        if(preInfo.month != info.month){
            if(preInfo.weekday == 7 && prevMonth.count > 0){
                break;
            }
            [prevMonth insertObject:[NSString stringWithFormat:@"%ld", (unsigned long)dayOfYear] atIndex:0];
        }
        else{
            [curMonth insertObject:[NSString stringWithFormat:@"%ld", (unsigned long)dayOfYear] atIndex:0];
            if(preInfo.day == 1 && preInfo.weekday == 2){
                break;
            }
        }
    }
    // calulate day after selcted day
    for(int i = 1; ; i++){
        NSDate *prevDate = [NSDate dateWithTimeInterval:(i * daySeconds) sinceDate:self.month];
        NSDateComponents *preInfo = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit
                                                           | NSDayCalendarUnit | NSWeekdayCalendarUnit)
                                                 fromDate:prevDate];
        NSUInteger dayOfYear = [gregorian ordinalityOfUnit:NSDayCalendarUnit
                                                    inUnit:NSYearCalendarUnit
                                                   forDate:prevDate];
        if(preInfo.month != info.month){
            if(preInfo.weekday == 1){
                break;
            }
            [nextMonth addObject:[NSString stringWithFormat:@"%ld", (unsigned long)dayOfYear]];
        }
        else{
            [curMonth addObject:[NSString stringWithFormat:@"%ld", (unsigned long)dayOfYear]];
            if(preInfo.day == 1 && preInfo.weekday == 2){
                break;
            }
        }
    }
    self.totalRows = floor((curMonth.count + prevMonth.count + nextMonth.count) / 7.0f + 0.5f);
    [self setNeedsDisplay];
}

/**
 * drawing the text here.
 * @param rect the view frame size.
 */
- (void)drawRect:(CGRect)rect{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    gregorian.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSDateComponents *info = [gregorian components:(NSYearCalendarUnit |
                                                    NSMonthCalendarUnit |
                                                    NSDayCalendarUnit |
                                                    NSWeekdayCalendarUnit)
                                          fromDate:self.selectedDate];
    NSInteger pos = info.day + prevMonth.count - 1;
    NSInteger posX = pos % 7;
    NSInteger posY = pos / 7;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    BOOL isCurrentMonth = (info.month == monthInfo.month);
    BOOL isCurrentYear = (info.year == monthInfo.year);
    if (isCurrentMonth && isCurrentYear) {
        CGContextSetRGBFillColor(context, 0.54, 0.79, 1, 1);
        CGContextFillRect(context, CGRectMake(posX * 48, posY * 40, 47, 39));
        CGContextStrokePath(context);
    }
    CGContextSetRGBStrokeColor(context, 0.2, 0.2, 0.2, 1);
    CGContextSetRGBFillColor(context, 0.2, 0.2, 0.2, 1);
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    UIFont *boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
    int x = 0;
    int y = 0;
    CGContextSetRGBFillColor(context, 0.8, 0.8, 0.8, 1);
    // drawing prev month days
    for (NSString *str in prevMonth) {
        CGSize size = [str sizeWithAttributes:@{NSFontAttributeName : font}];
        [str drawAtPoint:CGPointMake(x * 48 - size.width / 2 + 23, y * 40 - size.height / 2 + 20)
          withAttributes:@{NSFontAttributeName : font}];
        x = (x + 1);
        if (x == 7) {
            y++;
            x = 0;
        }
    }
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [comps setYear:info.year];
    [comps setMonth:1];
    [comps setDay:1];
    NSDate *firstDay = [gregorian dateFromComponents:comps];
    
    // drawing current month days
    for (NSString *str in curMonth) {
        NSDateComponents *compsToAdd = [[NSDateComponents alloc] init];
        [compsToAdd setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
        [compsToAdd setDay:str.integerValue - 1];
        
        NSDate *finalDate = [gregorian dateByAddingComponents:compsToAdd toDate:firstDay options:0];
        if ([Helper daysFromToday:finalDate] == 0 && isCurrentYear) {
            // paint current date
            CGContextSetRGBFillColor(context, 231./255., 245./255., 43./255., 1);
            CGContextFillRect(context, CGRectMake(x * 48, y * 40, 47, 39));
            CGContextStrokePath(context);
            
            // paint if selected date is equal to current date
            if ([Helper daysFromToday:self.selectedDate] == 0) {
                CGContextSetRGBFillColor(context, 0.54, 0.79, 1, 1);
                CGContextFillRect(context, CGRectMake(posX * 48 + 3, posY * 40 + 3, 41, 33));
                CGContextStrokePath(context);
            }
        }
        
        CGContextStrokePath(context);
        CGContextSetRGBFillColor(context, 0.2, 0.2, 0.2, 1);
        
        // check is selected or not.
        if (isCurrentMonth && isCurrentYear && posX == x && posY == y) {
            CGSize size = [str sizeWithAttributes:@{NSFontAttributeName : boldFont}];
            [str drawAtPoint:CGPointMake(x * 48 - size.width / 2 + 23, y * 40 - size.height / 2 + 20)
              withAttributes:@{NSFontAttributeName : boldFont}];
        } else {
            CGSize size = [str sizeWithAttributes:@{NSFontAttributeName : boldFont}];
            [str drawAtPoint:CGPointMake(x * 48 - size.width / 2 + 23, y * 40 - size.height / 2 + 20)
              withAttributes:@{NSFontAttributeName : boldFont}];
        }
        x = (x + 1);
        if (x == 7) {
            y++;
            x = 0;
        }
    }
    CGContextStrokePath(context);
    CGContextSetRGBFillColor(context, 0.8, 0.8, 0.8, 1);
    // drawing next month days
    for (NSString *str in nextMonth) {
        CGSize size = [str sizeWithAttributes:@{NSFontAttributeName : font}];
        [str drawAtPoint:CGPointMake(x * 48 - size.width / 2 + 23, y * 40 - size.height / 2 + 20)
          withAttributes:@{NSFontAttributeName : font}];
        x = (x + 1);
        if (x == 7) {
            y++;
            x = 0;
        }
    }
    CGContextStrokePath(context);
}


@end

/**
 * @class CalendarViewController
 * view controller for calendar pop view.
 * allow browsing date in different month, selecting a date.
 *
 * @author lofzcx
 * @version 1.0
 */
@implementation CalendarViewController

@synthesize selectedDate = _selectedDate;

/**
 * initilize some values and actions after view loaded.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.monthLabel.font = [UIFont fontWithName:@"Bebas" size:20];
    
    self.listView.userInteractionEnabled = YES;
    self.listView.selectedDate = self.selectedDate;
    [self setMonth:self.selectedDate];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.listView addGestureRecognizer:tap];
    // Do any additional setup after loading the view.
}

/**
 * setting the current month value.
 * @param month the current month.
 */
- (void)setMonth:(NSDate *)month{
    self.listView.month = month;
    [self.listView updateDateArray];
    long h = self.listView.totalRows * 40;
    
    self.bgCalendarGrid.frame = CGRectMake(15, 80, 336, 40 + h);
    self.btnToday.frame = CGRectMake(15, 143 + h, 336, 33);
    self.bgCalendar.frame = CGRectMake(-1, 15, 369, 178 + h);
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    gregorian.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSDateComponents *info = [gregorian components:(NSYearCalendarUnit |
                                                    NSMonthCalendarUnit |
                                                    NSDayCalendarUnit |
                                                    NSWeekdayCalendarUnit)
                                          fromDate:month];
    self.monthLabel.text = [NSString stringWithFormat:@"%@  %d", [Helper monthName:info.month], (int)info.year];
}

/**
 * go to next month list.
 * @param sender the button.
 */
- (IBAction)nextMonth:(id)sender{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    gregorian.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSDateComponents *info = [gregorian components:(NSYearCalendarUnit |
                                                    NSMonthCalendarUnit |
                                                    NSDayCalendarUnit |
                                                    NSWeekdayCalendarUnit)
                                          fromDate:self.listView.month];
    NSInteger m = info.month +1;
    NSInteger y = info.year;
    if(m > 12){
        y = info.year + 1;
        m = 1;
    }
    info.month = m;
    info.year = y;
    info.day = 10;
    info.hour = info.minute = info.second = 0;
    NSDate *nextMon = [gregorian dateFromComponents:info];
    [self setMonth:nextMon];
}

/**
 * go to previous month list.
 * @param sender the button.
 */
- (IBAction)prevMonth:(id)sender{
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *info = [gregorian components:(NSYearCalendarUnit |
                                                    NSMonthCalendarUnit |
                                                    NSDayCalendarUnit |
                                                    NSWeekdayCalendarUnit)
                                          fromDate:self.listView.month];
    NSInteger m = info.month - 1;
    NSInteger y = info.year;
    if(m <= 0){
        y = info.year - 1;
        m = 12;
    }
    info.month = m;
    info.year = y;
    info.day = 10;
    info.hour = info.minute = info.second = 0;
    NSDate *nextMon = [gregorian dateFromComponents:info];
    [self setMonth:nextMon];
}

/**
 * action on tap the list view. Check the position and get the selected date.
 * @param ges the tap gesture indicates the position.
 */
- (void)tap:(UITapGestureRecognizer *)ges{
    CGPoint pos = [ges locationInView:self.listView];
    NSDate *selectDate = [self.listView selectItemInPos:pos];
    if(selectDate != nil){
        self.listView.selectedDate = selectDate;
        [self.listView setNeedsDisplay];
        if(self.delegate && [self.delegate respondsToSelector:@selector(calendarDidSelect:)]){
            [self.delegate calendarDidSelect:selectDate];
        }
        [self.popController dismissPopoverAnimated:YES];
    }
}

/**
 * move the list view to the month of today and set today as active.
 * @param sender the button
 */
- (IBAction)today:(id)sender{
    [self setMonth:[NSDate date]];
    self.listView.selectedDate = [NSDate date];
    [self.listView setNeedsDisplay];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(calendarDidSelect:)]){
        [self.delegate calendarDidSelect:self.listView.selectedDate];
    }
    [self.popController dismissPopoverAnimated:YES];
}
@end
