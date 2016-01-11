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
//  VoiceSearchViewController.m
//  FoodIntakeTracker
//
//  Created by lofzcx 06/12/2013
//

#import "VoiceSearchViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "FoodProductServiceImpl.h"
#import "Helper.h"
#import "Settings.h"

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@interface VoiceSearchViewController (){
    /* the select photo count */
    int selectPhotos;
    /* Audio record objects */
    AVAudioRecorder *recorder;
    /* Elapsed timer */
    NSTimer *timer;
    NSInteger timeElapsed;
}

@end

@implementation VoiceSearchViewController

@synthesize consumptionViewController;

/**
 * set the title font here.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.lblTitle.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:24];
    self.lblTitle.text = @"Record Food Intake";
    
    // Retrieve language model paths
    self.searchResult = [NSMutableArray array];
    self.selectedFoodProducts = [NSMutableArray array];
    self.btnSpeak.enabled = NO;
    [self.lblSubTitle setTextColor:[UIColor blackColor]];
    self.lblSubTitle.text = @"Initializing...";
    self.resultsLabel.hidden = YES;
    self.noResultsMessageLabel.hidden = YES;
    self.topDivider.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AutoLogoutRenewEvent object:nil];
}

/**
 * release view resources after view unload by setting value nil.
 */
- (void)viewDidUnload {
    [self setLblSubTitle:nil];
    [self setLblTitle:nil];
    [self setBtnCancel:nil];
    [self setBtnDone:nil];
    [self setBtnSearchAgain:nil];
    [self setResultView:nil];
    [self setBtnAddToConsumption:nil];
    [self setScrollView:nil];
    [self setBtnSpeak:nil];
    [super viewDidUnload];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    NSDictionary *recordSetting = @{AVFormatIDKey: @(kAudioFormatMPEG4AAC),
                                    AVEncoderAudioQualityKey: @(AVAudioQualityMedium),
                                    AVNumberOfChannelsKey: @2};
    NSString *recorderFilePath = [NSString stringWithFormat:@"%@/tmp.aac", DOCUMENTS_FOLDER];
    
    NSURL *url = [NSURL fileURLWithPath:recorderFilePath];
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
    
    //prepare to record
    [recorder setDelegate:self.consumptionViewController];
    [recorder prepareToRecord];
    
    //start recording
    timeElapsed = 120;
    [recorder recordForDuration:120];
    
    [self.lblSubTitle setTextColor:[UIColor colorWithWhite:0.2f alpha:1.0f]];
    self.lblSubTitle.text = @"Speak Now (< 2min)";

    timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(updateSubTitle) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)updateSubTitle {
    timeElapsed--;
    if (timeElapsed >= 0) {
        NSInteger seconds = timeElapsed % 60;
        NSInteger minutes = timeElapsed / 60;

        self.lblSubTitle.text = [NSString stringWithFormat:@"Speak Now (%02ld:%2ld)", minutes, seconds];
    } else {
        [timer invalidate];
    }
}

/**
 * action for clicking at photo.
 * @param btn the button.
 */
- (void)clickPhoto:(UIButton *)btn{
    UIView *v = [btn.superview viewWithTag:10];
    if(v){
        [self.selectedFoodProducts removeObject:[self.searchResult objectAtIndex:btn.tag]];
        [v removeFromSuperview];
    }
    else{
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(83, 28, 29, 29)];
        img.image = [UIImage imageNamed:@"btn-checkmark.png"];
        img.tag = 10;
        [btn.superview addSubview:img];
        [self.selectedFoodProducts addObject:[self.searchResult objectAtIndex:btn.tag]];
    }
    if([self.selectedFoodProducts count] == 0){
        [self.btnAddToConsumption setEnabled:NO];
    }
    else{
        [self.btnAddToConsumption setEnabled:YES];
    }
}

/**
 * build grid photo list and make it visible.
 */
- (void)showResult{
    [self.selectedFoodProducts removeAllObjects];
    [self.btnAddToConsumption setEnabled:NO];
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:self.scrollView.frame];
    int rows = ceil([self.searchResult count] / 3.0);
    scroll.contentSize = CGSizeMake(scroll.frame.size.width, rows * 145 + 20);
    
    for (int i = 0; i < [self.searchResult count]; i++) {
        int x = (i % 3) * 122;
        int y = (i / 3) * 145;
        FoodProduct *product = (FoodProduct *)[self.searchResult objectAtIndex:i];
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(x, y, 122, 145)];
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(18, 20, 102, 94)];
        img.layer.borderColor = [UIColor colorWithRed:0.54 green:0.79 blue:1 alpha:1].CGColor;
        img.layer.borderWidth = 1;
        img.image = [UIImage imageNamed:product.productProfileImage];
        [v addSubview:img];
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 128, 100, 17)];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
        lbl.text = product.name;
        lbl.textColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1];
        [v addSubview:lbl];
        UIButton *btn = [[UIButton alloc] initWithFrame:img.frame];
        btn.tag = i;
        [btn addTarget:self action:@selector(clickPhoto:) forControlEvents:UIControlEventTouchUpInside];
        [v addSubview:btn];
        [scroll addSubview:v];
    }
    
    self.resultsLabel.hidden = NO;
    if ([self.searchResult count] == 0) {
        self.noResultsMessageLabel.hidden = NO;
    }
    self.topDivider.hidden = NO;

    [self.resultView insertSubview:scroll belowSubview:self.scrollView];
    [self.scrollView removeFromSuperview];
    self.scrollView = scroll;
    self.resultView.hidden = NO;
    self.btnCancel.hidden = YES;
    self.btnSearchAgain.hidden = NO;
}

/**
 * handle action for redo button.
 * @param sender the button.
 */
- (IBAction)doneButton:(id)sender {
    [recorder stop];
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

/**
 * handle action for redo button.
 * @param sender the button.
 */
- (IBAction)redoSearch:(id)sender {
    [self.lblSubTitle setTextColor:[UIColor blackColor]];
    self.lblSubTitle.text = @"Initializing...";
    self.btnSearchAgain.hidden = YES;
    self.btnCancel.hidden = NO;
    self.resultView.hidden = YES;
    self.resultsLabel.hidden = YES;
    self.noResultsMessageLabel.hidden = YES;
    self.topDivider.hidden = YES;
}

/**
 * handle action for analyze.
 * @param sender the button.
 */
- (IBAction)Analyze:(id)sender {
    // [pocketsphinxController stopListening];
    [self.btnSpeak setEnabled:NO];
    self.lblSubTitle.text = @"Analyzing...";
    [self performSelector:@selector(showResult) withObject:nil afterDelay:2];
}

@end
