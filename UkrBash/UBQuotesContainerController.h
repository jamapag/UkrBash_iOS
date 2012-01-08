//
//  UBQuotesContainerController.h
//  UkrBash
//
//  Created by Maks Markovets on 21.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UBQuotesContainerController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSArray *currentQuotes;
    UITableView *publishedQuotesTableView;
    UIButton *logoButton;
    UILabel *categoryLabel;
    
    BOOL loading;
}

- (void)showFooter;
- (void)hideFooter;

@end
