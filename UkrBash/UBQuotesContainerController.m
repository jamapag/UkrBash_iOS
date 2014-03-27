//
//  UBQuotesContainerController.m
//  UkrBash
//
//  Created by Maks Markovets on 21.12.11.
//  Copyright (c) 2011 smile2mobile. All rights reserved.
//

#import "UBQuotesContainerController.h"
#import "Model.h"
#import "UBQuote.h"
#import "UBQuoteCell.h"
#import "UBNavigationController.h"
#import "SharingController.h"
#import "UkrBashAppDelegate.h"
#import "EMailSharingController.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "EGOUkrBashActivityIndicator.h"
#import "Reachability.h"

@implementation UBQuotesContainerController

@synthesize dataSource;

- (id)initWithDataSourceClass:(Class)dataSourceClass
{
    self = [super init];
    if (self) {
        dataSource = [[dataSourceClass alloc] init];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [dataSource release];
    if (activeCell) {
        [activeCell release];
    }
    if (selectedIndexPath) {
        [selectedIndexPath release];
    }
    [tableView release];
    [_refreshHeaderView release];
    [super dealloc];
}

#pragma mark - actions

- (void)menuAction:(id)sender
{
    [self.ubNavigationController popViewControllerAnimated:YES];
}

- (void)showCopyMenu:(UILongPressGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        UBQuoteCell *cell = (UBQuoteCell*)gesture.view;
        [selectedIndexPath release], selectedIndexPath = nil;
        selectedIndexPath = [[tableView indexPathForCell:cell] retain];
        if ([selectedIndexPath isEqual:activeCell]) {
            return;
        }
        [cell setSelected:YES animated:NO];
        
        [self becomeFirstResponder];
        CGPoint location = [gesture locationInView:gesture.view];
        UIMenuItem *copy = [[[UIMenuItem alloc] initWithTitle:@"Копіювати" action:@selector(copyQuote:)] autorelease];
        UIMenuItem *copyURLItem = [[[UIMenuItem alloc] initWithTitle:@"Копіювати URL" action:@selector(copyURL:)] autorelease];
        
        UIMenuController *sharedMenu = [UIMenuController sharedMenuController];
        [sharedMenu setMenuItems:[NSArray arrayWithObjects:copy, copyURLItem, nil]];
        [sharedMenu setTargetRect:CGRectMake(location.x, location.y, 0., 0.) inView:gesture.view];
        [sharedMenu setMenuVisible:YES animated:YES];
    }
}

- (void)copyQuote:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    UBQuote *quote = [[dataSource items] objectAtIndex:selectedIndexPath.row];
    pasteboard.string = [quote text];

    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"copying"
                                                                                        action:@"quotes"
                                                                                         label:@"quote"
                                                                                         value:@(-1)] build]];
}

- (void)copyURL:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    UBQuote *quote = [[dataSource items] objectAtIndex:selectedIndexPath.row];
    NSString *quoteUrl = [NSString stringWithFormat:@"http://ukrbash.org/quote/%ld", (long)quote.quoteId];
    pasteboard.string = quoteUrl;

    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"sharing"
                                                                                        action:@"quotes"
                                                                                         label:@"url"
                                                                                         value:@(-1)] build]];
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"texture.png"]];
    
    float y = 0;
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // Load resources for iOS 6.1 or earlier;
        y = 0;
    } else {
        // Load resources for iOS 7 or later
        y = 20;
    }
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0., y, 50., self.view.frame.size.height + 20)];
    borderView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"border.png"]];
    [self.view addSubview:borderView];
    [borderView release];

    UIView *headerView = [[self headerViewWithMenuButtonAction:@selector(menuAction:)] retain];
    
    [self.view addSubview:headerView];

    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0., headerView.frame.size.height + headerView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - headerView.frame.size.height - headerView.frame.origin.y)];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // for starting loading automatically.
    [tableView setContentInset:UIEdgeInsetsMake(1., 0., 0., 0.)];
    
    [self.view addSubview:tableView];
    
    
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - tableView.bounds.size.height, self.view.frame.size.width, tableView.bounds.size.height)];
    _refreshHeaderView.delegate = self;
    [tableView addSubview:_refreshHeaderView];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(publishedQuotesUpdated:)
                                                 name:kNotificationDataUpdated
                                               object:nil];
    
    [headerView release];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    if (activeCell) {
        [activeCell release], activeCell = nil;
    }
    [tableView release], tableView = nil;
    [_refreshHeaderView release], _refreshHeaderView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    if (IS_IOS7) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resize:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    if (IS_IOS7) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)reachabilityChanged:(NSNotification *)notification
{
    Reachability *reach = notification.object;
    if ([reach isReachable]) {
        [self loadNewItems];
    }
    else {
        loading = NO;
    }
}

