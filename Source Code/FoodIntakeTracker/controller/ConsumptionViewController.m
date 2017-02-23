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
//  ConsumptionViewController.m
//  FoodIntakeTracker
//
//  Created by lofzcx 06/12/2013
//
//  Updated by pvmagacho on 05/07/2014
//  F2Finish - NASA iPad App Updates
//
//  Updated by pvmagacho on 05/14/2014
//  F2Finish - NASA iPad App Updates - Round 3
//

#import "ConsumptionViewController.h"
#import "CustomTabBarViewController.h"
#import "SummaryFoodTableCell.h"
#import "PopoverBackgroundView.h"
#import "AddFoodViewController.h"
#import "CalendarViewController.h"
#import "FoodDetailViewController.h"
#import "VoiceSearchViewController.h"
#import "SelectConsumptionViewController.h"
#import "Helper.h"
#import "AppDelegate.h"
#import "FoodConsumptionRecordServiceImpl.h"
#import "FoodProductServiceImpl.h"
#import "Settings.h"
#import "BNPieChart.h"
#import "BNColor.h"

#import "Media.h"

#import "WebserviceCoreData.h"

#define MAX_CALORIES 2800
#define MAX_SODIUM 160
#define MAX_FLUID 3000

#define PROTEIN_CALORIES_FACTOR 4.0
#define CARB_CALORIES_FACTOR 4.0
#define FAT_CALORIES_FACTOR 9.0

#define MAX_GM_KG 2.2f
#define PROGRESSBAR_WIDTH 100

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@interface Looper : NSObject <AVAudioPlayerDelegate> {
    AVAudioPlayer* player;
    NSArray* fileNameQueue;
    int index;
    FoodDetailViewController *foodDetail;
}

@property (nonatomic, retain) NSArray* fileNameQueue;
@property (nonatomic, retain) FoodDetailViewController *foodDetail;

- (id)initWithFileNameQueue:(NSArray*)queue;
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag;
- (void)start;
- (void)stop;

@end

@implementation Looper

@synthesize fileNameQueue, foodDetail;

- (id)initWithFileNameQueue:(NSArray*)queue {
    if ((self = [super init])) {
        self.fileNameQueue = queue;
    }
    return self;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (index < fileNameQueue.count) {
        [self play:index];
    } else {
        //reached end of queue
        foodDetail.btnVoice.enabled = YES;
        foodDetail.btnVoicePlay.enabled = YES;
        
        foodDetail.commentInstructionLabel.text = @"Player stopped";
        foodDetail.commentInstructionLabel.hidden = NO;
        [foodDetail.commentInstructionLabel sizeToFit];
        CGRect labelFrame = foodDetail.commentInstructionLabel.frame;
        labelFrame.size.width += 5;
        labelFrame.size.height += 5;
        foodDetail.commentInstructionLabel.frame = labelFrame;
        foodDetail.commentInstructionLabel.center = CGPointMake(280.f, 380.f);
    }
}

- (void)start {
    index = 0;
    [self play:0];
}

- (void)play:(int)i {
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *additionalFileDirectory = [documentsPath stringByAppendingPathComponent:appDelegate.additionalFilesDirectory];
    
    NSString *filePath = @"";
    id filename = [self.fileNameQueue objectAtIndex:i];
    if ([filename isKindOfClass:[NSString class]]) {
        filePath = [additionalFileDirectory stringByAppendingFormat:@"/%@", filename];
    } else if ([filename isKindOfClass:[Media class]]) {
        Media *media = (Media *) filename;
        filePath = [additionalFileDirectory stringByAppendingFormat:@"/%@", [media filename]];
    } else {
        [Helper showAlert:@"Error" message:@"Could not find audio file"];
        
        return;
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [Helper showAlert:@"Error" message:@"Could not find audio file"];
        return;
    }
    
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:filePath] error:nil];
    player.delegate = self;
    [player prepareToPlay];
    BOOL played = [player play];
    if (!played) {
        // error while trying to play
        foodDetail.btnVoice.enabled = YES;
        foodDetail.btnVoicePlay.enabled = YES;
        
        [Helper showAlert:@"Error" message:@"Could not play audio."];
        return;
    }
    
    index++;

    foodDetail.commentInstructionLabel.text = [NSString stringWithFormat:@"Playing recording (%d of %d)", index,
                                               (int) self.fileNameQueue.count];
    foodDetail.commentInstructionLabel.hidden = NO;
    foodDetail.commentInstructionLabel.layer.cornerRadius = 4.0f;
    [foodDetail.commentInstructionLabel sizeToFit];
    CGRect labelFrame = foodDetail.commentInstructionLabel.frame;
    labelFrame.size.width += 5;
    labelFrame.size.height += 5;
    foodDetail.commentInstructionLabel.frame = labelFrame;
    foodDetail.commentInstructionLabel.center = CGPointMake(280.f, 380.f);
}

- (void)stop {
    if (player && player.playing) {
        [player stop];
    }
}

@end

@implementation DateListView

/**
 * handles action for date item button click.
 * @param sender the date item button.
 */
-(void)buttonClick:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if(btn.tag == activeTag){
        return;
    }
    NSDate *date = [NSDate dateWithTimeInterval:(DAY_SECONDS * (btn.tag - activeTag))
                                      sinceDate:self.currentDate];
    self.currentDate = date;
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickDate:)]){
        [self.delegate clickDate:date];
    }
    [self setNeedsDisplay];
}

/**
 * overwrite this method to generate date item and bind actions.
 * @param rect the rect needs to be re-draw.
 */
