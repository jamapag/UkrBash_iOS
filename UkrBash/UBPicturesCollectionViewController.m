//
//  UBPicturesCollectionViewController.m
//  UkrBash
//
//  Created by maks on 20.02.13.
//
//

#import "UBPicturesCollectionViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UBPicture.h"
#import "MediaCenter.h"
#import "UBCollectionViewLayout.h"
#import "Model.h"
#import "UBPictureCollectionReusableFooter.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "Reachability.h"
#import "UkrBashAppDelegate.h"
#import "Picture.h"
#import "UBVkontakteActivity.h"

@interface UBPicturesCollectionViewController ()

@end

NSString *const UBCollectionElementKindSectionFooter = @"UICollectionElementKindSectionFooter";

@implementation UBPicturesCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:localImageLoadedObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:localPicturesLoadedObserver];
    [_collectionView release];
    [_refreshControl release];
    [dataSource release];
    [pendingImages release];
    [fullSizeController release];
    [super dealloc];
}

#pragma mark - actions

- (void)menuAction:(id)sender
{
    [self.ubNavigationController popViewControllerAnimated:YES];
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
    

    UBCollectionViewLayout *layout = [[UBCollectionViewLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, headerView.frame.size.height + headerView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - headerView.frame.size.height - headerView.frame.origin.y) collectionViewLayout:layout];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 10.f;
    layout.minimumInteritemSpacing = 5.f;
    [layout release];
    [self.view addSubview:_collectionView];
    
    [_collectionView registerClass:[UBPictureCollectionViewCell class] forCellWithReuseIdentifier:@"UBPictureCollectionViewCell"];
    [_collectionView registerClass:[UBPictureCollectionReusableFooter class] forSupplementaryViewOfKind:UBCollectionElementKindSectionFooter withReuseIdentifier:@"UBPrictureCollectionViewFooter"];
    [headerView release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIMenuItem *copyUrlMenuItem = [[UIMenuItem alloc] initWithTitle:@"Копіювати URL" action:@selector(copyUrlAction:)];
    UIMenuItem *openInBrowserMenuItem = [[UIMenuItem alloc] initWithTitle:@"Відкрити в Safari" action:@selector(openInBrowserAction:)];
    [[UIMenuController sharedMenuController] setMenuItems:[NSArray arrayWithObjects:copyUrlMenuItem, openInBrowserMenuItem, nil]];
    
    localImageLoadedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kImageCenterNotification_didLoadImage object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSMutableArray *rows = [NSMutableArray array];
        for (NSString *url in [[note userInfo] objectForKey:@"imageUrl"]) {
            if ([pendingImages objectForKey:url]) {
                [rows addObject:[pendingImages objectForKey:url]];
                [pendingImages removeObjectForKey:url];
            }
        }
        if ([rows count] > 0) {
            [_collectionView reloadItemsAtIndexPaths:rows];
        }
    }];
    localPicturesLoadedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationDataUpdated object:nil queue:nil usingBlock:^(NSNotification *note) {
        loading = NO;
        [self hideFooter];
        [_refreshControl endRefreshing];
        [_collectionView reloadData];
    }];
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(startRefresh:) forControlEvents:UIControlEventValueChanged];
    [_collectionView addSubview:_refreshControl];
    [self startRefresh:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void)reachabilityChanged:(NSNotification *)notification
{
    Reachability *reach = notification.object;
    if ([reach isReachable]) {
        if (!loading) {
            [self startRefresh:nil];
        }
    }
    else {
        loading = NO;
    }
}

- (void)startRefresh:(id)sender
{
    loading = YES;
    [dataSource loadNewItems];
    if (sender == nil) {
        [_refreshControl beginRefreshing];
    }
}

- (void)loadMorePictures
{
    loading = YES;
    [dataSource loadMoreItems];
    [self showFooter];
}

- (void)showFooter
{
    if (shouldShowFooter) {
        return;
    }
    shouldShowFooter = YES;
    [_collectionView.collectionViewLayout invalidateLayout];
}

