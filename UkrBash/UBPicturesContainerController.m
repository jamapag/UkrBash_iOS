//
//  UBPicturesContainerController.m
//  UkrBash
//
//  Created by Михаил Гребенкин on 12.03.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "UBPicturesContainerController.h"
#import "Model.h"
#import "UBPictureCell.h"
#import "MediaCenter.h"
#import "UBPicture.h"
#import <QuartzCore/QuartzCore.h>
#import "UBPicturesScrollViewController.h"
#import "GANTracker.h"


@implementation UBPicturesContainerController

@synthesize dataSource;

- (id)initWithDataSourceClass:(Class)dataSourceClass
{
    self = [super init];
    if (self) {
        dataSource = [[dataSourceClass alloc] init];
        pendingImages = [[NSMutableDictionary alloc] init];
    }
    return self;
}

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
    [dataSource release];
    [tableView release];
    [pendingImages release];
    [_refreshHeaderView release];
    if (viewer) {
        [viewer release];
    }
    [super dealloc];
}

#pragma mark - actions

- (void)menuAction:(id)sender
{
    [self.ubNavigationController popViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    
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
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setContentInset:UIEdgeInsetsMake(1., 0., 0., 0.)];
    
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - tableView.bounds.size.height, self.view.frame.size.width, tableView.bounds.size.height)];
    _refreshHeaderView.delegate = self;
    [tableView addSubview:_refreshHeaderView];

    [self.view addSubview:tableView];
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kImageCenterNotification_didLoadImage object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSMutableArray *rows = [NSMutableArray array];
        for (NSString *url in [[note userInfo] objectForKey:@"imageUrl"]) {
            if ([pendingImages objectForKey:url]) {
                [rows addObject:[pendingImages objectForKey:url]];
                [pendingImages removeObjectForKey:url];
            }
        }
        if ([rows count] > 0) {
            [tableView reloadRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationFade];
        }
    }];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kImageCenterNotification_didLoadImage object:nil];
    [pendingImages removeAllObjects];
    [tableView release], tableView = nil;
    [_refreshHeaderView release], _refreshHeaderView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                duration:(NSTimeInterval)duration
{
    if (viewer) {
        [viewer willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    if (viewer) {
        [viewer willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
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
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
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
    
    UBPictureCell *cell = (UBPictureCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = (UBPictureCell *)[dataSource cellWithReuesIdentifier:cellIdentifier];
    }
    
    UBPicture *picture = [[dataSource items] objectAtIndex:indexPath.row];
    UIImage *image = [[MediaCenter imageCenter] imageWithUrl:picture.thumbnail];
    if (!image && ![pendingImages objectForKey:picture.thumbnail]) {
        [pendingImages setObject:indexPath forKey:picture.thumbnail];
    }
    
    [dataSource configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    CALayer *viewLayer = cell.layer;
    
    CGFloat animationDuration = .4;
    
    CABasicAnimation* popInAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    popInAnimation.duration = animationDuration;
    [popInAnimation setToValue:[NSNumber numberWithFloat:1.5]];
    
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.duration = animationDuration;
    [fadeAnimation setToValue:[NSNumber numberWithFloat:0.]];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = [NSArray arrayWithObjects:popInAnimation, fadeAnimation, nil];
    animationGroup.duration = animationDuration;
	
    [viewLayer addAnimation:animationGroup forKey:@"animation"];
    
    
    NSError * error = nil;
    [[GANTracker sharedTracker] trackPageview:[NSString stringWithFormat:@"/%@/%@/picture/", NSStringFromClass([self class]), self.title] withError:&error];
    if (viewer) {
        [viewer release], viewer = nil;
    }
    viewer = [[UBPicturesScrollViewController alloc] initWithDataSource:dataSource andStartPictureIndex:indexPath.row];
    viewer.view.frame = self.view.bounds;
    viewer.view.alpha = 0;
    [self.view addSubview:viewer.view];
    [UIView animateWithDuration:animationDuration animations:^{
        viewer.view.alpha = 1;
    }];
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:aScrollView];
    
//    CGFloat alpha = 1;
//    if (aScrollView.contentOffset.y < 0) {
//        if (abs(aScrollView.contentOffset.y) >= tableView.contentInset.top) {
//            alpha = 1.;
//        } else {
//            alpha = 1. - (tableView.contentInset.top + aScrollView.contentOffset.y) / 100;
//        }
//    } else {
//        alpha = .5;
//    }
//    logoButton.alpha = MAX(alpha, .5);
//    categoryLabel.alpha = MAX(alpha, .5);
    
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
