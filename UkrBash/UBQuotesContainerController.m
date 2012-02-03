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
#import "UBPicture.h"
#import "UBQuoteCell.h"
#import "UBNavigationController.h"
#import "UBPublishedPicturesDataSource.h"
#import <MessageUI/MessageUI.h>
#import <Twitter/Twitter.h>


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
    [publishedQuotesTableView release];
    [categoryLabel release];
    [logoButton release];
    [super dealloc];
}

#pragma mark - actions

- (void)scrollToTopAction:(id)sender
{
    [publishedQuotesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0. inSection:0.] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)menuAction:(id)sender
{
    [self.ubNavigationController popViewControllerAnimated:YES];
}

- (void)showCopyMenu:(UILongPressGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        UBQuoteCell *cell = (UBQuoteCell*)gesture.view;
        NSIndexPath *path = [publishedQuotesTableView indexPathForCell:cell];
        if ([path isEqual:activeCell]) {
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
    
}

- (void)copyURL:(id)sender
{
    
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    
//    [[Model sharedModel] loadPublishedQuotes];
//    loading = YES;
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0., 0., self.view.frame.size.width, self.view.frame.size.height)];
    backgroundImageView.image = [UIImage imageNamed:@"Default"];
    backgroundImageView.contentMode = UIViewContentModeBottom;
    [self.view addSubview:backgroundImageView];
    [backgroundImageView release];
    
    publishedQuotesTableView = [[UITableView alloc] initWithFrame:self.view.bounds];  
    publishedQuotesTableView.delegate = self;
    publishedQuotesTableView.dataSource = self;
    publishedQuotesTableView.backgroundColor = [UIColor clearColor];
    publishedQuotesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [publishedQuotesTableView setContentInset:UIEdgeInsetsMake(45., 0., 0., 0.)];
    
    [self.view addSubview:publishedQuotesTableView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(publishedQuotesUpdated:)
                                                 name:kNotificationDataUpdated
                                               object:nil];
    
    logoButton = [[UIButton alloc] initWithFrame:CGRectMake(0., 5., 165., 38.)];
    logoButton.center = CGPointMake(self.view.frame.size.width / 2., logoButton.center.y);
    [logoButton addTarget:self action:@selector(scrollToTopAction:) forControlEvents:UIControlEventTouchUpInside];
    [logoButton setImage:[UIImage imageNamed:@"logo"] forState:UIControlStateNormal];
    [self.view addSubview:logoButton];
    
    categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(175., 37., 140., 15.)];
    categoryLabel.text = @"Опубліковане";
    categoryLabel.backgroundColor = [UIColor clearColor];
    categoryLabel.font = [UIFont fontWithName:@"TimesNewRomanPSMT" size:13];
    categoryLabel.shadowColor = [UIColor blackColor];
    categoryLabel.shadowOffset = CGSizeMake(0., .5);
    categoryLabel.textColor = [UIColor colorWithRed:.04 green:.6 blue:.97 alpha:1.];
//    [self.view addSubview:categoryLabel];
    
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setBackgroundImage:[UIImage imageNamed:@"menu-button"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
    [menuButton setFrame:CGRectMake(15., -35., 36., 36.)];
    [publishedQuotesTableView addSubview:menuButton];
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
    [publishedQuotesTableView release], publishedQuotesTableView = nil;
    [categoryLabel release], categoryLabel = nil;
    [logoButton release], logoButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)publishedQuotesUpdated:(NSNotificationCenter *)notification
{
    [publishedQuotesTableView reloadData];
    loading = NO;
    [self hideFooter];
}

- (void)loadMoreQuotes
{
    [self showFooter];
    loading = YES;
    [dataSource loadMoreItems];
}

- (void)showFooter
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = footerView.center;
    [activityIndicator startAnimating];
    [footerView addSubview:activityIndicator];
    
    publishedQuotesTableView.tableFooterView = footerView;
    [footerView release];
    [activityIndicator release];
}

- (void)hideFooter
{
    publishedQuotesTableView.tableFooterView = nil;
}

#pragma mark - UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[dataSource items] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UBQuoteCell *cell = (UBQuoteCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UBQuoteCell *cell = (UBQuoteCell*)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.shareButtonsVisible) {
        [activeCell release], activeCell = nil;
        [cell hideShareButtons];
    } else {
        if (![[UIMenuController sharedMenuController] isMenuVisible]) {
            UBQuoteCell *ac = (UBQuoteCell*)[tableView cellForRowAtIndexPath:activeCell];
            [ac hideShareButtons];
            
            [activeCell release], activeCell = nil;
            activeCell = [indexPath retain];
            [cell showShareButtons];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([dataSource isMemberOfClass:[UBPublishedPicturesDataSource class]]) {
        return 70.;
    }
    
    UBQuote *quote = [[dataSource items] objectAtIndex:indexPath.row];
    return [UBQuoteCell heightForQuoteText:quote.text viewWidth:publishedQuotesTableView.frame.size.width];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    CGFloat alpha = 1;
    if (aScrollView.contentOffset.y < 0) {
        if (abs(aScrollView.contentOffset.y) >= publishedQuotesTableView.contentInset.top) {
            alpha = 1.;
        } else {
            alpha = 1. - (publishedQuotesTableView.contentInset.top + aScrollView.contentOffset.y) / 100;
        }
    } else {
        alpha = .5;
    }
    logoButton.alpha = MAX(alpha, .5);
    categoryLabel.alpha = MAX(alpha, .5);
    
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

#pragma mark -

- (void)quoteCell:(UBQuoteCell *)cell shareQuoteWithType:(UBQuoteShareType)shareType
{
    if (shareType == UBQuoteShareFacebookType) {
        
    } else if (shareType == UBQuoteShareTwitterType) {
        TWTweetComposeViewController *tweetComposer = [[TWTweetComposeViewController alloc] init];
        [self presentModalViewController:tweetComposer animated:YES];
        [tweetComposer release];
    } else if (shareType == UBQuoteShareEmailType) {
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        [self presentModalViewController:mailComposer animated:YES];
        [mailComposer release];
    }
}

#pragma mark - 

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