- (void)hideFooter
{
    if (!shouldShowFooter) {
        return;
    }
    shouldShowFooter = NO;
    [_collectionView.collectionViewLayout invalidateLayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UBQuoteCollectionCellDelegate methods.

- (void)shareActionForCell:(UBPictureCollectionViewCell *)cell andRectForPopover:(CGRect)rect
{
    NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
    UBPicture *picture = [dataSource objectAtIndexPath:indexPath];
    NSString *pictureUrlString = [NSString stringWithFormat:@"http://ukrbash.org/picture/%ld", (long)picture.pictureId];
    NSURL *pictureUrl = [NSURL URLWithString:pictureUrlString];
    UIImage *image = [[MediaCenter imageCenter] imageWithUrl:picture.image];
    
    UBVkontakteActivity *vkActivity = [[UBVkontakteActivity alloc] init];
    vkActivity.parentViewController = self;
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[picture.title, pictureUrl, image] applicationActivities:@[vkActivity]];
    activityViewController.excludedActivityTypes = @[UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact];
    [vkActivity release];
    [activityViewController setCompletionHandler:^(NSString *activityType, BOOL completed) {
        if (IS_IOS7) {
            [self.ubNavigationController setNeedsStatusBarAppearanceUpdate];
        }
    }];
    [self presentViewController:activityViewController animated:YES completion:nil];
    [activityViewController release];
}

- (void)copyUrlActionForCell:(UBPictureCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
    [self copyUrlActionForIndexPath:indexPath];
}

- (void)openInBrowserActionForCell:(UBPictureCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
    [self openInBrowserActionForIndexPath:indexPath];
}

- (void)copyUrlActionForIndexPath:(NSIndexPath *)indexPath
{
    id picture = [dataSource objectAtIndexPath:indexPath];
    NSString *pictureUrl;
    if ([picture isKindOfClass:[UBPicture class]]) {
        UBPicture *ubPicture = (UBPicture *)picture;
        pictureUrl = [NSString stringWithFormat:@"http://ukrbash.org/picture/%ld", (long)ubPicture.pictureId];
    } else {
        Picture *cdPicture = (Picture *)picture;
        pictureUrl = [NSString stringWithFormat:@"http://ukrbash.org/picture/%ld", [cdPicture.pictureId longValue]];
    }
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = pictureUrl;
}

- (void)openInBrowserActionForIndexPath:(NSIndexPath *)indexPath
{
    id picture = [dataSource objectAtIndexPath:indexPath];
    NSString *pictureUrl;
    if ([picture isKindOfClass:[UBPicture class]]) {
        UBPicture *ubPicture = (UBPicture *)picture;
        pictureUrl = [NSString stringWithFormat:@"http://ukrbash.org/picture/%ld", (long)ubPicture.pictureId];
    } else {
        Picture *cdPicture = (Picture *)picture;
        pictureUrl = [NSString stringWithFormat:@"http://ukrbash.org/picture/%ld", [cdPicture.pictureId longValue]];
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:pictureUrl]];
}

