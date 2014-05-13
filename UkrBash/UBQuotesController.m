//
//  UBQuotesController.m
//  UkrBash
//
//  Created by Maks Markovets on 28.04.14.
//
//

#import "UBQuotesController.h"
#import "UBQuote.h"
#import "UBQuoteCell.h"
#import "UkrBashAppDelegate.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

@implementation UBQuotesController

@synthesize dataSource;

- (id)initWithDataSourceClass:(Class)dataSourceClass
{
    if (self = [super init]) {
        dataSource = [[dataSourceClass alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [dataSource release];
    [tableView release];
    [refreshHeaderView release];
    [super dealloc];
}

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
    [dataSource setTableView:tableView];
    
    [self.view addSubview:tableView];
    
    
//    refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - tableView.bounds.size.height, self.view.frame.size.width, tableView.bounds.size.height)];
//    refreshHeaderView.delegate = self;
//    [tableView addSubview:refreshHeaderView];
    
    [dataSource loadNewItems];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(publishedQuotesUpdated:)
//                                                 name:kNotificationDataUpdated
//                                               object:nil];
    
    [headerView release];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (IS_IOS7) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resize:) name:UIContentSizeCategoryDidChangeNotification object:nil];
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

#pragma mark - Actions.

- (void)menuAction:(id)sender
{
    [self.ubNavigationController popViewControllerAnimated:YES];
}

- (void)resize:(NSNotification *)notification
{
    [tableView reloadData];
}

#pragma mark - UBQuoteCellDelegate methods.

- (void)quoteCell:(UBQuoteCell *)cell shareQuoteWithType:(SharingNetworkType)networkType
{
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    Quote *quote = [dataSource objectAtIndexPath:indexPath];
    NSURL *quoteUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://ukrbash.org/quote/%ld", [quote.quoteId longValue]]];
    
    SharingController *sharingController = [SharingController sharingControllerForNetworkType:networkType];
    sharingController.url = quoteUrl;
    sharingController.message = (networkType == SharingEMailNetwork) ? quote.text : nil;
    sharingController.rootViewController = self;
    [sharingController setAttachmentTitle:[NSString stringWithFormat:@"Цитата %ld", [quote.quoteId longValue]]];
    [sharingController setAttachmentDescription:quote.text];
    [sharingController showSharingDialog];
    
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"sharing"
                                                                                        action:@"quotes"
                                                                                         label:NSStringFromClass([sharingController class])
                                                                                         value:@(-1)] build]];
}

- (void)favoriteActionForCell:(UBQuoteCell *)cell
{
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    NSManagedObjectContext *context = [(UkrBashAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    Quote *quote = [dataSource objectAtIndexPath:indexPath];
    
    if (![quote.favorite boolValue]) {
        quote.favorite = [NSNumber numberWithBool:YES];
    } else {
        quote.favorite = [NSNumber numberWithBool:NO];
    }
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
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
    
    Quote *quote = [dataSource objectAtIndexPath:selectedIndexPath];
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

#pragma mark - UITableViewDelegate methods.

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UBQuote *quote = [[dataSource items] objectAtIndex:indexPath.row];
    return [UBQuoteCell heightForQuoteText:quote.text viewWidth:tableView.frame.size.width];
}

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

#pragma mark - UITableViewDataSource methods.

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource numberOfRowsInSection:section];
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

@end
