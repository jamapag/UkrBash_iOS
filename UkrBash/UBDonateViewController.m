//
//  UBDonateViewController.m
//  UkrBash
//
//  Created by Michail Grebionkin on 21.01.13.
//
//

#import "UBDonateViewController.h"
#import "UBDonateCell.h"
#import <QuartzCore/QuartzCore.h>

#define UKRBASH_DONATE_SCHEME_1 @"com.lidarudyuk.UkrBash.donate1"
#define UKRBASH_DONATE_SCHEME_2 @"com.lidarudyuk.UkrBash.donate2"

@interface UBDonateViewController ()

@end

@implementation UBDonateViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    if (products) {
        [products release];
    }
    [activityIndicatorView release];
    [messageLabel release];
    [super dealloc];
}

- (void)loadView
{
    [super loadView];
    
    self.title = @"Підтримати розробку";
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"texture.png"]];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        UIImage *borderImage = [UIImage imageNamed:@"border"];
        UIImageView *borderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0., -20., borderImage.size.width, self.view.frame.size.height)];
        borderImageView.image = borderImage;
        borderImageView.contentMode = UIViewContentModeTopLeft;
        [self.view addSubview:borderImageView];
        [borderImageView release];
    }
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0., 45., self.view.frame.size.width, self.view.frame.size.height - 45.)];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.rowHeight = 52.;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    
    // for starting loading automatically.
    [tableView setContentInset:UIEdgeInsetsMake(1., 0., 0., 0.)];
    
    [self.view addSubview:tableView];
    
    UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0., 0., self.view.frame.size.width, 44.)];
    headerView.userInteractionEnabled = YES;
    headerView.image = [UIImage imageNamed:@"header"];
    headerView.contentMode = UIViewContentModeTopLeft;
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    headerView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:CGRectMake(0., 0., headerView.image.size.width, headerView.image.size.height)] CGPath];
    headerView.layer.shadowColor = [[UIColor blackColor] CGColor];
    headerView.layer.shadowRadius = 2.;
    headerView.layer.shadowOffset = CGSizeMake(0, 2.);
    headerView.layer.shadowOpacity = .3;
    
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    menuButton.autoresizingMask = UIViewAutoresizingNone;
    [menuButton setBackgroundImage:[UIImage imageNamed:@"menu-button"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
    [menuButton setFrame:CGRectMake(15., 2., 36., 36.)];
    [headerView addSubview:menuButton];
    
    CGFloat x = menuButton.frame.origin.x + menuButton.frame.size.width + 5.;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, menuButton.frame.origin.y, headerView.frame.size.width - x * 2, menuButton.frame.size.height)];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:21.];
    titleLabel.textColor = [UIColor darkGrayColor];
    titleLabel.shadowColor = [UIColor whiteColor];
    titleLabel.shadowOffset = CGSizeMake(0, 1.);
    titleLabel.text = self.title;
    [headerView addSubview:titleLabel];
    [titleLabel release];
    
    [self.view addSubview:headerView];
    [headerView release];
    
    activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [activityIndicatorView startAnimating];
    
    messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(40., 20., tableView.frame.size.width - 50., 100.)];
    messageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.textAlignment = UITextAlignmentCenter;
    messageLabel.textColor = [UIColor darkGrayColor];
    messageLabel.shadowColor = [UIColor whiteColor];
    messageLabel.shadowOffset = CGSizeMake(0, 1.);
    messageLabel.numberOfLines = 0;

    
    if (![SKPaymentQueue canMakePayments]) {
        messageLabel.text = @"Ця функція тимчасово не працює. Це пов`язано з налаштуваннями вашого акаунту в iTunes Store.";
        [tableView addSubview:messageLabel];
    }
    else {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        if (!products) {
            [self loadProducts];
        }
    }
}

- (NSNumberFormatter *)numberFormatterForLocale:(NSLocale *)locale
{
    if (!numberFormatter) {
        numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setLocale:locale];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    }
    return numberFormatter;
}