- (void)resize:(NSNotification *)notification
{
    [tableView reloadData];
}

- (void)publishedQuotesUpdated:(NSNotificationCenter *)notification
{
    [tableView reloadData];
    loading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:tableView];
    [self hideFooter];
}

- (void)loadMoreQuotes
{
    [self showFooter];
    loading = YES;
    [dataSource loadMoreItems];
}

- (void)loadNewItems
{
    loading = YES;
    [dataSource loadNewItems];
}

- (void)showFooter
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    EGOUkrBashActivityIndicator *activityIndicator = [[EGOUkrBashActivityIndicator alloc] init];
    activityIndicator.center = footerView.center;
    activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    [activityIndicator startAnimating];
    [footerView addSubview:activityIndicator];
    
    tableView.tableFooterView = footerView;
    [footerView release];
    [activityIndicator release];
}

- (void)hideFooter
{
    tableView.tableFooterView = nil;
}

#pragma mark - UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView 
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[dataSource items] count];
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UBQuoteCell *cell = (UBQuoteCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = (UBQuoteCell *)[dataSource cellWithReuesIdentifier:cellIdentifier];

        cell.shareDelegate = self;
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showCopyMenu:)];
        [cell addGestureRecognizer:longPress];
        [longPress release];
    }
    
    cell.quoteTextLabel.font = GET_FONT();
    [dataSource configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UBQuoteCell *cell = (UBQuoteCell*)[_tableView cellForRowAtIndexPath:indexPath];
    if (cell.shareButtonsVisible) {
        [activeCell release], activeCell = nil;
        [cell hideShareButtons];
    } else {
        if (![[UIMenuController sharedMenuController] isMenuVisible]) {
            UBQuoteCell *ac = (UBQuoteCell*)[_tableView cellForRowAtIndexPath:activeCell];
            [ac hideShareButtons];
            
            [activeCell release], activeCell = nil;
            activeCell = [indexPath retain];
            [cell showShareButtons];
        }
    }
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UBQuote *quote = [[dataSource items] objectAtIndex:indexPath.row];
    return [UBQuoteCell heightForQuoteText:quote.text viewWidth:tableView.frame.size.width];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:aScrollView];
    
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    if (h == 0 && [[dataSource items] count] > 0) {
        return;
    }
    
    float reload_distance = 10;
    if(y > h + reload_distance) {
        if (!loading) {
            NSLog(@"load more rows");
            [self loadMoreQuotes];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark -

- (void)quoteCell:(UBQuoteCell *)cell shareQuoteWithType:(SharingNetworkType)networkType
{
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    UBQuote *quote = [[dataSource items] objectAtIndex:indexPath.row];
    NSString *quoteUrl = [NSString stringWithFormat:@"http://ukrbash.org/quote/%ld", (long)quote.quoteId];
    
    SharingController * sharingController = [SharingController sharingControllerForNetworkType:networkType];
    sharingController.url = quoteUrl;
    sharingController.message = (networkType == SharingEMailNetwork) ? quote.text : nil;
    sharingController.rootViewController = self;
    [sharingController setAttachmentTitle:[NSString stringWithFormat:@"Цитата %ld", (long)quote.quoteId]];
    [sharingController setAttachmentDescription:quote.text];
    [sharingController showSharingDialog];

    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"sharing"
                                                                                        action:@"quotes"
                                                                                         label:NSStringFromClass([sharingController class])
                                                                                         value:@(-1)] build]];
}

#pragma mark - EGORefreshTableHeaderDelegate methods.
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [self loadNewItems];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return loading;
}

@end
