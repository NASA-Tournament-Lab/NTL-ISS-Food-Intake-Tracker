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
//  CustomTableViewController.m
//  FoodIntakeTracker
//
//  Created by subchap 08/19/2013
//

#import "CustomTableViewController.h"

/**
 * @class BaseCustomTableView
 * base custom table view. Could be extend to specify view and table data.
 *
 * @author subchap
 * @version 1.0
 */

@implementation BaseCustomTableView

@end

/**
 * @class SuggestionTableView
 * A table view that shows auto-suggestions
 *
 * @author subchap
 * @version 1.0
 */
@implementation SuggestionTableView

/**
 * load default values.
 */
-(void)viewDidLoad{
    [super viewDidLoad];
    self.suggestions = [NSArray array];
}

#pragma mark - UITableView Delegate Methods
/**
 * returns the row number of table in the section.
 * @param tableView the table requesting the row number.
 * @param section the section of the table.
 * @return the number of fooditems.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.suggestions.count;
}

/**
 * tells the table what the cell will be like. Update cell content here.
 * @param tableView the table view the cell in.
 * @param indexPath the position the cell in the table.
 * @return an updated cell.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *autoSuggestionTableCellIdentifier = @"AutoSuggestionTableCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:autoSuggestionTableCellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:autoSuggestionTableCellIdentifier];
    }
    
    cell.textLabel.text = self.suggestions[indexPath.row];
    return cell;
}

/**
 * action for row selected.
 * @param tableView the table informing the delegate about the new row selection.
 * @param indexPath the index path of the selected row.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.delegate && [self.delegate respondsToSelector:@selector(tableView:didSelectValue:)]){
        [self.delegate tableView:self didSelectValue:self.suggestions[indexPath.row]];
    }
    [self.popController dismissPopoverAnimated:YES];
}
@end