- (void)favoriteActionForCell:(UBPictureCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
    UBPicture *picture = [[dataSource items] objectAtIndex:indexPath.row];
    
    NSManagedObjectContext *context = [(UkrBashAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Picture" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"pictureId == %@", [NSNumber numberWithInteger:picture.pictureId]];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    Picture *cdPicture = nil;
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
    } else {
        if (picture.favorite) {
            [cell.favoriteButton setImage:[UIImage imageNamed:@"favorite_active"] forState:UIControlStateNormal];
        } else {
            [cell.favoriteButton setImage:[UIImage imageNamed:@"favorite"] forState:UIControlStateNormal];
        }
    }
}

#pragma mark - UICollectionViewDataSoruce methods.

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    return [[dataSource items] count];
    return [dataSource numberOfRowsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UBPictureCollectionViewCell *imageCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UBPictureCollectionViewCell" forIndexPath:indexPath];
    imageCell.shareDelegate = self;
    UBPicture *picture = [dataSource objectAtIndexPath:indexPath];
    UIImage *image = [[MediaCenter imageCenter] imageWithUrl:picture.image];
    if (!image && ![pendingImages objectForKey:picture.image]) {
        [pendingImages setObject:indexPath forKey:picture.image];
        imageCell.imageView.image = nil;
    } else {
        imageCell.imageView.image = image;
    }
    imageCell.authorLabel.text = picture.author;
    if (picture.rating > 0) {
        imageCell.ratingLabel.text = [NSString stringWithFormat:@"+%ld", (long)picture.rating];
    } else if (picture.rating <= 0) {
        imageCell.ratingLabel.text = [NSString stringWithFormat:@"%ld", (long)picture.rating];
    }
    imageCell.dateLabel.text = [[dataSource dateFormatter] stringFromDate:picture.addDate];
    [imageCell setPictureTitle:picture.title];
    if (picture.favorite) {
        [imageCell.favoriteButton setImage:[UIImage imageNamed:@"favorite_active"] forState:UIControlStateNormal];
    } else {
        [imageCell.favoriteButton setImage:[UIImage imageNamed:@"favorite"] forState:UIControlStateNormal];
    }
    return imageCell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    
    UBPictureCollectionReusableFooter *footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"UBPrictureCollectionViewFooter" forIndexPath:indexPath];
    return footer;
}

#pragma mark - UICollectionViewDelegateFlowLayout methods.

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if (shouldShowFooter) {
        return CGSizeMake(50, 50);
    }
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_PAD) {
        return CGSizeMake(495, 575);
    } else {
        return CGSizeMake(300, 380);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}


#pragma mark - UICollectionViewDelegate methods.

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IOS7) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [self.ubNavigationController setNeedsStatusBarAppearanceUpdate];
    } else {
        // iOS 6
        // Do nothing
    }
    
    UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:indexPath];
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
    
    if (!fullSizeController) {
        fullSizeController = [[UBFullSizePictureViewController alloc] initWithDataSource:dataSource andInitPicuteIndex:indexPath.row];
        fullSizeController.dataSource = dataSource;
        fullSizeController.view.frame = self.view.bounds;
    } else {
        fullSizeController.view.frame = self.view.bounds;
        [fullSizeController setCurrentPictureIndex:indexPath.row];
    }
    fullSizeController.view.alpha = 0;
    [self.view addSubview:fullSizeController.view];
    [UIView animateWithDuration:animationDuration animations:^{
        fullSizeController.view.alpha = 1;
    }];

}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copyUrlAction:) || action == @selector(openInBrowserAction:)) {
        return YES;
    }
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copyUrlAction:)) {
        [self copyUrlActionForIndexPath:indexPath];
    } else if (action == @selector(openInBrowserAction:)) {
        [self openInBrowserActionForIndexPath:indexPath];
    }
}

#pragma mark - UIMenuController required methods (Might not be needed on iOS 7)

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - Rotation handling

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [fullSizeController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    rotating = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [fullSizeController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    // TODO: add ios 6 support.
    // FORCE collectionView frame because of broken layout after rotate (sometimes).
    
    float y = 0;
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // Load resources for iOS 6.1 or earlier;
        y = 0;
    } else {
        // Load resources for iOS 7 or later
        y = 20;
    }
    _collectionView.frame = CGRectMake(0, y + 44., self.view.frame.size.width, self.view.frame.size.height - (y + 44.));
    rotating = NO;
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    if (rotating) {
        return;
    }
    
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    if (bounds.size.height > h) {
        return;
    }
    
    if (h == 0 && [[dataSource items] count] > 0) {
        return;
    }
    
    float reload_distance = 10;
    if(y > h + reload_distance && size.height > bounds.size.height) {
        if (!loading) {
            NSLog(@"load more rows");
            [self loadMorePictures];
        }
    }
}


@end
