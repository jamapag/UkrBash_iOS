//
//  UBPicturesCollectionViewController.m
//  UkrBash
//
//  Created by maks on 20.02.13.
//
//

#import "UBPicturesCollectionViewController.h"
#import "UBPictureCollectionViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UBPicture.h"
#import "MediaCenter.h"
#import "UBCollectionViewLayout.h"
#import "Model.h"
#import "UBPictureCollectionReusableFooter.h"

@interface UBPicturesCollectionViewController ()

@end

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
    
    UBCollectionViewLayout *layout = [[UBCollectionViewLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 45., self.view.frame.size.width, self.view.frame.size.height - 45) collectionViewLayout:layout];
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
    [_collectionView registerClass:[UBPictureCollectionReusableFooter class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"UBPrictureCollectionViewFooter"];
    
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[dataSource items] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UBPictureCollectionViewCell *imageCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UBPictureCollectionViewCell" forIndexPath:indexPath];
    UBPicture *picture = [[dataSource items] objectAtIndex:indexPath.row];
    UIImage *image = [[MediaCenter imageCenter] imageWithUrl:picture.image];
    if (!image && ![pendingImages objectForKey:picture.image]) {
        [pendingImages setObject:indexPath forKey:picture.image];
        imageCell.imageView.image = nil;
    } else {
        imageCell.imageView.image = image;
    }
    [imageCell setPictureTitle:picture.title];
    return imageCell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UBPictureCollectionReusableFooter *footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"UBPrictureCollectionViewFooter" forIndexPath:indexPath];
    return footer;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if (shouldShowFooter) {
        return CGSizeMake(50, 50);
    }
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(495, 495);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
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
    if(y > h + reload_distance) {
        if (!loading) {
            NSLog(@"load more rows");
            [self loadMorePictures];
        }
    }
}


@end