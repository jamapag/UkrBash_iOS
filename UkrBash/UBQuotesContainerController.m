//
//  UBQuotesContainerController.m
//  UkrBash
//
//  Created by Maks Markovets on 21.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UBQuotesContainerController.h"
#import "Model.h"
#import "UBQuote.h"
#import "UBQuoteCell.h"
#import "UBNavigationController.h"

#define FONT_SIZE 12.0f
#define CELL_CONTENT_WIDTH 320.0f - 10.0f
#define CELL_CONTENT_MARGIN 5.0f


@implementation UBQuotesContainerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    [activeCell release];
    [publishedQuotesTableView release];
    [currentQuotes release];
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

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    
    
    currentQuotes = [[[Model sharedModel] publishedQuotes] retain];
    [[Model sharedModel] loadPublishedQuotes];
    
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
                                                 name:kNotificationPublishedQuotesUpdated
                                               object:nil];
    
    logoButton = [[UIButton alloc] initWithFrame:CGRectMake(0., 5., 152., 39.)];
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
    [self.view addSubview:categoryLabel];
    
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [menuButton setTitle:@"M" forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
    [menuButton setFrame:CGRectMake(15., -37., 32., 32.)];
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
    [currentQuotes release], currentQuotes = nil;
    [categoryLabel release], categoryLabel = nil;
    [logoButton release], logoButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    [[Model sharedModel] loadMorePublishedQuotes];
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
    return [currentQuotes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UBQuoteCell *cell = (UBQuoteCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[UBQuoteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    UBQuote *quote = (UBQuote *)[currentQuotes objectAtIndex:indexPath.row];
    cell.quoteTextLabel.text = quote.text;
    
//    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    
//    CGSize size = [quote.text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
//    cell.quoteTextLabel.frame = CGRectMake(CELL_CONTENT_MARGIN, CELL_CONTENT_MARGIN, CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), MAX(size.height, 44.0f));

    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UBQuoteCell *cell = (UBQuoteCell*)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.shareButtonsVisible) {
        [activeCell release], activeCell = nil;
        [cell hideShareButtons];
    } else {
        UBQuoteCell *ac = (UBQuoteCell*)[tableView cellForRowAtIndexPath:activeCell];
        [ac hideShareButtons];
        
        [activeCell release], activeCell = nil;
        activeCell = [indexPath retain];
        [cell showShareButtons];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UBQuote *quote = [currentQuotes objectAtIndex:indexPath.row];
    NSString *text = quote.text;
    
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat height = MAX(size.height, 44.0f);
    
    return height + (CELL_CONTENT_MARGIN * 2) + (CELL_CONTENT_MARGIN * 2);
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
    
    float reload_distance = 10;
    if(y > h + reload_distance) {
        if (!loading) {
            NSLog(@"load more rows");
            [self loadMoreQuotes];
        }
    }
}

@end