-(void)drawRect:(CGRect)rect{
    int daySeconds = 60 * 60 * 24;
    if(self.currentDate == nil){
        self.currentDate = [NSDate date];
    }
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    gregorian.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSDateComponents *info = [gregorian components:(NSCalendarUnitYear |
                                                    NSCalendarUnitMonth |
                                                    NSCalendarUnitDay |
                                                    NSCalendarUnitWeekday)
                                          fromDate:self.currentDate];
    
    NSDate *startDate = [NSDate dateWithTimeInterval:(-1 * daySeconds * ((info.weekday + 7 - 1) % 7))
                                           sinceDate:self.currentDate];
    for(int i = 0; i < 7; i++){
        UIButton *btn = (UIButton *)[self viewWithTag:(101 + i)];
        [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        UILabel *lblDay = (UILabel *)[self viewWithTag:(201 + i)];
        UILabel *lblDayName = (UILabel *)[self viewWithTag:(301 + i)];
        NSDate *date = [NSDate dateWithTimeInterval:(daySeconds * i) sinceDate:startDate];
        NSDateComponents *tmp = [gregorian components:(NSCalendarUnitYear |
                                                       NSCalendarUnitMonth |
                                                       NSCalendarUnitDay |
                                                       NSCalendarUnitWeekday)
                                             fromDate:date];
        
        NSUInteger dayOfYear = [gregorian ordinalityOfUnit:NSCalendarUnitDay
                                                    inUnit:NSCalendarUnitYear
                                                   forDate:date];
        
        lblDay.text = [NSString stringWithFormat:@"%.2lu", (unsigned long) dayOfYear];
        if(tmp.weekday == info.weekday){
            activeTag = btn.tag;
            [btn setSelected:YES];
            lblDay.textColor = lblDayName.textColor = [UIColor colorWithRed:0.2 green:0.43 blue:0.62 alpha:1];
        }
        else{
            [btn setSelected:NO];
            lblDay.textColor = lblDayName.textColor = [UIColor colorWithRed:0.32 green:0.32 blue:0.32 alpha:1];
        }
        
        btn.layer.borderWidth = 0.f;
        btn.layer.borderColor = NULL;
        if ([Helper daysFromToday:date] == 0) {
            btn.layer.borderWidth = 2.f;
            btn.layer.borderColor = [UIColor yellowColor].CGColor;
        }
    }
    
}

@end

@implementation CustomProgressView

@synthesize currentProgress = _currentProgress, gmKg = _gmKg;

/**
 * setting the current progress value and reflesh the view.
 * @param currentProgress should be 0 to 1. The current progress.
 */
- (void)setCurrentProgress:(float)currentProgress{
    if(currentProgress > 1){
        _currentProgress = 1;
    }
    else if(currentProgress < 0){
        _currentProgress = 0;
    }
    else{
        _currentProgress = currentProgress;
    }
    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
}

/**
 * overwrite this method the layout the progress view.
 * @param rect the frame size.
 */
- (void)drawRect:(CGRect)rect{
    float w = self.progressView.frame.size.width;
    float h = self.progressView.frame.size.height;
    float x = self.progressView.frame.origin.x;
    float y = self.progressView.frame.origin.y;
    
    /*CGSize size = [self.lblCurrent.text sizeWithFont:self.lblCurrent.font
                                   constrainedToSize:CGSizeMake(MAXFLOAT, self.frame.size.height)];
    
    self.lblCurrent.frame = CGRectMake(self.lblCurrent.frame.origin.x,
                                       self.lblCurrent.frame.origin.y,
                                       size.width + 5,
                                       self.lblCurrent.frame.size.height);
    
    self.lblTotal.frame = CGRectMake(self.lblCurrent.frame.origin.x + size.width + 5,
                                     self.lblTotal.frame.origin.y,
                                     self.lblTotal.frame.size.width,
                                     self.lblTotal.frame.size.height);*/
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (self.progressImage != nil) {
        if (self.gmKg) {
            w -= 8;
            CGFloat value = 3;
            CGContextDrawImage(context, CGRectMake(x, y + value, w, h - value * 2), self.progressImage.CGImage);
            
            UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:10.0];
            NSArray *array = @[@0.5, @0.8, @1.2, @1.7, @2.0];
            
            for (NSNumber *number in array) {
                CGFloat pos = x + w * ([number floatValue] / MAX_GM_KG);
                CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
                CGContextSetLineWidth(context, 1.0f);
                CGContextMoveToPoint(context, pos, y + h - value); //start at this point
                CGContextAddLineToPoint(context, pos, y + h + 1); //start at this point
                CGContextStrokePath(context);
                
                NSString *str = [NSString stringWithFormat:@"%3.1f", [number floatValue]];
                CGSize size = [str sizeWithAttributes:@{NSFontAttributeName: font}];
                [str drawAtPoint:CGPointMake(pos - size.width / 2, y + h) withAttributes:@{NSFontAttributeName: font}];
            }
            
            CGFloat pos = x + _currentProgress * w - 3;
            
            NSString *str = [NSString stringWithFormat:@"%3.1f", _currentProgress * MAX_GM_KG];
            CGSize size = [str sizeWithAttributes:@{NSFontAttributeName: font}];
            [str drawAtPoint:CGPointMake(pos - 4, y - size.height) withAttributes:@{NSFontAttributeName: font}];
            
            CGRect rect = CGRectMake(pos, y + 1, 6, h - 2);
            CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
            CGContextSetLineWidth(context, 2.0f);
            CGContextAddRect(context, rect);
            CGContextStrokePath(context);
        } else {
            if (_currentProgress == 1) {
                CGContextSetFillColorWithColor(context, self.fullColor.CGColor);
                CGContextFillRect(context, CGRectMake(x + 1, y + 1, w - 2, h - 2));
                CGContextStrokePath(context);
            } else {
                CGContextDrawImage(context, CGRectMake(x, y, w, h), self.backgoundImage.CGImage);

                UIGraphicsBeginImageContext(CGSizeMake(w - 2, h - 2));
                [self.progressImage drawInRect:CGRectMake(0, 0, w - 2, h - 2)];

                CGContextClearRect (UIGraphicsGetCurrentContext(), CGRectMake((w - 2) * _currentProgress, 0,
                                                                              (w - 2) * (1 - _currentProgress), h - 2));

                CGContextStrokePath(UIGraphicsGetCurrentContext());
                UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();

                CGContextDrawImage(context, CGRectMake(x + 1, y + 1, (w - 2), h - 2), img.CGImage);
            }
        }
    } else {
        CGContextDrawImage(context, CGRectMake(x, y, w, h), self.backgoundImage.CGImage);
        CGContextSetFillColorWithColor(context, self.fullColor.CGColor);
        CGContextFillRect(context, CGRectMake(x + 1, y + 1, (w - 2) * _currentProgress, h - 2));
        CGContextStrokePath(context);
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    originalFrame = self.frame;
    if (event.type == UIEventTypeTouches) {
        [self performSelector:@selector(longTap) withObject:nil afterDelay:0.6];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(longTap) object:nil];
    
    self.layer.cornerRadius = 0.0f;
    
    if (!CGAffineTransformIsIdentity(self.transform)) {
        [UIView animateWithDuration:0.5 animations:^{
            self.transform = CGAffineTransformIdentity;
            self.frame = interFrame;
        } completion:^(BOOL finished) {
            self.backgroundColor = [UIColor clearColor];
            self.frame = originalFrame;
            [self layoutIfNeeded];
        }];
    } else {
        self.transform = CGAffineTransformIdentity;
        self.backgroundColor = [UIColor clearColor];
        self.frame = originalFrame;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

- (void)longTap {
    [self.superview bringSubviewToFront:self];
    self.layer.cornerRadius = 5.0f;
    self.backgroundColor = [UIColor colorWithWhite:252.f/255.f alpha:0.9];
    
    float scale = 1.2f;
    float deltaWidth = 40.0f;
    float newWidth = (originalFrame.size.width + deltaWidth);
    CGRect newFrame;
    
    if (originalFrame.origin.x < 50) {
        interFrame = CGRectMake(originalFrame.origin.x, originalFrame.origin.y,
                              newWidth, originalFrame.size.height);
    } else if (originalFrame.origin.x > 350) {
        interFrame = CGRectMake(originalFrame.origin.x - deltaWidth, originalFrame.origin.y,
                              newWidth, originalFrame.size.height);
    } else {
        interFrame = CGRectMake(originalFrame.origin.x - deltaWidth / 2.f, originalFrame.origin.y,
                              newWidth, originalFrame.size.height);
    }
    
    if (originalFrame.origin.x < 50) {
        newFrame = CGRectMake(interFrame.origin.x, interFrame.origin.y - 10,
                              interFrame.size.width * scale, interFrame.size.height * scale);
    } else if (originalFrame.origin.x > 350) {
        newFrame = CGRectMake(interFrame.origin.x - (interFrame.size.width * (scale - 1.0f)), interFrame.origin.y - 10,
                              interFrame.size.width * scale, interFrame.size.height * scale);
    } else {
        newFrame = CGRectMake(interFrame.origin.x - (interFrame.size.width * (scale - 1.0f)) / 2.0f, interFrame.origin.y - 10,
                              interFrame.size.width * scale, interFrame.size.height * scale);
    }
    
    self.frame = interFrame;
    [self layoutIfNeeded];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
        self.frame = newFrame;
    } completion:^(BOOL finished) {
        [self layoutIfNeeded];
    }];
}

@end

@interface ConsumptionViewController () {
    /* the selected food items */
    NSMutableArray *selectedItems;
    /* the copied food items */
    NSMutableArray *copyItems;
    /* the content offset - F2Finish change */
    NSMutableDictionary *contentOffset;
    
    /* the add food view controller */
    AddFoodViewController *_addFood;
    /* the cover when some pop up is shown */
    UIView *clearCover;
    /* the calendar view controller */
    CalendarViewController *caledar;
    /* the detail view controller */
    FoodDetailViewController *foodDetail;
    /* the voice search controller */
    VoiceSearchViewController *voiceSearch;
    /* the select consumption view controller */
    SelectConsumptionViewController *selectConsumption;
    /* whether the open ear is listening */
    bool listening;

    /* Audio record objects */
    NSMutableArray *recorderFilePath;
    AVAudioRecorder *recorder;
    Looper *looper;
}

@end

@implementation ConsumptionViewController

/**
 * called when view will appear.
 * @param animated If YES, the view is being added to the window using an animation.
 */
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];

    self.customTabBarController.tabView.hidden = NO;
    
    [self updateView];
}

/**
 * called when view will appear. just load foods here.
 */
- (void)updateView {
    if (![[NSThread currentThread] isMainThread]) {
        [self performSelectorOnMainThread:@selector(updateView) withObject:nil waitUntilDone:NO];
        return;
    }
    
    NSDate *selectDate = self.dateListView.currentDate;
    if (!selectDate) {
        selectDate = [NSDate date];
    }
    [self loadFoodItemsForDate:selectDate];

    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    NSMutableString *str = [NSMutableString string];
    if (appDelegate.loggedInUser.fullName.length > 0){
        NSArray *names = [appDelegate.loggedInUser.fullName componentsSeparatedByString:@" "];
        // F2Finish change - Display name
        [str appendFormat:@"  %@", names[0]];
        for (int i = 1; i < names.count; i++) {
           [str appendFormat:@"  %@", names[i]];
            if (str.length > 33) {
                int len = str.length - 30;
                [str replaceCharactersInRange:NSMakeRange(30, len) withString:@"..."];
            }
        }
    }
    [str appendFormat:@" "];
    
    if (self.lblHeaderTitle != nil) {
        CGRect textRect = [str boundingRectWithSize:self.lblHeaderTitle.frame.size
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName:self.lblHeaderTitle.font}
                                             context:nil];
        CGSize size1 = textRect.size;
        [str appendString:@"    Daily Intake Report"];
        self.lblHeaderTitle.text = [NSString stringWithString:str];
        [self.lblHeaderTitle sizeToFit];
        
        self.lblHeaderTitle.center = self.imgBgHeader.center;
    
        self.imgHeaderLine.frame = CGRectMake(self.lblHeaderTitle.frame.origin.x + size1.width + 10, 10, 2, 41);
    }

    if (appDelegate.loggedInUser) {
        self.caloriesProgess.lblTotal.text =
        [NSString stringWithFormat:@"| %@ Cal", appDelegate.loggedInUser.dailyTargetEnergy];
        self.sodiumProgress.lblTotal.text =
        [NSString stringWithFormat:@"| %@ mg", appDelegate.loggedInUser.dailyTargetSodium];
        self.fluidProgress.lblTotal.text =
        [NSString stringWithFormat:@"| %@ mL", appDelegate.loggedInUser.dailyTargetFluid];
    }

    [self updateProgress];
}

