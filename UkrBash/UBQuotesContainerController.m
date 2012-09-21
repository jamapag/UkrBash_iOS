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
#import "FacebookSharer.h"
#import "UkrBashAppDelegate.h"
#import "ShareManager.h"
#import "EMailSharer.h"


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
    [activeCell release];
    [selectedIndexPath release];
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
}

- (void)copyURL:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    UBQuote *quote = [[dataSource items] objectAtIndex:selectedIndexPath.row];
    NSString *quoteUrl = [NSString stringWithFormat:@"http://ukrbash.org/quote/%d", quote.quoteId];
    pasteboard.string = quoteUrl;
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0., -20., self.view.frame.size.width, self.view.frame.size.height)];
    backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    backgroundImageView.image = [UIImage imageNamed:@"view-background"];
    backgroundImageView.contentMode = UIViewContentModeTopLeft;
    [self.view addSubview:backgroundImageView];
    [backgroundImageView release];
    
    UIImage *borderImage = [UIImage imageNamed:@"border"];
    UIImageView *borderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0., -20., borderImage.size.width, self.view.frame.size.height)];
    borderImageView.image = borderImage;
    borderImageView.contentMode = UIViewContentModeTopLeft;
    [self.view addSubview:borderImageView];
    [borderImageView release];
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0., 45., self.view.frame.size.width, self.view.frame.size.height - 45.)];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // for starting loading automatically.
    [tableView setContentInset:UIEdgeInsetsMake(1., 0., 0., 0.)];
    
    [self.view addSubview:tableView];
    
    
    if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - tableView.bounds.size.height, self.view.frame.size.width, tableView.bounds.size.height)];
		view.delegate = self;
		[tableView addSubview:view];
		_refreshHeaderView = view;
		[view release];		
	}

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(publishedQuotesUpdated:)
                                                 name:kNotificationDataUpdated
                                               object:nil];
    
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
    [activeCell release], activeCell = nil;
    [tableView release], tableView = nil;
    [_refreshHeaderView release], _refreshHeaderView = nil;
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
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
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
    // NSLog(@"offset: %f", offset.y);   
    // NSLog(@"content.height: %f", size.height);   
    // NSLog(@"bounds.height: %f", bounds.size.height);   
    // NSLog(@"inset.top: %f", inset.top);   
    // NSLog(@"inset.bottom: %f", inset.bottom);   
    // NSLog(@"pos: %f of %f", y, h);

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

- (void)quoteCell:(UBQuoteCell *)cell shareQuoteWithType:(UBQuoteShareType)shareType
{
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    UBQuote *quote = [[dataSource items] objectAtIndex:indexPath.row];
    NSString *quoteUrl = [NSString stringWithFormat:@"http://ukrbash.org/quote/%d", quote.quoteId];
    
    if (shareType == UBQuoteShareFacebookType) {
        FacebookSharer *fbSharer = [[ShareManager sharedInstance] createFacebookSharer];
        UkrBashAppDelegate *delegate = (UkrBashAppDelegate *) [[UIApplication sharedApplication] delegate];
        delegate.facebook = fbSharer.facebook;

        [fbSharer shareUrl:quoteUrl withMessage:nil];
    } else if (shareType == UBQuoteShareTwitterType) {
        TwitterSharer *twitterSharer = [[ShareManager sharedInstance] createTwitterSharerWithViewController:self];
        [twitterSharer shareUrl:quoteUrl withMessage:quote.text];
    } else if (shareType == UBQuoteShareEmailType) {
        EMailSharer *emailSharer = [[ShareManager sharedInstance] createEmailSharerWithViewController:self];
        [emailSharer shareUrl:quoteUrl withMessage:quote.text];
    }
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
