//
//  UBDonateViewController.h
//  UkrBash
//
//  Created by Michail Grebionkin on 21.01.13.
//
//

#import <StoreKit/StoreKit.h>
#import "UBCenterViewController.h"

@interface UBDonateViewController : UBCenterViewController
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
