//
//  UBQuotesContainerController.h
//  UkrBash
//
//  Created by Maks Markovets on 21.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UBViewController.h"

@interface UBQuotesContainerController : UBViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSArray *currentQuotes;
    UITableView *publishedQuotesTableView;
    UIButton *logoButton;
    UILabel *categoryLabel;
    NSIndexPath *activeCell;
    
    BOOL loading;
}

- (void)showFooter;
- (void)hideFooter;

@end
