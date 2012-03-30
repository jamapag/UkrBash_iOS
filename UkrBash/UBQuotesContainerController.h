//
//  UBQuotesContainerController.h
//  UkrBash
//
//  Created by Maks Markovets on 21.12.11.
//  Copyright (c) 2011 smile2mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UBViewController.h"
#import "UBQuoteCell.h"
#import "UBTableViewDataSource.h"
#import "EGORefreshTableHeaderView.h"

@interface UBQuotesContainerController : UBViewController <UITableViewDelegate, UITableViewDataSource, UBQuoteCellDelegate, EGORefreshTableHeaderDelegate>
{
    UITableView *tableView;
    UIButton *logoButton;
    UILabel *categoryLabel;
    NSIndexPath *activeCell;
    
    UBTableViewDataSource *dataSource;
    EGORefreshTableHeaderView *_refreshHeaderView;
    
    BOOL loading;
}

@property (nonatomic, retain) UBTableViewDataSource *dataSource;

- (id)initWithDataSourceClass:(Class)dataSourceClass;
- (void)showFooter;
- (void)hideFooter;

@end
