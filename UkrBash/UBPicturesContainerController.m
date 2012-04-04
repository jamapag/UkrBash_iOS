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
#import "UBPicturesViewerController.h"
#import <QuartzCore/QuartzCore.h>


@interface UBPicturesContainerController ()
{
    UBPicturesViewerController *viewerController;
}

@end

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
    [categoryLabel release];
    [logoButton release];
    [pendingImages release];
    [viewerController release];
    [_refreshHeaderView release];
    [super dealloc];
}

#pragma mark -

- (UBPicturesViewerController*)picturesViewerController
{
    if (!viewerController) {
        viewerController = [[UBPicturesViewerController alloc] initWithDataSource:dataSource currentIndex:0];
    }
    return viewerController;
}

#pragma mark - actions

- (void)scrollToTopAction:(id)sender
{
    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0. inSection:0.] atScrollPosition:UITableViewScrollPositionTop animated:YES];
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
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0., 0., self.view.frame.size.width, self.view.frame.size.height)];
    backgroundImageView.image = [UIImage imageNamed:@"view-background"];
    backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    backgroundImageView.contentMode = UIViewContentModeBottom;
    [self.view addSubview:backgroundImageView];
    [backgroundImageView release];
    
    UIImage *borderImage = [UIImage imageNamed:@"border"];
    UIImageView *borderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0., 0., borderImage.size.width, self.view.frame.size.height)];
    borderImageView.image = borderImage;
    borderImageView.contentMode = UIViewContentModeBottomLeft;
    [self.view addSubview:borderImageView];
    [borderImageView release];
    
    tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setContentInset:UIEdgeInsetsMake(1., 0., 0., 0.)];
    
    if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - tableView.bounds.size.height, self.view.frame.size.width, tableView.bounds.size.height)];
		view.delegate = self;
		[tableView addSubview:view];
		_refreshHeaderView = view;
		[view release];		
	}

    [self.view addSubview:tableView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(publishedQuotesUpdated:)
                                                 name:kNotificationDataUpdated
                                               object:nil];
    
    logoButton = [[UIButton alloc] initWithFrame:CGRectMake(0., 5., 165., 38.)];
    logoButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
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
    [menuButton setFrame:CGRectMake(15., 5., 36., 36.)];
    [self.view addSubview:menuButton];
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
    [categoryLabel release], categoryLabel = nil;
    [logoButton release], logoButton = nil;
    [_refreshHeaderView release], _refreshHeaderView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
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
    
    
    UBPicturesViewerController *viewer = [self picturesViewerController];
    viewer.pictureIndex = indexPath.row;
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
