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
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "Reachability.h"
#import "UkrBashAppDelegate.h"
#import "Picture.h"


@implementation UBPicturesContainerController

@synthesize dataSource;

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (viewer.view.superview) {
        return UIStatusBarStyleLightContent;
    } else {
        return UIStatusBarStyleDefault;
    }
}

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

- (void)childBackAction
{
    if (IS_IOS7) {
        [self.ubNavigationController setNeedsStatusBarAppearanceUpdate];
    }
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
    [tableView setContentInset:UIEdgeInsetsMake(1., 0., 0., 0.)];
    
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - tableView.bounds.size.height, self.view.frame.size.width, tableView.bounds.size.height)];
    _refreshHeaderView.delegate = self;
    [tableView addSubview:_refreshHeaderView];

    [self.view addSubview:tableView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(publishedQuotesUpdated:)
                                                 name:kNotificationDataUpdated
                                               object:nil];
    
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
    
    cell.quoteTextLabel.font = GET_FONT();
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
   // Lets add pictures to favorite there;
    
    UBPicture *picture = [[dataSource items] objectAtIndex:indexPath.row];
    
    NSManagedObjectContext *context = [(UkrBashAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Picture" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"pictureId == %@", [NSNumber numberWithInteger:picture.pictureId]];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    Picture *cdPicture;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if ([fetchedObjects count] > 0) {
        cdPicture = [fetchedObjects objectAtIndex:0];
    }
    [fetchRequest release];
    
    if (!picture.favorite) {
        NSManagedObjectContext *context = [(UkrBashAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        cdPicture = [NSEntityDescription insertNewObjectForEntityForName:@"Picture" inManagedObjectContext:context];
        cdPicture.pictureId = [NSNumber numberWithInteger:picture.pictureId];
        cdPicture.status = [NSNumber numberWithInteger:picture.status];
        cdPicture.type = picture.type;
        cdPicture.addDate = picture.addDate;
        cdPicture.pubDate = picture.pubDate;
        cdPicture.author = picture.author;
        cdPicture.authorId = [NSNumber numberWithInteger:picture.authorId];
        cdPicture.title = picture.title;
        cdPicture.thumbnail = picture.thumbnail;
        cdPicture.image = picture.image;
        cdPicture.rating = [NSNumber numberWithInteger:picture.rating];
        cdPicture.favorite = [NSNumber numberWithBool:YES];
        picture.favorite = YES;
    } else {
        cdPicture.favorite = [NSNumber numberWithBool:NO];
        picture.favorite = NO;
    }
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    // End setting favorites.
    
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
    
    
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName value:[NSString stringWithFormat:@"/%@/%@/picture/", NSStringFromClass([self class]), self.title]];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    if (viewer) {
        [viewer release], viewer = nil;
    }
    viewer = [[UBPicturesScrollViewController alloc] initWithDataSource:dataSource andStartPictureIndex:indexPath.row];
    viewer.parentController = self;
    viewer.view.frame = self.view.bounds;
    viewer.view.alpha = 0;
    [self.view addSubview:viewer.view];
    [UIView animateWithDuration:animationDuration animations:^{
        viewer.view.alpha = 1;
    }];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    if (IS_IOS7) {
        [self.ubNavigationController setNeedsStatusBarAppearanceUpdate];
    }
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
