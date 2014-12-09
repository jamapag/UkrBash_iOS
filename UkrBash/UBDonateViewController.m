//
//  UBDonateViewController.m
//  UkrBash
//
//  Created by Michail Grebionkin on 21.01.13.
//
//

#import "UBDonateViewController.h"
#import "UBDonateCell.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import <QuartzCore/QuartzCore.h>

#define UKRBASH_DONATE_SCHEME_1 @"com.lidarudyuk.UkrBash.donate1"
#define UKRBASH_DONATE_SCHEME_2 @"com.lidarudyuk.UkrBash.donate2"

#define UBDonateViewDescriptionOption_Text @"Допомогти проекту дуже просто. Якщо ви помітили помилку у роботі застосунку, або маєте ідеї чи пропозиції з його покращення, напишіть нам листа. Ви дуже допоможете, якщо розповісте про цей затосунок своїм друзям або просто залишите оцінку і відгук у AppStore. Або ви можете перерахувати кошти на розробку застосунку."

NS_ENUM(NSInteger, _UBDonateViewOptions)
{
    UBDonateViewDescriptionOption,
    UBDonateViewRatingOption,
    UBDonateViewShareOption,
    UBDonateViewMailOption,
    UBDonateViewOptionsCount
};

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

    float y = 20;

    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0., y, 50., self.view.frame.size.height + 20)];
    borderView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"border.png"]];
    [self.view addSubview:borderView];
    
    UIView *headerView = [[self headerViewWithMenuButtonAction:@selector(menuAction:)] retain];
    
    [self.view addSubview:headerView];
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0., headerView.frame.size.height + headerView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - headerView.frame.size.height - headerView.frame.origin.y)];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.rowHeight = 52.;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.translatesAutoresizingMaskIntoConstraints = NO;

    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"donate-cell"];
    
    // for starting loading automatically.
    [tableView setContentInset:UIEdgeInsetsMake(1., 0., 0., 0.)];
    
    [self.view addSubview:tableView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[borderView][tableView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(borderView, tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[headerView][tableView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headerView, tableView)]];
    [borderView release];
    
    activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    activityIndicatorView.tintColor = [UIColor whiteColor];
    [activityIndicatorView startAnimating];
    [headerView addSubview:activityIndicatorView];
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[activityIndicatorView]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(activityIndicatorView)]];
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[activityIndicatorView]-13-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(activityIndicatorView)]];
    [self hideActivityIndicator];
    
    [headerView release];
    
    messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(40., 20., tableView.frame.size.width - 50., 100.)];
    messageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.textColor = [UIColor darkGrayColor];
    messageLabel.shadowColor = [UIColor whiteColor];
    messageLabel.shadowOffset = CGSizeMake(0, 1.);
    messageLabel.numberOfLines = 0;

    
    if ([SKPaymentQueue canMakePayments]) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        if (!products) {
            [self loadProducts];
        }
    }
}

- (void)showActivityIndicator
{
    activityIndicatorView.hidden = NO;
}

- (void)hideActivityIndicator
{
    activityIndicatorView.hidden = YES;
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
    [self showActivityIndicator];
}


#pragma mark - SKRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
//    NSLog(@"prodcuts response: %@", response);
//    NSLog(@"\t%@", response.products);
//    NSLog(@"\t%@", response.invalidProductIdentifiers);
    for (SKProduct *product in response.products) {
        [products addObject:product];
    }
    [tableView reloadData];
    [self hideActivityIndicator];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    [self hideActivityIndicator];
}

