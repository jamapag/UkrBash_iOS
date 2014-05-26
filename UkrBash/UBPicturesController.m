//
//  UBPicturesController.m
//  UkrBash
//
//  Created by Maks Markovets on 06.05.14.
//
//

#import "UBPicturesController.h"
#import "MediaCenter/MediaCenter.h"
#import "Reachability.h"
#import "UBPictureCell.h"
#import "Picture.h"
#import "UBCollectionViewLayout.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "UkrBashAppDelegate.h"
#import "UBVkontakteActivity.h"

@implementation UBPicturesController

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
    [dataSource release];
    [pendingImages release];
    [_collectionView release];
    [fullSizeController release];
    [emptyView release];
    [super dealloc];
}

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
    dataSource.collectionView = _collectionView;
    
    [_collectionView registerClass:[UBPictureCollectionViewCell class] forCellWithReuseIdentifier:@"UBPictureCollectionViewCell"];
//    [_collectionView registerClass:[UBPictureCollectionReusableFooter class] forSupplementaryViewOfKind:UBCollectionElementKindSectionFooter withReuseIdentifier:@"UBPrictureCollectionViewFooter"];
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
    
    [dataSource loadNewItems];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (IS_IOS7) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resize:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (IS_IOS7) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)showEmptyView
{
    if (!emptyView) {
        emptyView = [[UBEmptyListView alloc] initWithFrame:CGRectMake(10, 70, 300, self.view.frame.size.height - 80)
                                          andEmptyViewType:UBEmptyListViewFavoritePicturesType];
        emptyView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
    if (!emptyView.superview) {
        [self.view addSubview:emptyView];
        emptyView.center = self.view.center;
    }
}

- (void)hideEmptyView
{
    if (emptyView.superview) {
        [emptyView removeFromSuperview];
    }
}

#pragma mark - Actions.

- (void)menuAction:(id)sender
{
    [self.ubNavigationController popViewControllerAnimated:YES];
}

- (void)resize:(NSNotification *)notification
{
    [_collectionView reloadData];
}

#pragma mark - UICollectionViewDataSoruce methods.

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([dataSource numberOfRowsInSection:section] == 0) {
        [self showEmptyView];
    } else {
        [self hideEmptyView];
    }
    return [dataSource numberOfRowsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UBPictureCollectionViewCell *imageCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UBPictureCollectionViewCell" forIndexPath:indexPath];
    imageCell.shareDelegate = self;
    Picture *picture = [dataSource objectAtIndexPath:indexPath];
    UIImage *image = [[MediaCenter imageCenter] imageWithUrl:picture.image];
    if (!image && ![pendingImages objectForKey:picture.image]) {
        [pendingImages setObject:indexPath forKey:picture.image];
        imageCell.imageView.image = nil;
    } else {
        imageCell.imageView.image = image;
    }
    imageCell.authorLabel.text = picture.author;
    if (picture.rating > 0) {
        imageCell.ratingLabel.text = [NSString stringWithFormat:@"+%ld", [picture.rating longValue]];
    } else if (picture.rating <= 0) {
        imageCell.ratingLabel.text = [NSString stringWithFormat:@"%ld", [picture.rating longValue]];
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

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
//    UBPictureCollectionReusableFooter *footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"UBPrictureCollectionViewFooter" forIndexPath:indexPath];
//    return footer;
    return nil;
}

#pragma mark - UICollectionViewDelegateFlowLayout methods.

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
//    if (shouldShowFooter) {
//        return CGSizeMake(50, 50);
//    }
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
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    if (IS_IOS7) {
        [self.ubNavigationController setNeedsStatusBarAppearanceUpdate];
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
        fullSizeController.delegate = self;
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
//    rotating = YES;
}

- (void)viewDidLayoutSubviews
{
//    rotating = NO;
}

#pragma mark - UBQuoteCollectionCellDelegate methods.

- (void)shareActionForCell:(UBPictureCollectionViewCell *)cell andRectForPopover:(CGRect)rect
{
    NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
    Picture *picture = [dataSource objectAtIndexPath:indexPath];
    NSString *pictureUrlString = [NSString stringWithFormat:@"http://ukrbash.org/picture/%ld", [picture.pictureId longValue]];
    NSURL *pictureUrl = [NSURL URLWithString:pictureUrlString];
    UIImage *image = [[MediaCenter imageCenter] imageWithUrl:picture.image];
    NSString *title = [NSString stringWithFormat:@"Картинка %ld", [picture.pictureId longValue]];
    NSString *description = picture.title == nil ? @"" : picture.title;

    
    UBVkontakteActivity *vkActivity = [[UBVkontakteActivity alloc] init];
    vkActivity.attachmentTitle = title;
    vkActivity.parentViewController = self;
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[description, pictureUrl, image] applicationActivities:@[vkActivity]];
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
    Picture *picture = [dataSource objectAtIndexPath:indexPath];
    NSString *pictureUrl = [NSString stringWithFormat:@"http://ukrbash.org/picture/%ld", [picture.pictureId longValue]];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = pictureUrl;
}

- (void)openInBrowserActionForIndexPath:(NSIndexPath *)indexPath
{
    Picture *picture = [dataSource objectAtIndexPath:indexPath];
    NSString *pictureUrl = [NSString stringWithFormat:@"http://ukrbash.org/picture/%ld", [picture.pictureId longValue]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:pictureUrl]];
}

- (void)favoriteActionForCell:(UBPictureCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
    NSManagedObjectContext *context = [(UkrBashAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    Picture *picture = [dataSource objectAtIndexPath:indexPath];
    
    if (![picture.favorite boolValue]) {
        picture.favorite = [NSNumber numberWithBool:YES];
    } else {
        picture.favorite = [NSNumber numberWithBool:NO];
    }
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

#pragma mark - UBFullSizePictureViewControllerDelegate Methods.

- (void)userDidScroll:(UBFullSizePictureViewController *)viewController toPictureAtIndex:(NSInteger)index
{
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
}

- (void)updatePictureAtIndex:(NSInteger)index
{
    // Currently used only for favorites, so do nothing.
}
@end
