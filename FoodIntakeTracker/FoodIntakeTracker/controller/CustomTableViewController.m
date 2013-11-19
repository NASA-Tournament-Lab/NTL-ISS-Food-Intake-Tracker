//
//  CustomTableViewController.m
//  FoodIntakeTracker
//
//  Created by subchap 08/19/2013
//  Copyright (c) 2013 Topcoder. All rights reserved.
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

