//
//  UBFullSizePictureViewController.m
//  UkrBash
//
//  Created by Maks Markovets on 13.05.14.
//
//

#import "UBFullSizePictureViewController.h"
#import "UBPictureViewController.h"
#import "UBPicture.h"
#import "Picture.h"
#import "MediaCenter/MediaCenter.h"
#import "SharingController.h"
#import "UBQuoteCell.h"

@implementation UBFullSizePictureViewController

@synthesize dataSource;

- (id)initWithDataSource:(UBPicturesDataSource *)aDataSource andInitPicuteIndex:(NSInteger)index
{
    if (self = [super  init]) {
        pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{UIPageViewControllerOptionInterPageSpacingKey: @(30)}];
        pageViewController.dataSource = self;
        pageViewController.delegate = self;
        [self addChildViewController:pageViewController];
        self.dataSource = aDataSource;
        initPictureIndex = index;
    }
    return self;
}

- (void)dealloc
{
    [pageViewController release];
    [backButton release];
    [toolbar release];
    [infoView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    tapGesture.numberOfTapsRequired = 1;
    [pageViewController.view addGestureRecognizer:tapGesture];
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [pageViewController.view addGestureRecognizer:doubleTapGesture];
    
    [tapGesture requireGestureRecognizerToFail:doubleTapGesture];
    [doubleTapGesture release];
    [tapGesture release];
    
    float topY = 0;
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // Load resources for iOS 6.1 or earlier;
        topY = 0;
    } else {
        // Load resources for iOS 7 or later
        topY = 20;
    }

    CGFloat padding = 10.;
    
    // Configure child view controllers
    [pageViewController setViewControllers:@[[self photoViewControllerForIndex:initPictureIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Configure self's view
    self.view.backgroundColor = [UIColor blackColor];
    
    // Configure subviews
    pageViewController.view.frame = self.view.bounds;
    
    pageViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:pageViewController.view];
    
    CGFloat sharingButtonHeight = 32.;
    toolbar = [[UIView alloc] initWithFrame:CGRectMake(0., topY, self.view.frame.size.width, padding + sharingButtonHeight)];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    toolbar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:toolbar];
    
    CGFloat x = padding, y = padding;
    backButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    backButton.frame = CGRectMake(x - 5, y - 5, sharingButtonHeight + 10, sharingButtonHeight + 10);
    [backButton setImage:[UIImage imageNamed:@"back-btn"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:backButton];
    padding += 10.;
    x += sharingButtonHeight + padding;
    
    if ([SharingController isSharingAvailableForNetworkType:SharingFacebookNetwork]) {
        UIButton *fbButton = [UIButton buttonWithType:UIButtonTypeCustom];
        fbButton.frame = CGRectMake(x, y, sharingButtonHeight, sharingButtonHeight);
        [fbButton setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateNormal];
        [fbButton addTarget:self action:@selector(fbShareAction:) forControlEvents:UIControlEventTouchUpInside];
        [toolbar addSubview:fbButton];
        x += sharingButtonHeight + padding;
    }
    
    if ([SharingController isSharingAvailableForNetworkType:SharingTwitterNetwork]) {
        UIButton *twButton = [UIButton buttonWithType:UIButtonTypeCustom];
        twButton.frame = CGRectMake(x, y, sharingButtonHeight, sharingButtonHeight);
        [twButton setImage:[UIImage imageNamed:@"twitter"] forState:UIControlStateNormal];
        [twButton addTarget:self action:@selector(twShareAction:) forControlEvents:UIControlEventTouchUpInside];
        [toolbar addSubview:twButton];
        x += sharingButtonHeight + padding;
    }
    
    if ([SharingController isSharingAvailableForNetworkType:SharingEMailNetwork]) {
        UIButton *mailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        mailButton.frame = CGRectMake(x, y, sharingButtonHeight, sharingButtonHeight);
        [mailButton setImage:[UIImage imageNamed:@"gmail"] forState:UIControlStateNormal];
        [mailButton addTarget:self action:@selector(mailShareAction:) forControlEvents:UIControlEventTouchUpInside];
        [toolbar addSubview:mailButton];
        x += sharingButtonHeight + padding;
    }
    
    if ([SharingController isSharingAvailableForNetworkType:SharingVkontakteNetwork]) {
        UIButton *mailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        mailButton.frame = CGRectMake(x, y, sharingButtonHeight, sharingButtonHeight);
        [mailButton setImage:[UIImage imageNamed:@"vk"] forState:UIControlStateNormal];
        [mailButton addTarget:self action:@selector(vkontakteShareAction:) forControlEvents:UIControlEventTouchUpInside];
        [toolbar addSubview:mailButton];
    }
    
    
    padding = 10.;
    infoView = [[UBPictureInfoView alloc] initWithFrame:CGRectMake(padding, self.view.frame.size.height - padding - 80., self.view.frame.size.width - 2 * padding, 80.)];
    infoView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:infoView];
    [self updatePictureInfoView];
}

#pragma mark - Actions.

- (void)setCurrentPictureIndex:(NSInteger)pictureIndex
{
    [pageViewController setViewControllers:@[[self photoViewControllerForIndex:pictureIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self updatePictureInfoView];
}

- (void)backAction:(id)sender
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    if (IS_IOS7) {
        [self.ubNavigationController setNeedsStatusBarAppearanceUpdate];
    }
    
    [UIView animateWithDuration:.3
                     animations:^{
                         self.view.alpha = 0.;
                     }
                     completion:^(BOOL finished) {
                         [self.view removeFromSuperview];
                     }];
}

- (void)tapGestureHandler:(UITapGestureRecognizer *)tapGesture
{
    if (tapGesture.numberOfTapsRequired == 1 && tapGesture.state == UIGestureRecognizerStateEnded) {
        if (toolbar.hidden) {
            toolbar.hidden = NO;
            infoView.hidden = NO;
        } else {
            toolbar.hidden = YES;
            infoView.hidden = YES;
        }
    } else if (tapGesture.numberOfTapsRequired == 2 && tapGesture.state == UIGestureRecognizerStateEnded) {
        [pageViewController.viewControllers.firstObject doubleTapAtPoint:[tapGesture locationInView:tapGesture.view]];
    }
}

#pragma mark - Private methods.

-(UBPictureViewController *)photoViewControllerForIndex:(NSInteger)index
{
    if (index < 0 || index > [dataSource numberOfRowsInSection:0] - 1) {
        return nil;
    }
    id picture = [dataSource objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    if ([picture isKindOfClass:[UBPicture class]]) {
        UBPicture *ubPicture = (UBPicture *)picture;
        UBPictureViewController *pictureViewController = [[UBPictureViewController alloc] init];
        pictureViewController.pictureIndex = index;
        pictureViewController.imageUrl = ubPicture.image;
        NSString *fullScreenPictureUrl = [ubPicture.image stringByReplacingOccurrencesOfString:@"/400/" withString:@"/600/"];
        pictureViewController.fullScreenImageUrl = fullScreenPictureUrl;
        return [pictureViewController autorelease];
    } else if ([picture isKindOfClass:[Picture class]]) {
        Picture *cdPicture = (Picture *)picture;
        UBPictureViewController *pictureViewController = [[UBPictureViewController alloc] init];
        pictureViewController.pictureIndex = index;
        pictureViewController.imageUrl = cdPicture.image;
        NSString *fullScreenPictureUrl = [cdPicture.image stringByReplacingOccurrencesOfString:@"/400/" withString:@"/600/"];
        pictureViewController.fullScreenImageUrl = fullScreenPictureUrl;
        return [pictureViewController autorelease];
    }
    return nil;
}

- (void)updatePictureInfoView
{
    currentPictureIndex = [pageViewController.viewControllers.firstObject pictureIndex];
    if (currentPictureIndex >= 0 && currentPictureIndex < [dataSource numberOfRowsInSection:0]) {
        [dataSource configurePictureInfoView:infoView forRowAtIndexPath:[NSIndexPath indexPathForRow:currentPictureIndex inSection:0]];
    }
}


#pragma mark - UIPageViewControllerDelegate Methods 

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    [self updatePictureInfoView];
    if (completed) {
        for (UBPictureViewController *pictureController in previousViewControllers) {
            [pictureController zoomOutIfNeeded];
        }
    }
}

#pragma mark - UIPageViewControllerDataSource Methods

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UBPictureViewController *)viewController
{
    return [self photoViewControllerForIndex:viewController.pictureIndex - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UBPictureViewController *)viewController
{
    return [self photoViewControllerForIndex:viewController.pictureIndex + 1];
}

@end
