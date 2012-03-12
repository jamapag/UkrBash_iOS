//
//  UBQuotesContainerController.h
//  UkrBash
//
//  Created by Maks Markovets on 21.12.11.
//  Copyright (c) 2011 smile2mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "UBViewController.h"
#import "UBQuoteCell.h"
#import "UBTableViewDataSource.h"

@interface UBQuotesContainerController : UBViewController <UITableViewDelegate, UITableViewDataSource, UBQuoteCellDelegate, MFMailComposeViewControllerDelegate>
{
    UITableView *tableView;
    UIButton *logoButton;
    UILabel *categoryLabel;
    NSIndexPath *activeCell;
    
    UBTableViewDataSource *dataSource;
    
    BOOL loading;
}

@property (nonatomic, retain) UBTableViewDataSource *dataSource;

- (id)initWithDataSourceClass:(Class)dataSourceClass;
- (void)showFooter;
- (void)hideFooter;

@end