- (void)loadProducts
{
    if (!products) {
        products = [[NSMutableArray alloc] init];
    }
    else {
        [products removeAllObjects];
        [tableView reloadData];
    }
    
    SKProductsRequest * request = [[SKProductsRequest alloc] initWithProductIdentifiers:
                                   [NSSet setWithObjects:UKRBASH_DONATE_SCHEME_1, UKRBASH_DONATE_SCHEME_2, nil]];
    request.delegate = self;
    [request start];
    [request release];
    
    activityIndicatorView.center = CGPointMake(self.view.frame.size.width / 2.,  30.);
    [tableView addSubview:activityIndicatorView];
}

#pragma mark - Actions

- (void)menuAction:(id)sender
{
    [self.ubNavigationController popViewControllerAnimated:YES];
}

#pragma mark - SKRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"prodcuts response: %@", response);
    NSLog(@"\t%@", response.products);
    NSLog(@"\t%@", response.invalidProductIdentifiers);
    for (SKProduct *product in response.products) {
        [products addObject:product];
    }
    [tableView reloadData];
    [activityIndicatorView removeFromSuperview];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    [activityIndicatorView removeFromSuperview];
    messageLabel.text = @"Трапилась помилка. Будьласка, спробуйте пізніше.";
    [tableView addSubview:messageLabel];
}

#pragma mark - Table View Datasource/Delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (processing) {
        return 0;
    }
    return products.count;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UBDonateCell *cell = (UBDonateCell*)[tableView dequeueReusableCellWithIdentifier:@"donate-cell"];
    if (cell == nil) {
        cell = [[[UBDonateCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"donate-cell"] autorelease];
    }
    
    SKProduct *product = [products objectAtIndex:indexPath.row];
    cell.titleLabel.text = product.localizedTitle;
    cell.valueLabel.text = [[self numberFormatterForLocale:product.priceLocale] stringFromNumber:product.price];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(products != nil, @"no products to purchase!");
    NSAssert(products.count != 0, @"no products to purchase!");
    
    SKPayment *payment = [SKPayment paymentWithProduct:[products objectAtIndex:indexPath.row]];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return nil;
}

- (UIView *)tableView:(UITableView *)_tableView viewForFooterInSection:(NSInteger)section
{
    if (products.count == 0) {
        return [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    }
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0., 0., _tableView.frame.size.width, 100.)];
    footerView.backgroundColor = [UIColor clearColor];
    
    UILabel *details = [[UILabel alloc] initWithFrame:CGRectMake(55., 0., footerView.frame.size.width - 65., footerView.frame.size.height)];
    details.text = @"Якщо ви бажаєте підтримати розробку цього додатку, ви можете зробити внесок.";
    details.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    details.textColor = [UIColor darkGrayColor];
    details.shadowColor = [UIColor whiteColor];
    details.shadowOffset = CGSizeMake(0., 1.);
    details.backgroundColor = [UIColor clearColor];
    details.numberOfLines = 0;
    [footerView addSubview:details];
    [details release];

    return [footerView autorelease];
}

#pragma mark - Payment queue observer

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStateFailed:
            {
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                if (transaction.error.code != SKErrorPaymentCancelled) {
                    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Помилка" message:@"Трапилась помилка. Будьласка, спробуйте ще раз." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [errorAlert show];
                    [errorAlert release];
                }
                
                processing = NO;
                [activityIndicatorView removeFromSuperview];
                [tableView reloadData];
            }
                break;
            case SKPaymentTransactionStatePurchased:
            {
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                
                UIAlertView *thankYouAlert = [[UIAlertView alloc] initWithTitle:@"Готово!" message:@"Красно дякуємо за підтримку!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [thankYouAlert show];
                [thankYouAlert release];
                
                processing = NO;
                [activityIndicatorView removeFromSuperview];
                [tableView reloadData];
            }
                break;
            case SKPaymentTransactionStatePurchasing:
            {
                processing = YES;
                [tableView reloadData];
                [tableView addSubview:activityIndicatorView];
            }
                break;
                
            default:
                break;
        }
    }
}

@end