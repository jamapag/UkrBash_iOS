//
//  UBDonateViewController.h
//  UkrBash
//
//  Created by Michail Grebionkin on 21.01.13.
//
//

#import "UBViewController.h"
#import <StoreKit/StoreKit.h>

@interface UBDonateViewController : UBViewController
<
    UITableViewDelegate,
    UITableViewDataSource,
    SKProductsRequestDelegate,
    SKPaymentTransactionObserver
>
{
    UITableView * tableView;
    NSMutableArray * products;
    NSNumberFormatter * numberFormatter;
    UIActivityIndicatorView * activityIndicatorView;
    UILabel * messageLabel;
    BOOL processing;
}
@end
