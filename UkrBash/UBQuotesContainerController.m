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
#import "UBFavoriteQuotesDataSource.h"
#import "UBVkontakteActivity.h"

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
        UIMenuItem *openInBrowser = [[[UIMenuItem alloc] initWithTitle:@"Відкрити в Safari" action:@selector(openInBrowser:)] autorelease];
        
        UIMenuController *sharedMenu = [UIMenuController sharedMenuController];
        [sharedMenu setMenuItems:[NSArray arrayWithObjects:copy, copyURLItem, openInBrowser, nil]];
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

- (void)openInBrowser:(id)sender
{
    UBQuote *quote = [[dataSource items] objectAtIndex:selectedIndexPath.row];
    NSString *quoteUrl = [NSString stringWithFormat:@"http://ukrbash.org/quote/%ld", (long)quote.quoteId];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:quoteUrl]];
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];

    UIView *headerView = [[self headerViewWithMenuButtonAction:@selector(menuAction:)] retain];
    
    [self.view addSubview:headerView];

    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0., headerView.frame.size.height + headerView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - headerView.frame.size.height - headerView.frame.origin.y)];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // for starting loading automatically.
//    [tableView setContentInset:UIEdgeInsetsMake(1., 0., 0., 0.)];
    
    if ([dataSource isKindOfClass:[UBFavoriteQuotesDataSource class]]) {
        [(UBFavoriteQuotesDataSource *)dataSource setTableView:tableView];
    }
    
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resize:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    if ([[dataSource items] count] == 0) {
        [self loadNewItems];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
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
        if (!loading) {
            [self loadNewItems];
        }
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
    [tableView reloadData];
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
    if(y > h + reload_distance && size.height > bounds.size.height) { // Added checking (size.height > bounds.size.height) TODO: need to add to other controllers.
        if (!loading) {
            NSLog(@"load more rows");
            [self loadMoreQuotes];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - UBQuoteCellDelegate methods.

- (void)shareActionForCell:(id)cell andRectForPopover:(CGRect)rect
{
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    UBQuote *quote = [dataSource objectAtIndexPath:indexPath];
    NSURL *quoteUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://ukrbash.org/quote/%ld", (long)quote.quoteId]];
    
    UBVkontakteActivity *vkActivity = [[UBVkontakteActivity alloc] init];
    vkActivity.parentViewController = self;
    vkActivity.attachmentTitle = [NSString stringWithFormat:@"Цитата %ld", (long)quote.quoteId];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self, quoteUrl] applicationActivities:@[vkActivity]];
    [activityViewController setValue:[NSString stringWithFormat:@"Цитата %ld", (long)quote.quoteId] forKey:@"subject"];
    activityViewController.excludedActivityTypes = @[UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact];
    [vkActivity release];
    [activityViewController setCompletionHandler:^(NSString *activityType, BOOL completed) {
        [self.ubNavigationController setNeedsStatusBarAppearanceUpdate];
    }];
    if (IS_IOS8_AND_LATER) {
        activityViewController.popoverPresentationController.sourceView = cell;
        activityViewController.popoverPresentationController.sourceRect = rect;
    }
    [self presentViewController:activityViewController animated:YES completion:nil];
    [activityViewController release];

}


- (void)favoriteActionForCell:(UBQuoteCell *)cell
{
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    UBQuote *quote = [[dataSource items] objectAtIndex:indexPath.row];
    
    NSManagedObjectContext *context = [(UkrBashAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Quote" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"quoteId == %@", [NSNumber numberWithInteger:quote.quoteId]];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    Quote *cdQuote = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if ([fetchedObjects count] > 0) {
        cdQuote = [fetchedObjects objectAtIndex:0];
    }
    [fetchRequest release];
    
    if (!cdQuote) {
        cdQuote = [NSEntityDescription insertNewObjectForEntityForName:@"Quote" inManagedObjectContext:context];
        cdQuote.quoteId = [NSNumber numberWithInteger:quote.quoteId];
        cdQuote.status = [NSNumber numberWithInteger:quote.status];
        cdQuote.type = quote.type;
        cdQuote.addDate = quote.addDate;
        cdQuote.pubDate = quote.pubDate;
        cdQuote.author = quote.author;
        cdQuote.authorId = [NSNumber numberWithInteger:quote.authorId];
        cdQuote.text = quote.text;
        cdQuote.rating = [NSNumber numberWithInteger:quote.rating];
    } else {
        // update some fields:
        cdQuote.status = [NSNumber numberWithInteger:quote.status];
        cdQuote.pubDate = quote.pubDate;
        cdQuote.rating = [NSNumber numberWithInteger:quote.rating];
    }
    
    if (!quote.favorite) {
        cdQuote.favorite = [NSNumber numberWithBool:YES];
        quote.favorite = YES;
    } else {
        cdQuote.favorite = [NSNumber numberWithBool:NO];
        quote.favorite = NO;
    }
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    } else {
        if (quote.favorite) {
            [cell.favoriteButton setImage:[UIImage imageNamed:@"favorite_active"] forState:UIControlStateNormal];
        } else {
            [cell.favoriteButton setImage:[UIImage imageNamed:@"favorite"] forState:UIControlStateNormal];
        }
    }
}

#pragma mark - UIActivityItemSource Methods.

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    UBQuote *quote = [dataSource objectAtIndexPath:activeCell];
    NSString *shareText = quote.text;
    if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
        if ([shareText length] > 109) {
            shareText = [shareText substringToIndex:108];
        }
    }
    return shareText;
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return nil;
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