/**
 * initilize some default values when view loaded.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.lblHeaderTitle.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:24];
    
    selectedItems = [[NSMutableArray alloc] init];
    copyItems = [[NSMutableArray alloc] init];
    
    // F2Finish change
    contentOffset = [[NSMutableDictionary alloc] init];
    
    self.lblFooterTitle.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    self.lblMonth.font = [UIFont fontWithName:@"Bebas" size:16];
    
    self.caloriesProgess.backgoundImage = [UIImage imageNamed:@"bg-progress.png"];
    self.sodiumProgress.backgoundImage = [UIImage imageNamed:@"bg-progress.png"];
    self.fluidProgress.backgoundImage = [UIImage imageNamed:@"bg-progress.png"];
    self.proteinProgess.backgoundImage = [UIImage imageNamed:@"bg-progress.png"];
    /*self.carbProgress.backgoundImage = [UIImage imageNamed:@"bg-progress.png"];
    self.fatProgress.backgoundImage = [UIImage imageNamed:@"bg-progress.png"];*/
    
    self.caloriesProgess.fullColor = [UIColor greenColor];
    self.sodiumProgress.fullColor = [UIColor redColor];
    self.fluidProgress.fullColor = [UIColor greenColor];
    // self.proteinProgess.fullColor = [UIColor clearColor];
    self.carbProgress.fullColor = [UIColor clearColor];
    self.fatProgress.fullColor = [UIColor clearColor];
    
    self.caloriesProgess.progressImage = [UIImage imageNamed:@"bg-progress-red.png"];
    self.sodiumProgress.progressImage = [UIImage imageNamed:@"bg-progress-green.png"];
    self.fluidProgress.progressImage = [UIImage imageNamed:@"bg-progress-red.png"];
    self.proteinProgess.progressImage = [UIImage imageNamed:@"bg_protein_bar.png"];
    /*self.proteinProgess.progressImage = [UIImage imageNamed:@"bg-progress-red.png"];
    self.carbProgress.progressImage = [UIImage imageNamed:@"bg-progress-red.png"];
    self.fatProgress.progressImage = [UIImage imageNamed:@"bg-progress-red.png"];*/
    
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    if (appDelegate.loggedInUser) {
        self.caloriesProgess.lblTotal.text =
        [NSString stringWithFormat:@"| %@ Cal", appDelegate.loggedInUser.dailyTargetEnergy];
        self.sodiumProgress.lblTotal.text =
        [NSString stringWithFormat:@"| %@ mg", appDelegate.loggedInUser.dailyTargetSodium];
        self.fluidProgress.lblTotal.text =
        [NSString stringWithFormat:@"| %@ mL", appDelegate.loggedInUser.dailyTargetFluid];
    } else {
        self.caloriesProgess.lblTotal.text = [NSString stringWithFormat:@"| %d Cal", MAX_CALORIES];
        self.sodiumProgress.lblTotal.text = [NSString stringWithFormat:@"| %d mg", MAX_SODIUM];
        self.fluidProgress.lblTotal.text = [NSString stringWithFormat:@"| %d mL", MAX_FLUID];
    }
    
    [self.caloriesProgess.lblTotal sizeToFit];
    [self.sodiumProgress.lblTotal sizeToFit];
    [self.fluidProgress.lblTotal sizeToFit];
    
    listening = NO;
    [self calendarDidSelect:[NSDate date]];
    self.dateListView.delegate = self;
    
    self.bottomScrollView.contentSize = CGSizeMake(1536, 125);
    
    self.lblDeletePopupTitle.font = [UIFont fontWithName:@"Bebas" size:20];
    self.lblCopyPopupTitle.font = [UIFont fontWithName:@"Bebas" size:20];
    self.lblPastePopupTitle.font = [UIFont fontWithName:@"Bebas" size:20];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(consumptionUpdated)
                                                 name:ConsumptionUpdatedEvent object:nil];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    gregorian.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSDateComponents *info = [gregorian components:(NSCalendarUnitYear |
                                                    NSCalendarUnitMonth |
                                                    NSCalendarUnitDay |
                                                    NSCalendarUnitWeekday)
                                          fromDate:[NSDate date]];
    
    self.lblMonth.text = [Helper monthName:(int)info.month];
    self.lblYear.text = [NSString stringWithFormat:@"GMT %d", (int)info.year];

    [self redrawPieChartWithProtein:0.333 carb:0.333 fat:0.334];
    
    // Save audio
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
    //record sound test code -  END
    
    //NSError *error;
    //self.lmPaths = [srService getGeneralLanguageModelPaths:&error];
    //if ([Helper displayError:error]) return;
    [[NSNotificationCenter defaultCenter] postNotificationName:AutoLogoutRenewEvent object:nil];
    
    UISwipeGestureRecognizer *rLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleDateSwipe:)];
    rLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    rLeft.delegate = self;
    [self.dateListView addGestureRecognizer:rLeft];
    
    UISwipeGestureRecognizer *rRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleDateSwipe:)];
    rRight.direction = UISwipeGestureRecognizerDirectionRight;
    rRight.delegate = self;    
    [self.dateListView addGestureRecognizer:rRight];
    
    self.proteinPercentageLabel.layer.borderWidth = 0.8f;
    self.proteinPercentageLabel.layer.borderColor = [UIColor colorWithWhite:0.2 alpha:0.2].CGColor;
    self.proteinPercentageLabel.layer.cornerRadius = 7.f;
    
    self.carbPercentageLabel.layer.cornerRadius = 7.f;
    self.carbPercentageLabel.layer.borderWidth = 0.8f;
    self.carbPercentageLabel.layer.borderColor = [UIColor colorWithWhite:0.2 alpha:0.2].CGColor;
    
    self.fatPercentageLabel.layer.cornerRadius = 7.f;
    self.fatPercentageLabel.layer.borderWidth = 0.8f;
    self.fatPercentageLabel.layer.borderColor = [UIColor colorWithWhite:0.2 alpha:0.2].CGColor;

    _addFood.commentInstructionLabel.hidden = YES;
    foodDetail.commentInstructionLabel.hidden = YES;
    [_addFood.commentInstructionLabel sizeToFit];
    [foodDetail.commentInstructionLabel sizeToFit];
    _addFood.commentInstructionLabel.layer.cornerRadius = 4.0f;
    foodDetail.commentInstructionLabel.layer.cornerRadius = 4.0f;

    recorderFilePath = [NSMutableArray array];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView)
                                                 name:CurrentUserUpdateEvent object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView)
                                                 name:MergeDataEvent object:nil];
}

/**
 * release some value by setting nil.
 */
- (void)viewDidUnload {
    [self setBtnDelete:nil];
    [self setBtnCopy:nil];
    [self setBtnPaste:nil];
    [self setBtnSelect:nil];
    [self setBtnVoice:nil];
    [self setBtnPhoto:nil];
    [self setBtnAddFood:nil];
    [self setCaloriesProgess:nil];
    [self setSodiumProgress:nil];
    [self setFluidProgress:nil];
    [self setProteinProgess:nil];
    [self setCarbProgress:nil];
    [self setFatProgress:nil];
    [self setLblFooterTitle:nil];
    [self setLblFooterNote:nil];
    [self setBtnMonth:nil];
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self hideFoodDetail];

    [self hideDeletePop:nil];
    [self hideCopyPop:nil];
    [self hidePastePop:nil];
}

-(void)setProgressViewColor:(CustomProgressView *) view {
    if (view.currentProgress * MAX_GM_KG < 1.2) {
        [view setFullColor:[UIColor redColor]];
    } else if (view.currentProgress * MAX_GM_KG < 1.7) {
        [view setFullColor:[UIColor greenColor]];
    } else {
        [view setFullColor:[UIColor redColor]];
    }
}

/**
 * update progress in the bottom info bar.
 */
- (void)updateProgress {
    float caloriesTotal = 0;
    float sodiumTotal = 0;
    float fluidTotal = 0;
    float proteinTotal = 0;
    float carbTotal = 0;
    float fatTotal = 0;
    for (FoodConsumptionRecord *item in self.foodConsumptionRecords) {
        caloriesTotal += [item.foodProduct.energy intValue] * [item.quantity floatValue];
        sodiumTotal += [item.foodProduct.sodium intValue] * [item.quantity floatValue];
        fluidTotal += [item.foodProduct.fluid floatValue] * [item.quantity floatValue];
        proteinTotal += [item.foodProduct.protein floatValue] * [item.quantity floatValue];
        carbTotal += [item.foodProduct.carb floatValue] * [item.quantity floatValue];
        fatTotal += [item.foodProduct.fat floatValue] * [item.quantity floatValue];
    }
    
    self.caloriesProgess.lblCurrent.text = [NSString stringWithFormat:@"%d", (int) caloriesTotal];
    self.sodiumProgress.lblCurrent.text = [NSString stringWithFormat:@"%d", (int) sodiumTotal];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:@"#.##"];
    self.fluidProgress.lblCurrent.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:fluidTotal]];

    [self.caloriesProgess.lblCurrent sizeToFit];
    [self.sodiumProgress.lblCurrent sizeToFit];
    [self.fluidProgress.lblCurrent sizeToFit];
    
    int x = self.caloriesProgess.lblCurrent.frame.origin.x + self.caloriesProgess.lblCurrent.frame.size.width;
    CGRect frame = self.caloriesProgess.lblTotal.frame;
    frame.origin.x = x + 2;
    self.caloriesProgess.lblTotal.frame = frame;
    
    x = self.sodiumProgress.lblCurrent.frame.origin.x + self.sodiumProgress.lblCurrent.frame.size.width;
    frame = self.sodiumProgress.lblTotal.frame;
    frame.origin.x = x + 2;
    self.sodiumProgress.lblTotal.frame = frame;
    
    x = self.fluidProgress.lblCurrent.frame.origin.x + self.fluidProgress.lblCurrent.frame.size.width;
    frame = self.fluidProgress.lblTotal.frame;
    frame.origin.x = x + 2;
    self.fluidProgress.lblTotal.frame = frame;
    
    self.proteinProgess.lblCurrent.text = [NSString stringWithFormat:@"%d Cal", (int) (proteinTotal * PROTEIN_CALORIES_FACTOR)];
    self.carbProgress.lblCurrent.text = [NSString stringWithFormat:@"%d Cal", (int) (carbTotal * CARB_CALORIES_FACTOR)];
    self.fatProgress.lblCurrent.text = [NSString stringWithFormat:@"%d Cal", (int) (fatTotal * FAT_CALORIES_FACTOR)];
    
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    float caloriesProgessPercentage = caloriesTotal * 1.0f / [appDelegate.loggedInUser.dailyTargetEnergy intValue];
    float sodiumProgressPercentage = sodiumTotal * 1.0f / [appDelegate.loggedInUser.dailyTargetSodium intValue];
    float fluidProgressPercentage = fluidTotal * 1.0f / [appDelegate.loggedInUser.dailyTargetFluid intValue];
    
    self.caloriesProgess.currentProgress = caloriesProgessPercentage;
    self.sodiumProgress.currentProgress = sodiumProgressPercentage;
    self.fluidProgress.currentProgress = fluidProgressPercentage;
    
    int maxConsumption = [appDelegate.loggedInUser.dailyTargetEnergy intValue];
    
    self.proteinProgess.lblPercent.text = [NSString stringWithFormat:@"%10d g", (int) proteinTotal];
    self.carbProgress.lblPercent.text = [NSString stringWithFormat:@"%10d g", (int) carbTotal];
    self.fatProgress.lblPercent.text = [NSString stringWithFormat:@"%10d g", (int) fatTotal];
    
    self.proteinProgess.currentProgress = 1.0;
    self.carbProgress.currentProgress =  1.0;
    self.fatProgress.currentProgress =  1.0;

    CGRect proteinProgressFrame = self.proteinProgess.progressView.frame;
    CGRect carbProgressFrame = self.carbProgress.progressView.frame;
    CGRect fatProgressFrame = self.fatProgress.progressView.frame;
    
    if (maxConsumption > 0) {
        proteinProgressFrame.size.width = (int)(proteinTotal * PROTEIN_CALORIES_FACTOR / maxConsumption * PROGRESSBAR_WIDTH);
        carbProgressFrame.size.width = (int)(carbTotal * CARB_CALORIES_FACTOR / maxConsumption * PROGRESSBAR_WIDTH);
        fatProgressFrame.size.width = (int)(fatTotal * FAT_CALORIES_FACTOR / maxConsumption * PROGRESSBAR_WIDTH);
    }
    else {
        proteinProgressFrame.size.width = 0;
        carbProgressFrame.size.width = 0;
        fatProgressFrame.size.width = 0;
    }
    
    CGFloat weight = appDelegate.loggedInUser.weight != nil ? appDelegate.loggedInUser.weight.floatValue : 70.0f;
    self.proteinProgess.currentProgress = (proteinTotal / weight) / MAX_GM_KG;
    self.curProteinValue.text = [NSString stringWithFormat:@"%3.1f", (proteinTotal / weight)];
    
    self.proteinProgess.lblCurrent.text = [NSString stringWithFormat:@"Protein (g/kg BW)"];
    
    [self setProgressViewColor:self.proteinProgess];
    [self.proteinProgess setGmKg:YES];
    
    float proteinCalories = proteinTotal * PROTEIN_CALORIES_FACTOR;
    float carbCalories = carbTotal * CARB_CALORIES_FACTOR;
    float fatCalories = fatTotal * FAT_CALORIES_FACTOR;
    float calories = proteinCalories + carbCalories + fatCalories;
    if (calories > 0) {
        proteinCalories = proteinCalories / calories;
        carbCalories = carbCalories / calories;
        fatCalories = fatCalories / calories;
        [self redrawPieChartWithProtein:proteinCalories carb:carbCalories fat:fatCalories];
    }
    else {
        [self redrawPieChartWithProtein:0.333 carb:0.333 fat:0.334];
    }
    
    self.proteinPercentageLabel.text = [NSString stringWithFormat:@"        %4.0f%% of Cal",
                                            floor(proteinCalories * 100)];
    self.carbPercentageLabel.text = [NSString stringWithFormat:@"        %4.0f%% of Cal",
                                           floor(carbCalories * 100)];
    self.fatPercentageLabel.text = [NSString stringWithFormat:@"        %4.0f%% of Cal",
                                          floor(fatCalories * 100)];

    self.caloriesProgess.lblPercent.text = [NSString stringWithFormat:@"%.0f%%",
                                            floor(caloriesProgessPercentage  * 100)];
    self.sodiumProgress.lblPercent.text = [NSString stringWithFormat:@"%.0f%%",
                                           floor(sodiumProgressPercentage * 100)];
    self.fluidProgress.lblPercent.text = [NSString stringWithFormat:@"%.0f%%",
                                          floor(fluidProgressPercentage * 100)];
}

