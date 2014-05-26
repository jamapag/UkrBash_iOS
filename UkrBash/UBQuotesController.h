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
#import "UBEmptyListView.h"

@interface UBQuotesController : UBViewController <UITableViewDataSource, UITableViewDelegate, UBQuoteCellDelegate, UIActivityItemSource>
{
    UITableView *tableView;
    NSIndexPath *activeCell;
    NSIndexPath *selectedIndexPath;
    UBEmptyListView *emptyView;
    
    UBFetchedQuotesDataSource *dataSource;
    EGORefreshTableHeaderView *refreshHeaderView;
}

@property (nonatomic, retain) UBFetchedQuotesDataSource *dataSource;

- (id)initWithDataSourceClass:(Class)dataSourceClass;

@end
