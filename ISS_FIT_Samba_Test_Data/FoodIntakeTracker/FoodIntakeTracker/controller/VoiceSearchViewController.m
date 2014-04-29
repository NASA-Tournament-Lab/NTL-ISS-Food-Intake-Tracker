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
#import "SpeechRecognitionServiceImpl.h"
#import "FoodProductServiceImpl.h"
#import "Helper.h"
#import "Settings.h"

@interface VoiceSearchViewController (){
    /* the select photo count */
    int selectPhotos;
}

@end

@implementation VoiceSearchViewController

/**
 * set the title font here.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.lblTitle.font = [UIFont fontWithName:@"Bebas" size:24];
    // Initialize OpenEars
    pocketsphinxController = [[PocketsphinxController alloc] init];
    pocketsphinxController.returnNbest = TRUE;
    pocketsphinxController.nBestNumber = 9;
    openEarsEventsObserver = [[OpenEarsEventsObserver alloc] init];
    [openEarsEventsObserver setDelegate:self];
    // Retrieve language model paths
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    SpeechRecognitionServiceImpl *srService = appDelegate.speechRecognitionService;
    self.searchResult = [NSMutableArray array];
    self.selectedFoodProducts = [NSMutableArray array];
    self.btnSpeak.enabled = NO;
    [self.lblSubTitle setTextColor:[UIColor blackColor]];
    self.lblSubTitle.text = @"Initializing...";
    self.resultsLabel.hidden = YES;
    self.noResultsMessageLabel.hidden = YES;
    self.topDivider.hidden = YES;
    
    NSError *error;
    /* Uncomment to regenarte language models. */
    /*
    if ([srService updateFoodProductLanguageModel:&error]) {
        NSLog(@"Updated successfully");
    }
    */
    NSDictionary *dict = [srService getFoodProductLanguageModelPaths:&error];
    // start listening for speech
    [pocketsphinxController startListeningWithLanguageModelAtPath:[dict valueForKey:@"LMPath"]
                                                 dictionaryAtPath:[dict valueForKey:@"DictionaryPath"]
                                              languageModelIsJSGF:FALSE];
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
        lbl.font = [UIFont fontWithName:@"Helvetica Neue" size:15];
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
    self.btnDone.hidden = NO;
    self.btnSearchAgain.hidden = NO;
}

/**
 * handle action for redo button.
 * @param sender the button.
 */
- (IBAction)cancelSearch:(id)sender {
    [pocketsphinxController stopListening];
}

/**
 * handle action for redo button.
 * @param sender the button.
 */
- (IBAction)redoSearch:(id)sender {
    [self.lblSubTitle setTextColor:[UIColor blackColor]];
    self.lblSubTitle.text = @"Initializing...";
    self.btnSearchAgain.hidden = YES;
    self.btnDone.hidden = YES;
    self.btnCancel.hidden = NO;
    self.resultView.hidden = YES;
    self.resultsLabel.hidden = YES;
    self.noResultsMessageLabel.hidden = YES;
    self.topDivider.hidden = YES;
    // Retrieve language model paths
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    SpeechRecognitionServiceImpl *srService = appDelegate.speechRecognitionService;
    NSError *error;
    NSDictionary *dict = [srService getFoodProductLanguageModelPaths:&error];
    if ([Helper displayError:error]) return;
    // start listening for speech
    [pocketsphinxController startListeningWithLanguageModelAtPath:[dict valueForKey:@"LMPath"]
                                                 dictionaryAtPath:[dict valueForKey:@"DictionaryPath"]
                                              languageModelIsJSGF:FALSE];
}

/**
 * handle action for analyze.
 * @param sender the button.
 */
- (IBAction)Analyze:(id)sender {
    [pocketsphinxController stopListening];
    [self.btnSpeak setEnabled:NO];
    self.lblSubTitle.text = @"Analyzing...";
    [self performSelector:@selector(showResult) withObject:nil afterDelay:2];
}

/**
 * This method will be called when N-Best Hypothesis have been produced.
 * @param hypothesisArray the hypothesis array.
 */
- (void)pocketsphinxDidReceiveNBestHypothesisArray:(NSArray *)hypothesisArray {
    self.lblSubTitle.text = @"Analyzing...";
    // Retrieve language model paths
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    FoodProductServiceImpl *foodProductService = appDelegate.foodProductService;
    NSError *error;
    
    [self.searchResult removeAllObjects];
    NSMutableSet *recognizedSet = [NSMutableSet set];
    for (id hypothesis in hypothesisArray) {
        NSString *hypo = nil;
        if ([hypothesis isKindOfClass:[NSDictionary class]]) {
            hypo = hypothesis[@"Hypothesis"];
        }
        else {
            hypo = hypothesis;
        }
        hypo = [hypo capitalizedString];
        NSLog(@"Recognized:%@", hypo);
        if ([recognizedSet containsObject:hypo]) {
            continue;
        }
        FoodProduct *foodProduct = [foodProductService getFoodProductByName:appDelegate.loggedInUser
                                                                       name:hypo
                                                                      error:&error];
        if (foodProduct) {
            [recognizedSet addObject:hypo];
            [self.searchResult addObject:foodProduct];
        }
    }
    [self showResult];
    
    // Stop listening
    [pocketsphinxController performSelector:@selector(stopListening) withObject:nil afterDelay:0.1];
}

// An optional delegate method of OpenEarsEventsObserver which informs that Pocketsphinx is now listening for speech.
- (void) pocketsphinxDidStartListening {
    [self.lblSubTitle setTextColor:[UIColor redColor]];
    self.lblSubTitle.text = @"Speak Now";
}
@end