/**
 * load food items by specify date.
 * @param date The date of foods want to load.
 */
- (void)loadFoodItemsForDate:(NSDate *)date {
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    if (!appDelegate.loggedInUser) {
        return;
    }
    FoodConsumptionRecordServiceImpl *recordService = appDelegate.foodConsumptionRecordService;
    [recordService.managedObjectContext processPendingChanges];

    NSError *error;
    NSArray *records = [recordService getFoodConsumptionRecords:appDelegate.loggedInUser date:date error:&error];
    if ([Helper displayError:error]) return;
    self.foodConsumptionRecords = [NSMutableArray arrayWithArray:records];
    
    NSInteger diffDays = [Helper daysFromToday:date];
    if (diffDays != 0) {
        self.lblFooterTitle.text = [NSString stringWithFormat:@"GMT %+ld Nutrient Intake Total", (long) diffDays];
    } else {
        self.lblFooterTitle.text = @"Today's Nutrient Intake Progress";
    }
    
    [self.foodTableView reloadData];
}

/**
 * action for check box button click. Add item to array or remove it. Update button status.
 * @param sender the check box button.
 */
- (void)foodSelect:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSInteger row = btn.tag;
    FoodConsumptionRecord *item = [self.foodConsumptionRecords objectAtIndex:row];
    if([selectedItems containsObject:item]){
        [selectedItems removeObject:item];
        [btn setSelected:NO];
    }
    else{
        [selectedItems addObject:item];
        [btn setSelected:YES];
    }
    BOOL canCopy = YES;
    for (FoodConsumptionRecord *record in selectedItems) {
        canCopy &= ![record.foodProduct.removed boolValue];
    }
    if (selectedItems.count == 0){
        [self.btnCopy setEnabled:NO];
        [self.btnDelete setEnabled:NO];
    } else {
        [self.btnCopy setEnabled:canCopy];
        [self.btnDelete setEnabled:YES];
    }
}

/**
 * Called when the consumption is updated.
 */
- (void) consumptionUpdated {
    [self updateProgress];
}

/*!
 Redraw the pie chart
 */
- (void) redrawPieChartWithProtein:(float)proteinRatio carb:(float)carbRatio fat:(float)fatRatio {
    if (self.pieChart) {
        [self.pieChart removeFromSuperview];
        self.pieChart = nil;
    }
    self.pieChart = [[BNPieChart alloc] initWithFrame:CGRectMake(440, 0, 130, 130)];
    [self.pieChart addSlicePortion:proteinRatio withName:@"BLANK" andImage:[UIImage imageNamed:@"icon_protein_pie.png"]];
    [self.pieChart addSlicePortion:carbRatio withName:@"BLANK" andImage:[UIImage imageNamed:@"icon_carb_pie.png"]];
    [self.pieChart addSlicePortion:fatRatio withName:@"BLANK" andImage:[UIImage imageNamed:@"icon_fat_pie.png"]];
    NSArray *colors = @[[BNColor colorWithRed:1.0 green:0.89 blue:0.89],
                        [BNColor colorWithRed:1.0 green:0.89 blue:0.79],
                        [BNColor colorWithRed:0.98 green:0.98 blue:0.85]];
    self.pieChart.colors = colors;
    [self.pieChart showLabels:NO];
    [self.progressView2 addSubview:self.pieChart];
}

#pragma mark - add food

/**
 * handle action for save button in add food view. Save food to list and reload table.
 */
