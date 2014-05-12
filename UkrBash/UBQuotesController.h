//
//  UBQuotesController.h
//  UkrBash
//
//  Created by Maks Markovets on 28.04.14.
//
//

#import "UBViewController.h"
#import "UBTableViewDataSource.h"
#import "UBFetchedQuotesDataSource.h"
#import "EGORefreshTableHeaderView.h"
#import "UBQuoteCell.h"

@interface UBQuotesController : UBViewController <UITableViewDataSource, UITableViewDelegate, UBQuoteCellDelegate>
{
    UITableView *tableView;
    NSIndexPath *activeCell;
    NSIndexPath *selectedIndexPath;
    
    UBFetchedQuotesDataSource *dataSource;
    EGORefreshTableHeaderView *refreshHeaderView;
}

@property (nonatomic, retain) UBFetchedQuotesDataSource *dataSource;

- (id)initWithDataSourceClass:(Class)dataSourceClass;

@end
