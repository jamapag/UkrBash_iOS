//
//  UBQuotesContainerController.h
//  UkrBash
//
//  Created by Maks Markovets on 21.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UBViewController.h"
#import "UBUnpablishedQuotesDataSource.h"

@interface UBQuotesContainerController : UBViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSArray *currentQuotes;
    UITableView *publishedQuotesTableView;
    UIButton *logoButton;
    UILabel *categoryLabel;
    NSIndexPath *activeCell;
    NSDateFormatter *dateFormatter;
    
    id <UBQuotesDataSource> dataSource;
    
    BOOL loading;
}

@property (nonatomic, retain) id <UBQuotesDataSource> dataSource;

- (id)initWithDataSourceClass:(Class)dataSourceClass;
- (void)showFooter;
- (void)hideFooter;

@end