#pragma mark - Table View Datasource/Delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (processing) {
        return UBDonateViewOptionsCount;
    }
    return UBDonateViewOptionsCount + products.count;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"donate-cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    
    if (indexPath.row == UBDonateViewShareOption) {
        cell.textLabel.text = @"Розповісти друзям";
        cell.imageView.image = [UIImage imageNamed:@"share"];
    } else if (indexPath.row == UBDonateViewMailOption) {
        cell.textLabel.text = @"Написати розробникам";
        cell.imageView.image = [UIImage imageNamed:@"mail"];
    } else if (indexPath.row == UBDonateViewRatingOption) {
        cell.textLabel.text = @"Оцінити застосунок";
        cell.imageView.image = [UIImage imageNamed:@"favorite"];
    } else if (indexPath.row == UBDonateViewDescriptionOption) {
        cell.textLabel.text = UBDonateViewDescriptionOption_Text;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.shadowColor = [UIColor whiteColor];
        cell.textLabel.shadowOffset = CGSizeMake(0, 1.);
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    } else if (indexPath.row >= UBDonateViewOptionsCount) {
        NSInteger row = indexPath.row - UBDonateViewOptionsCount;
        SKProduct *product = [products objectAtIndex:row];
        cell.textLabel.text = [NSString stringWithFormat:@"Профінансувати %@", [[self numberFormatterForLocale:product.priceLocale] stringFromNumber:product.price]];
        cell.imageView.image = [UIImage imageNamed:@"money"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *appURL = [NSURL URLWithString:@"https://itunes.apple.com/ua/app/ukrbash/id517226573?mt=8"];
    if (indexPath.row == UBDonateViewShareOption) {
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[appURL] applicationActivities:nil];
        activityViewController.completionHandler = ^(NSString *activityType, BOOL completed) {
            if (completed) {
                [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"sharing"
                                                                                                    action:@"app"
                                                                                                     label:@"url"
                                                                                                     value:@(-1)] build]];
            }
        };
        if (IS_IOS8_AND_LATER) {
            UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
            activityViewController.popoverPresentationController.sourceView = cell;
        }
        [self presentViewController:activityViewController animated:YES completion:nil];
    } else if (indexPath.row == UBDonateViewMailOption) {
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
            mailComposer.mailComposeDelegate = self;
            [mailComposer setToRecipients:[NSArray arrayWithObject:@"info@smile2mobile.net"]];
            [mailComposer setSubject:@"UkrBash iOS feedback"];
            [self presentViewController:mailComposer animated:YES completion:nil];
        } else {
            NSURL *url = [NSURL URLWithString:@"mailto:info@smile2mobile.net?subject=UkrBash%20iOS%20feedback"];
            [[UIApplication sharedApplication] openURL:url];
        }
    } else if (indexPath.row == UBDonateViewRatingOption) {
        if ([SKStoreProductViewController class]) {
            SKStoreProductViewController *controller = [[SKStoreProductViewController alloc] init];
            controller.delegate = self;
            [controller loadProductWithParameters:@{ SKStoreProductParameterITunesItemIdentifier:@"517226573" }
                                  completionBlock:NULL];
            [self presentViewController:controller animated:YES completion:nil];
            [controller release];
            return;
        } else {
            [[UIApplication sharedApplication] openURL:appURL];
        }
    } else if (indexPath.row == UBDonateViewDescriptionOption) {
        // nothing to do
    } else if (indexPath.row >= UBDonateViewOptionsCount) {
        NSAssert(products != nil, @"no products to purchase!");
        NSAssert(products.count != 0, @"no products to purchase!");
        
        NSInteger row = indexPath.row - UBDonateViewOptionsCount;
        SKPayment *payment = [SKPayment paymentWithProduct:[products objectAtIndex:row]];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
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
    details.textAlignment = NSTextAlignmentCenter;
    [footerView addSubview:details];
    [details release];

    return [footerView autorelease];
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == UBDonateViewDescriptionOption) {
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]};
        NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
        [context setMinimumScaleFactor:1];
        CGSize constraint = CGSizeMake(tableView.frame.size.width - 70, MAXFLOAT);
        CGRect rect = [UBDonateViewDescriptionOption_Text boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:context];
        return ceilf(rect.size.height);
    }
    return 44.;
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
                [self hideActivityIndicator];
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
                [self hideActivityIndicator];
                [tableView reloadData];
            }
                break;
            case SKPaymentTransactionStatePurchasing:
            {
                processing = YES;
                [tableView reloadData];
                [self showActivityIndicator];
            }
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (!error && result == MFMailComposeResultSent) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Дякуєм!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
}

#pragma mark - SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