- (void)addFoodDoneButtonClick{
    // Validate the quantity
    if (![Helper checkIsNumber:_addFood.txtQuantity.text]) {
        [Helper showAlert:@"Error" message:@"The quantity has to be a number."];
        return;
    }
    if ([_addFood.txtQuantity.text floatValue] > 10.0) {
        [Helper showAlert:@"Error" message:@"The quantity should be at most 10."];
        return;
    }
    
    // Validate the food name
    _addFood.txtFood.text = [_addFood.txtFood.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![Helper checkStringIsValid:_addFood.txtFood.text]) {
        [Helper showAlert:@"Error" message:@"The Food Name cannot be empty."];
        return;
    }
    
    if (![Helper checkIsNumber:_addFood.txtQuantity.text]) {
        [Helper showAlert:@"Error" message:@"The quantity has to be a number."];
        return;
    }
    
    _addFood.txtComment.text = [_addFood.txtComment.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    FoodConsumptionRecordServiceImpl *recordService = appDelegate.foodConsumptionRecordService;
    FoodProductServiceImpl *foodProductService = appDelegate.foodProductService;
    NSError *error;
    if (self.foodConsumptionRecordToAdd) {
        FoodProduct *foodProduct = [foodProductService getFoodProductByName:appDelegate.loggedInUser
                                                                       name:_addFood.txtFood.text
                                                                      error:&error];
        error = nil;
        
        if (!foodProduct) {
            if (self.adhocFoodProductToAdd) {
                [foodProductService addAdhocFoodProduct:appDelegate.loggedInUser
                                                product:self.adhocFoodProductToAdd
                                                  error:&error];
                if ([Helper displayError:error]) return;
                
                self.adhocFoodProductToAdd.name = _addFood.txtFood.text;
                self.adhocFoodProductToAdd.quantity = [NSNumber numberWithFloat:_addFood.txtQuantity.text.floatValue];
            }
        }
        
        self.foodConsumptionRecordToAdd.comments = _addFood.txtComment.text;
        self.foodConsumptionRecordToAdd.quantity = [NSNumber numberWithFloat:_addFood.txtQuantity.text.floatValue];
        
        NSString *time = _addFood.timeLabel.text;
        NSCalendar *calendar = [NSCalendar currentCalendar];
        [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
        NSDateComponents *components = [calendar components:(NSCalendarUnitYear |
                                                             NSCalendarUnitMonth |
                                                             NSCalendarUnitDay |
                                                             NSCalendarUnitHour |
                                                             NSCalendarUnitMinute)
                                                   fromDate:self.dateListView.currentDate];
        [components setCalendar:calendar];
        components.hour = [[time substringToIndex:2] intValue];
        components.minute = [[time substringFromIndex:3] intValue];
        self.foodConsumptionRecordToAdd.timestamp = [components date];

        [recordService addFoodConsumptionRecord:appDelegate.loggedInUser
                                         record:self.foodConsumptionRecordToAdd
                                          error:&error];
        if ([Helper displayError:error]) return;
        if (foodProduct) {
            // The food product already exists
            self.foodConsumptionRecordToAdd.foodProduct = foodProduct;
            self.foodConsumptionRecordToAdd.quantity = self.foodConsumptionRecordToAdd.quantity;
        } else {
            self.foodConsumptionRecordToAdd.foodProduct = self.adhocFoodProductToAdd;
            self.foodConsumptionRecordToAdd.quantity = self.adhocFoodProductToAdd.quantity;
        }
        
        [recordService saveFoodConsumptionRecord:self.foodConsumptionRecordToAdd error:&error];
        if ([Helper displayError:error]) return;

        if (recorderFilePath && recorderFilePath.count > 0) {
            for (NSString *filePath in recorderFilePath) {
                Media *media = [[Media alloc] initWithEntity:[NSEntityDescription
                                                              entityForName:@"Media"
                                                              inManagedObjectContext:self.foodConsumptionRecordToAdd.managedObjectContext]
                              insertIntoManagedObjectContext:self.foodConsumptionRecordToAdd.managedObjectContext];
                media.filename = filePath;
                media.removed = @NO;
                media.synchronized = @YES;

                [self.foodConsumptionRecordToAdd addVoiceRecordingsObject:media];
            }
        }

        [recordService saveFoodConsumptionRecord:self.foodConsumptionRecordToAdd error:&error];
        if ([Helper displayError:error]) return;

        //[self.foodConsumptionRecords addObject:self.foodConsumptionRecordToAdd];
        //[self.foodTableView reloadData];
        [_addFood.view removeFromSuperview];
        [clearCover removeFromSuperview];
        _addFood = nil;
        clearCover = nil;
        self.adhocFoodProductToAdd = nil;
        self.foodConsumptionRecordToAdd = nil;

        [recorderFilePath removeAllObjects];
        
        [self.btnAddFood setSelected:NO];

        if (self.foodConsumptionRecords.count > 0) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:self.foodConsumptionRecords.count-1 inSection:0];
            [self.foodTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DataSyncUpdate object:self.dateListView.currentDate];
    }
    [self updateProgress];
    [self stopCommentDictation];
}
/**
 * handle action for cancel button in add food view. Just hide the add food view.
 */
- (void)addFoodCancelButtonClick{
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    FoodConsumptionRecordServiceImpl *recordService = appDelegate.foodConsumptionRecordService;
    FoodProductServiceImpl *foodProductService = appDelegate.foodProductService;
    
    NSError *error;
    if (self.foodConsumptionRecordToAdd) {
        [recordService deleteFoodConsumptionRecord:self.foodConsumptionRecordToAdd error:&error];
        if ([Helper displayError:error]) return;
        self.foodConsumptionRecordToAdd = nil;
    }
    if (self.adhocFoodProductToAdd) {
        [foodProductService deleteAdhocFoodProduct:self.adhocFoodProductToAdd error:&error];
        if ([Helper displayError:error]) return;
        self.adhocFoodProductToAdd = nil;
    }
    
    [_addFood.view removeFromSuperview];
    [clearCover removeFromSuperview];
    _addFood = nil;
    clearCover = nil;
    
    [self.btnAddFood setSelected:NO];
    [self stopCommentDictation];
}
/**
 * handle action for add button click. Pop add food view and bind button action.
 * @param sender the button.
 */
- (IBAction)showAddFoodPopover:(id)sender{
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    FoodConsumptionRecordServiceImpl *recordService = appDelegate.foodConsumptionRecordService;
    FoodProductServiceImpl *foodProductService = appDelegate.foodProductService;
    NSError *error;
    self.adhocFoodProductToAdd = [foodProductService buildAdhocFoodProduct:&error];
    if ([Helper displayError:error]) return;
    self.foodConsumptionRecordToAdd = [recordService buildFoodConsumptionRecord:&error];
    if ([Helper displayError:error]) return;
    
    [self.btnAddFood setSelected:YES];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:self.view.frame];
    [btn addTarget:self action:@selector(addFoodCancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor clearColor];
    clearCover = btn;
    [self.view addSubview:clearCover];
    
    _addFood = [self.storyboard instantiateViewControllerWithIdentifier:@"AddFoodView"];
    [self.view addSubview:_addFood.view];
    _addFood.view.frame = CGRectMake(0, 154, 768, 192);
    
    [_addFood.btnDone addTarget:self action:@selector(addFoodDoneButtonClick)
               forControlEvents:UIControlEventTouchUpInside];
    [_addFood.btnCancel addTarget:self action:@selector(addFoodCancelButtonClick)
                 forControlEvents:UIControlEventTouchUpInside];
    [_addFood.btnVoice addTarget:self action:@selector(startCommentDictation:)
                 forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - food Details

/**
 * hide food detail view.
 */
- (void)hideFoodDetail{
    if (looper) {
        [looper stop];
    }
    
    [clearCover removeFromSuperview];
    clearCover = nil;
    [foodDetail.view removeFromSuperview];
    foodDetail = nil;
    
    [self updateProgress];
    [self stopCommentDictation];
    
    [recorderFilePath removeAllObjects];
}

/**
 * handle action for save button in detail view. save values in food detail and reload data.
 */
- (void)saveFoodDetail{
    // Validate the quantity
    if (![Helper checkIsNumber:foodDetail.txtQuantity.text]) {
        [Helper showAlert:@"Error" message:@"The quantity has to be a number."];
        return;
    }
    if ([foodDetail.txtQuantity.text floatValue] > 10.0) {
        [Helper showAlert:@"Error" message:@"The quantity should be at most 10."];
        return;
    }
    
    foodDetail.txtComment.text = [foodDetail.txtComment.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    foodDetail.txtFoodName.text = [foodDetail.txtFoodName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    FoodConsumptionRecordServiceImpl *recordService = appDelegate.foodConsumptionRecordService;
    NSError *error;

    if (foodDetail.txtFoodName.text.length == 0) {
        [Helper showAlert:@"Error" message:@"The Food Name cannot be empty."];
        return;
    }
    
    // handle food name change
    if ([foodDetail.foodConsumptionRecord.foodProduct isKindOfClass:[AdhocFoodProduct class]] &&
        ![foodDetail.foodConsumptionRecord.foodProduct.name isEqualToString:foodDetail.txtFoodName.text]) {
        FoodProductServiceImpl *foodService = appDelegate.foodProductService;
        AdhocFoodProduct *product = (AdhocFoodProduct *) foodDetail.foodConsumptionRecord.foodProduct;
        product.name = foodDetail.txtFoodName.text;

        [foodService updateAdhocFoodProduct:product error:&error];
        if ([Helper displayError:error]) return;
    }
    
    foodDetail.foodConsumptionRecord.quantity = [NSNumber numberWithFloat:foodDetail.txtQuantity.text.floatValue];
    foodDetail.foodConsumptionRecord.comments = foodDetail.txtComment.text;
    
    NSString *timeString = foodDetail.lblTime.text;
    // set date
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear |
                                                         NSCalendarUnitMonth |
                                                         NSCalendarUnitDay |
                                                         NSCalendarUnitHour |
                                                         NSCalendarUnitMinute)
                                               fromDate:self.dateListView.currentDate];
    [components setCalendar:calendar];
    components.hour = [[timeString substringToIndex:2] intValue];
    components.minute = [[timeString substringFromIndex:3] intValue];
    components.second = (int)round([foodDetail.foodConsumptionRecord.timestamp timeIntervalSince1970]) % 60;
    foodDetail.foodConsumptionRecord.timestamp = [components date];

    if (recorderFilePath && recorderFilePath.count > 0) {
        for (NSString *filePath in recorderFilePath) {
            Media *media = [[Media alloc] initWithEntity:[NSEntityDescription
                                                          entityForName:@"Media"
                                                          inManagedObjectContext:recordService.managedObjectContext]
                          insertIntoManagedObjectContext:recordService.managedObjectContext];
            media.filename = filePath;
            media.removed = @NO;
            media.synchronized = @YES;

            [foodDetail.foodConsumptionRecord addVoiceRecordingsObject:media];
        }
    }
    
    [recordService saveFoodConsumptionRecord:foodDetail.foodConsumptionRecord error:&error];
    if ([Helper displayError:error]) return;
    
    //[self.foodTableView reloadData];
    //[self updateProgress];
    [clearCover removeFromSuperview];
    clearCover = nil;
    [foodDetail.view removeFromSuperview];
    foodDetail = nil;
    [recorderFilePath removeAllObjects];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DataSyncUpdate object:self.dateListView.currentDate];
}

/**
 * This method will show food consumption record details.
 * @param record the FoodConsumptionRecord.
 */
- (void)showFoodDetails:(FoodConsumptionRecord *)record{
    foodDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"FoodDetailView"];
    foodDetail.foodConsumptionRecord = record;
    
    clearCover = [[UIView alloc] initWithFrame:self.view.frame];
    clearCover.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
    [self.view addSubview:clearCover];
    
    foodDetail.view.frame = CGRectMake(88, 293, 592, 417);
    [self.view addSubview:foodDetail.view];
    [foodDetail.btnCancel addTarget:self
                             action:@selector(hideFoodDetail)
                   forControlEvents:UIControlEventTouchUpInside];

    if ([record.foodProduct.removed boolValue]) {
        [foodDetail.btnSave setHidden:YES];
        [foodDetail.btnVoice setHidden:YES];
        [foodDetail.btnVoicePlay setHidden:YES];
        [foodDetail.txtFoodName setUserInteractionEnabled:NO];
        [foodDetail.txtComment setUserInteractionEnabled:NO];
        [foodDetail.txtQuantity setUserInteractionEnabled:NO];
    }

    [foodDetail.btnSave addTarget:self
                           action:@selector(saveFoodDetail)
                 forControlEvents:UIControlEventTouchUpInside];
    
    [foodDetail.btnVoice addTarget:self
                           action:@selector(startCommentDictation:)
                 forControlEvents:UIControlEventTouchUpInside];
    
    [foodDetail.btnVoicePlay addTarget:self
                            action:@selector(playVoiceRecordings:)
                  forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Calendar

/**
 * handle calendar swipe.
 * @param recognizer the gesture object
 */
- (void)handleDateSwipe:(UIGestureRecognizer *) recognizer {
    UISwipeGestureRecognizer *rec = (UISwipeGestureRecognizer *) recognizer;
    if (rec.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    int direction = 0;
    if (rec.direction == UISwipeGestureRecognizerDirectionLeft) {
        direction = 1;
    } else if (rec.direction == UISwipeGestureRecognizerDirectionRight) {
        direction = -1;
    }
    
    NSDate *newDate = [self.dateListView.currentDate dateByAddingTimeInterval:direction * 7 * 24 * 3600];
    [self calendarDidSelect:newDate];
}

/**
 * handle action for date click in date list view.
 * @param date the selected date.
 */
- (void)clickDate:(NSDate *)date{
    [self loadFoodItemsForDate:date];
}

/**
 * CalendarViewDelegate method. Called when select a date in calendar view.
 * @param date the selected data.
 */
- (void)calendarDidSelect:(NSDate *)date{
    self.dateListView.currentDate = date;
    [self.dateListView setNeedsDisplay];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    gregorian.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSDateComponents *info = [gregorian components:(NSCalendarUnitYear |
                                                    NSCalendarUnitMonth |
                                                    NSCalendarUnitDay |
                                                    NSCalendarUnitWeekday)
                                          fromDate:self.dateListView.currentDate];
    
    self.lblMonth.text = [Helper monthName:info.month];
    self.lblYear.text = [NSString stringWithFormat:@"GMT %ld", (long) info.year];
    [self.btnMonth setSelected:NO];
    
    [self loadFoodItemsForDate:date];
}

/**
 * handle action for month button click. Showing calendar pop over.
 * @param sender the button.
 */
- (IBAction)showMonthPopover:(id)sender {
    UIButton *btn = (UIButton *)sender;
    [self.btnMonth setSelected:YES];
    CalendarViewController *calendar = [self.storyboard instantiateViewControllerWithIdentifier:@"CalendarView"];
    calendar.delegate = self;
    UIPopoverController *popController = [[UIPopoverController alloc] initWithContentViewController:calendar];
    popController.popoverBackgroundViewClass = [PopoverBackgroundView class];
    popController.popoverContentSize = CGSizeMake(367, 438);
    popController.delegate = self;
    calendar.popController = popController;
    calendar.selectedDate = self.dateListView.currentDate;
    CGRect popoverRect = CGRectMake(btn.bounds.origin.x,
                                    btn.bounds.origin.y,
                                    1,
                                    43);
    
    [popController presentPopoverFromRect:popoverRect
                                   inView:btn
                 permittedArrowDirections:UIPopoverArrowDirectionUp
                                 animated:NO];
}

#pragma mark - copy, delete, past
/**
 * handle action for copy button.
 * @param sender the button.
 */
- (IBAction)copySelected:(id)sender{
    [copyItems removeAllObjects];
    [copyItems addObjectsFromArray:selectedItems];
    [selectedItems removeAllObjects];
    //[self.foodTableView reloadData];
    [self.btnCopy setEnabled:NO];
    [self.btnDelete setEnabled:NO];
    [self.btnPaste setEnabled:YES];
    [self hideCopyPop:nil];
}
/**
 * This method will paste selected records.
 * @param sender the button.
 */
- (IBAction)pasteSelected:(id)sender{
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    FoodConsumptionRecordServiceImpl *recordService = appDelegate.foodConsumptionRecordService;
    NSError *error;
    for (FoodConsumptionRecord *record in copyItems) {
        [recordService copyFoodConsumptionRecord:record copyToDay:self.dateListView.currentDate
                                           error:&error];
        if ([Helper displayError:error]) return;
        //[self.foodConsumptionRecords addObject:copyRecord];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:DataSyncUpdate object:self.dateListView.currentDate];

    [copyItems removeAllObjects];
    //[self.foodTableView reloadData];
    //[self updateProgress];
    [self.btnPaste setEnabled:NO];
    [self hidePastePop:nil];

    if (self.foodConsumptionRecords.count > 0) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:self.foodConsumptionRecords.count-1 inSection:0];
        [self.foodTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}
/**
 * handle action for delete button. Just pop over delete confirm dialog.
 * @param sender the button.
 */
- (IBAction)showDeletePop:(id)sender{
    
    UIButton *btn = [[UIButton alloc] initWithFrame:self.view.frame];
    [btn addTarget:self action:@selector(hideDeletePop:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor clearColor];
    clearCover = btn;
    [self.view addSubview:clearCover];
    
    [self.view bringSubviewToFront:self.deletePopup];
    self.deletePopup.hidden = NO;
    [self.btnDelete setSelected:YES];
}
/**
 * handle action for hiding delete confirm dialog.
 * @param sender the button.
 */
- (IBAction)hideDeletePop:(id)sender{
    
    [clearCover removeFromSuperview];
    clearCover = nil;
    [self.btnDelete setSelected:NO];
    
    self.deletePopup.hidden = YES;
}
/**
 * This method will delete selected records.
 * @param sender the button.
 */
- (IBAction)deleteSelected:(id)sender{
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    FoodConsumptionRecordServiceImpl *recordService = appDelegate.foodConsumptionRecordService;
    NSError *error;
    for (FoodConsumptionRecord *record in selectedItems) {
        // clear from copy
        [copyItems removeObject:record];
        if (copyItems.count == 0) {
            [self.btnPaste setEnabled:NO];
        }
        
        // F2Finish change
        [contentOffset removeObjectForKey:record.objectID];
        
        // [self.foodConsumptionRecords removeObject:record];
        [recordService deleteFoodConsumptionRecord:record error:&error];
        if ([Helper displayError:error]) return;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:DataSyncUpdate object:self.dateListView.currentDate];
    
    //[self.foodTableView reloadData];
    //[self updateProgress];
    [selectedItems removeAllObjects];
    [self hideDeletePop:nil];
}

/**
 * handle action for copy button. Just pop over copy confirm dialog.
 * @param sender the button.
 */
- (IBAction)showCopyPop:(id)sender{
    
    UIButton *btn = [[UIButton alloc] initWithFrame:self.view.frame];
    [btn addTarget:self action:@selector(hideCopyPop:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor clearColor];
    clearCover = btn;
    [self.view addSubview:clearCover];
    
    [self.view bringSubviewToFront:self.consumptionCopyPopup];
    self.consumptionCopyPopup.hidden = NO;
    [self.btnCopy setSelected:YES];
}
/**
 * handle action for hiding copy confirm dialog.
 * @param sender the button.
 */
- (IBAction)hideCopyPop:(id)sender{
    
    [clearCover removeFromSuperview];
    clearCover = nil;
    [self.btnCopy setSelected:NO];
    
    self.consumptionCopyPopup.hidden = YES;
}

/**
 * handle action for paste button. Just pop over paste confirm dialog.
 * @param sender the button.
 */
- (IBAction)showPastePop:(id)sender{
    
    UIButton *btn = [[UIButton alloc] initWithFrame:self.view.frame];
    [btn addTarget:self action:@selector(hideCopyPop:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor clearColor];
    clearCover = btn;
    [self.view addSubview:clearCover];
    
    [self.view bringSubviewToFront:self.pastePopup];
    self.pastePopup.hidden = NO;
    [self.btnPaste setSelected:YES];
}
/**
 * handle action for hiding paste confirm dialog.
 * @param sender the button.
 */
- (IBAction)hidePastePop:(id)sender{
    
    [clearCover removeFromSuperview];
    clearCover = nil;
    [self.btnPaste setSelected:NO];
    
    self.pastePopup.hidden = YES;
}

/**
 * handle action for delete a single row.
 * @param sender the button.
 */
- (void)deleteItem:(id)sender{
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    FoodConsumptionRecordServiceImpl *recordService = appDelegate.foodConsumptionRecordService;
    NSError *error;
    
    UIButton *btn = (UIButton *)sender;
    int row = btn.tag;
    SummaryFoodTableCell *cell = (SummaryFoodTableCell *)[self.foodTableView cellForRowAtIndexPath:
                                                          [NSIndexPath indexPathForRow:row
                                                                             inSection:0]];
    [cell setEditing:NO animated:YES];
    if(cell.btnDone == btn){
        // F2Finish change
        [contentOffset removeObjectForKey:cell.foodConsumptionRecord.objectID];
        
        [self.foodConsumptionRecords removeObjectAtIndex:row];
        [recordService deleteFoodConsumptionRecord:cell.foodConsumptionRecord error:&error];
        if ([Helper displayError:error]) return;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DataSyncUpdate object:self.dateListView.currentDate];
    }
    //[self.foodTableView reloadData];
    //[self updateProgress];
}

#pragma mark - photo option
/**
 * handle action for photo button click. Showing photo option pop.
 * @param sender the button.
 */
- (IBAction)showOptionPopup:(id)sender{
    [self.btnPhoto setSelected:YES];
    UIButton *btn = [[UIButton alloc] initWithFrame:self.view.frame];
    [btn addTarget:self action:@selector(hideOptionPopup:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor clearColor];
    clearCover = btn;
    [self.view addSubview:clearCover];
    
    [self.view bringSubviewToFront:self.optionPopup];
    self.optionPopup.hidden = NO;
}
/**
 * hide photo option pop.
 * @param sender the button.
 */
- (IBAction)hideOptionPopup:(id)sender{
    [clearCover removeFromSuperview];
    clearCover = nil;
    self.optionPopup.hidden = YES;
    [self.btnPhoto setSelected:NO];
}

/**
 * set the custom tabbar view controller here.
 * @param segue The segue object containing information about the view controllers involved in the segue.
 * @param sender The object that initiated the segue.
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.destinationViewController respondsToSelector:@selector(setCustomTabBarController:)]){
        [segue.destinationViewController setCustomTabBarController:self.customTabBarController];
    }
}
#pragma mark - voice search
/**
 * handle action for voice button. Showing voice search view.
 * @param sender the button.
 */
- (IBAction)showVoice:(id)sender{
    UIButton *btn = [[UIButton alloc] initWithFrame:self.view.frame];
    //[btn addTarget:self action:@selector(hideVoice:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
    clearCover = btn;
    [self.view addSubview:clearCover];
    
    voiceSearch = [self.storyboard instantiateViewControllerWithIdentifier:@"VoiceSearchView"];
    voiceSearch.view.frame = CGRectMake(173, 203, 422, 598);
    voiceSearch.consumptionViewController = self;
    [self.view addSubview:voiceSearch.view];
    
    [voiceSearch.btnCancel addTarget:self
                              action:@selector(hideVoice:)
                    forControlEvents:UIControlEventTouchUpInside];
    /*[voiceSearch.btnDone addTarget:self
                            action:@selector(hideVoice:)
                  forControlEvents:UIControlEventTouchUpInside];*/
    
    [voiceSearch.btnAddToConsumption addTarget:self
                                        action:@selector(hideVoice:)
                              forControlEvents:UIControlEventTouchUpInside];
}
/**
 * This method will add consumption records for selected food products.
 * @param sender the button.
 */
- (void)hideVoice:(id)sender{
    if ([voiceSearch.selectedFoodProducts count] > 0) {
        AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        FoodConsumptionRecordServiceImpl *recordService = appDelegate.foodConsumptionRecordService;
        NSError *error;
        
        for (FoodProduct *product in voiceSearch.selectedFoodProducts) {
            FoodConsumptionRecord *record = [recordService buildFoodConsumptionRecord:&error];
            if ([Helper displayError:error]) return;
            record.quantity = @1.0;
            record.foodProduct.fluid = product.fluid;
            record.foodProduct.sodium = product.sodium;
            record.foodProduct.energy = product.energy;
            record.foodProduct.protein = product.protein;
            record.foodProduct.carb = product.carb;
            record.foodProduct.fat = product.fat;
            record.timestamp = [Helper convertDateTimeToDate:self.dateListView.currentDate time:[NSDate date]];
            
            [recordService addFoodConsumptionRecord:appDelegate.loggedInUser record:record error:&error];

            record.foodProduct = [record.managedObjectContext objectWithID:product.objectID];
            if (recorderFilePath && recorderFilePath.count > 0) {
                for (NSString *filePath in recorderFilePath) {
                    Media *media = [[Media alloc] initWithEntity:[NSEntityDescription
                                                                  entityForName:@"Media"
                                                                  inManagedObjectContext:record.managedObjectContext]
                                  insertIntoManagedObjectContext:record.managedObjectContext];
                    media.filename = filePath;
                    media.removed = @NO;
                    media.synchronized = @YES;

                    [record addVoiceRecordingsObject:media];
                }
            }

            [recordService saveFoodConsumptionRecord:record error:&error];
            
            if ([Helper displayError:error]) return;
            //[self.foodConsumptionRecords addObject:record];
            //[self.foodTableView reloadData];
            
            [recorderFilePath removeAllObjects];

            if (self.foodConsumptionRecords.count > 0) {
                NSIndexPath *path = [NSIndexPath indexPathForRow:self.foodConsumptionRecords.count-1 inSection:0];
                [self.foodTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }

        [voiceSearch.selectedFoodProducts removeAllObjects];
        //[self.foodTableView reloadData];
        //[self updateProgress];
        [clearCover removeFromSuperview];
        clearCover = nil;
        
        [voiceSearch.view removeFromSuperview];
        voiceSearch = nil;

        [[NSNotificationCenter defaultCenter] postNotificationName:DataSyncUpdate object:self.dateListView.currentDate];
    } else {
        [clearCover removeFromSuperview];
        clearCover = nil;
        
        [voiceSearch.view removeFromSuperview];
        voiceSearch = nil;
        
        [recorder stop];
    }
}

#pragma mark - select consumption
/**
 * animation delegate method. Called when animation ends. Remove some hidden view here.
 * @param animationID An NSString containing the identifier.
 * @param finished An NSNumber object containing a Boolean value.
 * The value is YES if the animation ran to completion before it stopped or NO if it did not.
 * @param context This is the context data passed to the beginAnimations:context: method.
 */
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    if([animationID isEqualToString:@"hideSelectConsumption"]){
        [selectConsumption.view removeFromSuperview];
        selectConsumption = nil;
    }
}

/**
 * hide the select consumption view and cancel food add to consumption action.
 * @param sender the button or nil.
 */
- (void)cancelSelectConsumption:(id)sender {
    if(selectConsumption != nil){
        [selectConsumption.selectFoods removeAllObjects];
        [self.foodTableView reloadData];
        [self updateProgress];
        
        [self.navigationController popViewControllerAnimated:YES];
        [self.customTabBarController setConsumptionActive];
    }
}

/**
 * hide the select consumption view.
 * @param sender the button or nil.
 */
- (void)hideSelectConsumption:(id)sender{
    if(selectConsumption != nil){
        if ([selectConsumption.selectFoods count]> 0) {
            AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
            FoodConsumptionRecordServiceImpl *recordService = appDelegate.foodConsumptionRecordService;
            NSError *error;
            for (FoodProduct *product in selectConsumption.selectFoods) {
                FoodConsumptionRecord *record = [recordService buildFoodConsumptionRecord:&error];
                if ([Helper displayError:error]) return;
                record.quantity = @1.0;
                record.fluid = product.fluid;
                record.sodium = product.sodium;
                record.energy = product.energy;
                record.protein = product.protein;
                record.carb = product.carb;
                record.fat = product.fat;
                record.timestamp = [Helper convertDateTimeToDate:self.dateListView.currentDate time:[NSDate date]];
                
                [recordService addFoodConsumptionRecord:appDelegate.loggedInUser record:record error:&error];

                record.foodProduct = [record.managedObjectContext objectWithID:product.objectID];
                if (!record.foodProduct) {
                    NSString *msg = [NSString stringWithFormat:@"food %@ not found in managed context", product.name];
                    error = [NSError errorWithDomain:@"FoodService" code:IllegalArgumentErrorCode
                                            userInfo:@{NSUnderlyingErrorKey: msg}];
                    if ([Helper displayError:error]) return;
                }
                
                [recordService saveFoodConsumptionRecord:record error:&error];
                
                if ([Helper displayError:error]) return;
                //[self.foodConsumptionRecords addObject:record];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:DataSyncUpdate object:self.dateListView.currentDate];
            
            [selectConsumption.selectFoods removeAllObjects];
            //[self.foodTableView reloadData];
            //[self updateProgress];

            if (self.foodConsumptionRecords.count > 0) {
                NSIndexPath *path = [NSIndexPath indexPathForRow:self.foodConsumptionRecords.count-1 inSection:0];
                [self.foodTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }
        [self.navigationController popViewControllerAnimated:YES];
        [self.customTabBarController setConsumptionActive];
    }
}

/**
 * This method will play all voice recordings.
 * @param sender the button.
 */
- (IBAction)playVoiceRecordings:(id)sender {
    foodDetail.btnVoice.enabled = NO;
    foodDetail.btnVoicePlay.enabled = NO;
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:[foodDetail.foodConsumptionRecord.voiceRecordings allObjects]];
    if (recorderFilePath.count > 0) {
        [array addObjectsFromArray:recorderFilePath];
    }
    
    looper = [[Looper alloc] initWithFileNameQueue:array];
    looper.foodDetail = foodDetail;
    
    [looper start];
}

/**
 * This method will be called when the "mic" icon is clicked to turn on the comment dictation.
 * @param sender the button.
 */
- (IBAction)startCommentDictation:(id)sender {
    if (self.commentToUpdate) {
        _addFood.commentInstructionLabel.hidden = YES;
        foodDetail.commentInstructionLabel.hidden = YES;
        // Stop commenting
        [self stopCommentDictation];
    }
    else {
        // start listening for speech
        _addFood.commentInstructionLabel.text = @"Initializing...";
        foodDetail.commentInstructionLabel.text = @"Initializing...";
        _addFood.commentInstructionLabel.hidden = NO;
        foodDetail.commentInstructionLabel.hidden = NO;

        [_addFood.commentInstructionLabel sizeToFit];
        CGRect labelFrame = _addFood.commentInstructionLabel.frame;
        labelFrame.size.width += 7;
        labelFrame.size.height += 7;
        _addFood.commentInstructionLabel.frame = labelFrame;
        _addFood.commentInstructionLabel.center = CGPointMake(557.f, 102.f);

        [foodDetail.commentInstructionLabel sizeToFit];
        labelFrame = foodDetail.commentInstructionLabel.frame;
        labelFrame.size.width += 7;
        labelFrame.size.height += 7;
        foodDetail.commentInstructionLabel.frame = labelFrame;
        foodDetail.commentInstructionLabel.center = CGPointMake(280.f, 380.f);

        _addFood.commentInstructionLabel.layer.cornerRadius = 4.0f;
        foodDetail.commentInstructionLabel.layer.cornerRadius = 4.0f;

        listening = YES;
        
        if (foodDetail) {
            foodDetail.btnSave.enabled = NO;
            foodDetail.btnVoicePlay.enabled = NO;
        }
        if (_addFood) {
            _addFood.btnDone.enabled = NO;
        }
        
        NSDictionary *recordSetting = @{AVFormatIDKey: @(kAudioFormatMPEG4AAC),
                                        AVEncoderAudioQualityKey: @(AVAudioQualityMedium),
                                        AVNumberOfChannelsKey: @2};        
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/tmp.aac", DOCUMENTS_FOLDER]];
        NSError *err = nil;
        recorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
        if(!recorder){
            NSLog(@"recorder: %@ %d %@", [err domain], (int) [err code], [[err userInfo] description]);
            UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle: @"Warning"
                                       message: [err localizedDescription]
                                      delegate: nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
            [alert show];
            return;
        }

        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.3]];
        
        //prepare to record
        [recorder setDelegate:self];
        [recorder prepareToRecord];
        
        //start recording
        [recorder recordForDuration:120];
        
        _addFood.commentInstructionLabel.text = @"Speak now, tap the Mic icon to stop (< 2min)";
        foodDetail.commentInstructionLabel.text = @"Speak now, tap the Mic icon to stop (< 2min)";
        _addFood.commentInstructionLabel.hidden = NO;
        foodDetail.commentInstructionLabel.hidden = NO;

        [_addFood.commentInstructionLabel sizeToFit];
        labelFrame = _addFood.commentInstructionLabel.frame;
        labelFrame.size.width += 5;
        labelFrame.size.height += 5;
        _addFood.commentInstructionLabel.frame = labelFrame;
        _addFood.commentInstructionLabel.center = CGPointMake(557.f, 102.f);

        [foodDetail.commentInstructionLabel sizeToFit];
        labelFrame = foodDetail.commentInstructionLabel.frame;
        labelFrame.size.width += 5;
        labelFrame.size.height += 5;
        foodDetail.commentInstructionLabel.frame = labelFrame;
        foodDetail.commentInstructionLabel.center = CGPointMake(280.f, 380.f);

        UIButton *button = (UIButton *)sender;
        if ([button isEqual:foodDetail.btnVoice]) {
            self.commentToUpdate = foodDetail.txtComment;
        }
        else if ([button isEqual:_addFood.btnVoice]) {
            self.commentToUpdate = _addFood.txtComment;
        }
    }
}

/**
 * This method will be called when the "mic" icon is clicked to turn off the comment dictation.
 */
- (void)stopCommentDictation {
    // Stop listening for speech
    _addFood.commentInstructionLabel.text = @"Recording stopped";
    foodDetail.commentInstructionLabel.text = @"Recording stopped";
    _addFood.commentInstructionLabel.hidden = NO;
    foodDetail.commentInstructionLabel.hidden = NO;

    [_addFood.commentInstructionLabel sizeToFit];
    CGRect labelFrame = _addFood.commentInstructionLabel.frame;
    labelFrame.size.width += 5;
    labelFrame.size.height += 5;
    _addFood.commentInstructionLabel.frame = labelFrame;
    _addFood.commentInstructionLabel.center = CGPointMake(557.f, 102.f);

    [foodDetail.commentInstructionLabel sizeToFit];
    labelFrame = foodDetail.commentInstructionLabel.frame;
    labelFrame.size.width += 5;
    labelFrame.size.height += 5;
    foodDetail.commentInstructionLabel.frame = labelFrame;
    foodDetail.commentInstructionLabel.center = CGPointMake(280.f, 380.f);

    if (listening) {
        [recorder stop];
        listening = NO;
    }

    [self performSelector:@selector(hideCommentInstructionLabel) withObject:nil afterDelay:2];

    self.commentToUpdate = nil;
}

- (void)hideCommentInstructionLabel{
    _addFood.commentInstructionLabel.hidden = YES;
    foodDetail.commentInstructionLabel.hidden = YES;
}

/**
 * handle action for showing select consumption view.
 * @param sender the button.
 */
- (IBAction)showSelectConsumption:(id)sender {
    [self viewDidDisappear:NO];
    
    self.customTabBarController.imgConsumption.image = [UIImage imageNamed:@"icon-consumption"];
    [self.customTabBarController.btnConsumption setImage:nil forState:UIControlStateNormal];
    self.customTabBarController.activeTab = 0;
    selectConsumption = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectConsumptionView"];
    [self.navigationController pushViewController:selectConsumption animated:YES];
    [self performSelector:@selector(bindSelectionConsumptionBackButton) withObject:nil afterDelay:0.1];
}

- (void) bindSelectionConsumptionBackButton {
    [selectConsumption.btnBack addTarget:self
                                  action:@selector(cancelSelectConsumption:)
                        forControlEvents:UIControlEventTouchUpInside];
    
    [selectConsumption.btnBack addTarget:self
                                  action:@selector(hideSelectConsumption:)
                        forControlEvents:UIControlEventApplicationReserved];
}

#pragma mark - Water method

/**
 * handle water button clicked.
 * @param sender the button.
 */
- (IBAction)addWaterButtonClicked:(id)sender {
    if ([self.fluidProgress.lblCurrent.text integerValue] > 9999) {
        return;
    }

    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    FoodConsumptionRecordServiceImpl *recordService = appDelegate.foodConsumptionRecordService;
    FoodProductServiceImpl *foodProductService = appDelegate.foodProductService;
    
    NSString *name = @"Drinking Water";
    NSError *error = nil;

    FoodProduct *foodProduct = [foodProductService getFoodProductByName:appDelegate.loggedInUser
                                                                   name:name
                                                                  error:&error];
    if (!foodProduct) {
        error = [NSError errorWithDomain:@"FoodService" code:IllegalArgumentErrorCode
                                userInfo:@{NSUnderlyingErrorKey: @"no such food (Drinking Water)"}];
        if ([Helper displayError:error]) return;
    } else {
        FoodConsumptionRecord *record = [recordService buildFoodConsumptionRecord:&error];
        if ([Helper displayError:error]) return;

        record.timestamp = [Helper convertDateTimeToDate:self.dateListView.currentDate time:[NSDate date]];
        record.quantity = @1.0;
        record.fat = [foodProduct.fat copy];
        record.carb = [foodProduct.carb copy];
        record.energy = [foodProduct.energy copy];
        record.protein = [foodProduct.protein copy];
        record.sodium = [foodProduct.sodium copy];
        record.fluid = [foodProduct.fluid copy];

        [recordService addFoodConsumptionRecord:appDelegate.loggedInUser record:record error:&error];
        if ([Helper displayError:error]) return;

        record.foodProduct = foodProduct;
        
        [recordService saveFoodConsumptionRecord:record error:&error];
        if ([Helper displayError:error]) return;

        //[self.foodConsumptionRecords addObject:record];
        //[self.foodTableView reloadData];

        if (self.foodConsumptionRecords.count > 0) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:self.foodConsumptionRecords.count-1 inSection:0];
            [self.foodTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:DataSyncUpdate object:self.dateListView.currentDate];
    }
}

#pragma mark - UIPopover Delegate Methods
/**
 * UIPopoverDelegate methods. Called when popover is hidden.
 * @param popoverController the hidden Popover.
 */
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    if ([popoverController.contentViewController isKindOfClass:[CalendarViewController class]]) {
        [self.btnMonth setSelected:NO];
    }
}

#pragma mark - UITableView Delegate Methods
/**
 * returns the row number of table in the section.
 * @param tableView the table requesting the row number.
 * @param section the section of the table.
 * @return the number of fooditems.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    [selectedItems removeAllObjects];
    if (selectedItems.count == 0) {
        [self.btnCopy setEnabled:NO];
        [self.btnDelete setEnabled:NO];
    } else {
        [self.btnCopy setEnabled:YES];
        [self.btnDelete setEnabled:YES];
    }
    /*if(copyItems.count == 0){
        [self.btnCopy setEnabled:NO];
    }
    else{
        [self.btnCopy setEnabled:YES];
    }*/
    [self updateProgress];
    return self.foodConsumptionRecords.count;
}

/**
 * tells the table what the cell will be like. Update cell content here.
 * @param tableView the table view the cell in.
 * @param indexPath the position the cell in the table.
 * @return an updated cell.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *SummaryFoodTableCellIdentifier = @"SummaryFoodTableCellIdentifier";
    SummaryFoodTableCell *cell = [tableView dequeueReusableCellWithIdentifier:SummaryFoodTableCellIdentifier];
    int row = indexPath.row;
    cell.btnCheck.tag = row;
    cell.btnDone.tag = row;
    cell.btnUndo.tag = row;
    [cell.btnDone addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnUndo addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnCheck addTarget:self action:@selector(foodSelect:) forControlEvents:UIControlEventTouchUpInside];
    FoodConsumptionRecord *item = [self.foodConsumptionRecords objectAtIndex:row];
    cell.foodConsumptionRecord = item;
    if ([selectedItems containsObject:item]) {
        [cell.btnCheck setSelected:YES];
    } else {
        [cell.btnCheck setSelected:NO];
    }
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:@"#.##"];
    cell.lblQuantity.text = [numberFormatter stringFromNumber:item.quantity];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour |
                                                         NSCalendarUnitMinute)
                                               fromDate:item.timestamp];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    
    cell.lblTime.text = [NSString stringWithFormat:@"%.2ld:%.2ld", (long) hour, (long) minute];
    cell.lblName.text = item.foodProduct.name;
    cell.lblName.textColor = [UIColor colorWithRed:68.f/255.f green:68.f/255.f blue:68.f/255.f alpha:1];
    if ([item.foodProduct.removed boolValue] && ![item.foodProduct isKindOfClass:[AdhocFoodProduct class]]) {
        cell.lblName.textColor = [UIColor colorWithRed:192.f/255.f green:0 blue:0 alpha:1];
    }

    if(item.foodProduct.energy.intValue == 0 && item.foodProduct.sodium.intValue == 0 &&
       item.foodProduct.fluid.intValue == 0){
        cell.btnNonNutrient.hidden = NO;
        cell.nutrientView.hidden = YES;
    }
    else{
        cell.btnNonNutrient.hidden = YES;
        cell.nutrientView.hidden = NO;
        cell.lblCalories.text = [NSString stringWithFormat:@"%@", item.foodProduct.energy];
        cell.lblSodium.text = [NSString stringWithFormat:@"%@", item.foodProduct.sodium];
        cell.lblFluid.text = [numberFormatter stringFromNumber:item.foodProduct.fluid];
        cell.lblProtein.text = [NSString stringWithFormat:@"%@", item.foodProduct.protein];
        cell.lblCarb.text = [NSString stringWithFormat:@"%@", item.foodProduct.carb];
        cell.lblFat.text = [NSString stringWithFormat:@"%@", item.foodProduct.fat];
    }
    
    // F2Finish change
    cell.nutrientScrollView.tag = row;
    if ([contentOffset objectForKey:item.objectID]) {
        NSValue *value = [contentOffset objectForKey:item.objectID];
        cell.nutrientScrollView.contentOffset = [value CGPointValue];
    } else {
        cell.nutrientScrollView.contentOffset = CGPointZero;
    }
    
    cell.btnComment.hidden = YES;
    if(item.comments.length > 0){
        cell.btnComment.hidden = NO;
    }
    if(cell.editing){
        cell.deleteView.hidden = NO;
    }
    else{
        cell.deleteView.hidden = YES;
    }

    cell.fluidAmount = [self.fluidProgress.lblCurrent.text integerValue];
    cell.caloriesAmount = [self.caloriesProgess.lblCurrent.text integerValue];
    cell.sodiumAmount = [self.sodiumProgress.lblCurrent.text integerValue];

    NSLog(@"Got record (%@) with name %@ at %@ with sync %@", item.id, item.foodProduct.name, item.timestamp, item.synchronized);

    cell.loadingView.hidden = item.synchronized.boolValue || ![[WebserviceCoreData instance] canConnect];
    if (cell.loadingView.hidden) {
        [(UIActivityIndicatorView *)[cell.loadingView viewWithTag:10] stopAnimating];
    } else {
        [(UIActivityIndicatorView *)[cell.loadingView viewWithTag:10] startAnimating];
    }

    [cell setNeedsDisplay];
    return cell;
}

/**
 * action for row selected. Call show food details to showing the detail view.
 * @param tableView the table informing the delegate about the new row selection.
 * @param indexPath the index path of the selected row.
 * @return the SummaryFoodTableCell.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SummaryFoodTableCell *cell = (SummaryFoodTableCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.editing) {
        return;
    }
    int row = indexPath.row;
    FoodConsumptionRecord *item = [self.foodConsumptionRecords objectAtIndex:row];
    if (item.synchronized.boolValue || ![[WebserviceCoreData instance] canConnect]) {
        [self showFoodDetails:item];
    }
}

/**
 * tells the table if the row of indexpath could be eidt or not.
 * @param tableView The table-view object requesting this information.
 * @param indexPath An index path locating a row in tableView.
 * @return Always return YES here.
 */
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    int row = indexPath.row;
    FoodConsumptionRecord *item = [self.foodConsumptionRecords objectAtIndex:row];
    return item.synchronized.boolValue || ![[WebserviceCoreData instance] canConnect];
}
/**
 * update the cell editing value here. Always return UITableViewCellEditingStyleNone to 
 * disable showing delete button.
 * @param tableView The table-view object requesting this information.
 * @param indexPath An index path locating a row in tableView.
 */
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    SummaryFoodTableCell *cell = (SummaryFoodTableCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell setEditing:!cell.editing animated:YES];
    return  UITableViewCellEditingStyleNone;
}

/**
 * just implement this method to enable table enter edit mode.
 * @param tableView The table-view object requesting this information.
 * @param indexPath An index path locating a row in tableView.
 * @param editingStyle The eidting style.
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Page control

/**
 * action for list page control's page number changed.
 * @param sender the page control.
 */
- (IBAction)pageControlDidChange:(id)sender {
    int width = self.bottomScrollView.frame.size.width;
    int height = self.bottomScrollView.frame.size.height;
    int current = self.pageControl.currentPage;
    [self.bottomScrollView scrollRectToVisible:CGRectMake(width * current, 0, width, height)
                                         animated:YES];
}

// F2Finish change - add delegate
#pragma mark - UIScrollView delegate

/**
 * detect a scroll in UIScrollView.
 * @param scrollView The scroll-view object in which the scrolling occurred.
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (![scrollView isEqual:self.foodTableView] &&
        ![scrollView isEqual:self.bottomScrollView]) {
        FoodConsumptionRecord *item = [self.foodConsumptionRecords objectAtIndex:scrollView.tag];
        CGPoint point = scrollView.contentOffset;
        NSValue *value = [NSValue valueWithCGPoint:point];
        [contentOffset setObject:value forKey:item.objectID];
    }
}
/**
 * Obtain the change in content offset from scrollView and draw the affected portion of the content view.
 * @param scrollView The scroll-view object that is performing the scrolling animation.
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (![scrollView isEqual:self.bottomScrollView]) {
        return;
    }
    
    int width = self.bottomScrollView.frame.size.width;
    int current = floor(scrollView.contentOffset.x / width + 0.5);
    if(current != self.pageControl.currentPage){
        self.pageControl.currentPage = current;
    }
}


#pragma mark - AVAudioRecorderDelegate methods

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)aRecorder successfully:(BOOL)flag {
    [self audioRecorderEndInterruption:aRecorder withOptions:0];
}

- (void)audioRecorderEndInterruption:(AVAudioRecorder *)aRecorder withOptions:(NSUInteger)flags {
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/tmp.aac", DOCUMENTS_FOLDER]];
    NSError *err = nil;
    NSData *audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:&err];
    if ([Helper displayError:err]) return;
    
    //[recorder deleteRecording];
    NSFileManager *fm = [NSFileManager defaultManager];
    err = nil;
    [fm removeItemAtPath:[url path] error:&err];
    if ([Helper displayError:err]) return;
    
    NSString *audioPath = [Helper saveVoiceRecording:audioData];
    [recorderFilePath addObject:audioPath];
    
    if (voiceSearch) {
        NSString *name = @"Intake From Voice";
        NSError *error = nil;
        
        AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        FoodProductServiceImpl *foodProductService = appDelegate.foodProductService;
        AdhocFoodProduct *product = [foodProductService buildAdhocFoodProduct:&error];
        product.quantity = @1.0;
        product.name = name;
        [foodProductService addAdhocFoodProduct:appDelegate.loggedInUser
                                        product:product
                                          error:&error];
        [voiceSearch.selectedFoodProducts addObject:product];

        [self hideVoice:nil];
    }
    
    if (foodDetail) {
        foodDetail.btnSave.enabled = YES;
        foodDetail.btnVoicePlay.enabled = YES;
    }
    if (_addFood) {
        _addFood.btnDone.enabled = YES;
    }
}

#pragma mark - UIGestureRecognizer methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

@end
