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
#import "UBVkontakteActivity.h"
#import "UkrBashAppDelegate.h"

@implementation UBFullSizePictureViewController

@synthesize delegate;
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
    [favoriteButton release];
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
//    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
//        // Load resources for iOS 6.1 or earlier;
//        topY = 0;
//    } else {
//        // Load resources for iOS 7 or later
////        topY = 20;
//    }

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
    toolbar = [[UIView alloc] initWithFrame:CGRectMake(0., topY, self.view.frame.size.width, 2 * padding + sharingButtonHeight)];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    toolbar.backgroundColor = [UIColor colorWithWhite:.0 alpha:.5];
    [self.view addSubview:toolbar];
    
    CGFloat x = padding, y = padding;
    backButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    backButton.frame = CGRectMake(x - 5, y - 5, sharingButtonHeight + 10, sharingButtonHeight + 10);
    [backButton setImage:[UIImage imageNamed:@"back-btn"] forState:UIControlStateNormal];
    backButton.imageView.contentMode = UIViewContentModeCenter;
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:backButton];
    padding += 10.;
    
    x = self.view.frame.size.width - padding - sharingButtonHeight;
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    shareButton.frame = CGRectMake(x, y, sharingButtonHeight, sharingButtonHeight);
    [shareButton setImage:[UIImage imageNamed:@"share-white"] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:shareButton];
    
    x -= sharingButtonHeight + padding;
    
    favoriteButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    favoriteButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    favoriteButton.frame = CGRectMake(x, y, sharingButtonHeight, sharingButtonHeight);
    [favoriteButton setImage:[UIImage imageNamed:@"favorite-white"] forState:UIControlStateNormal];
    [favoriteButton addTarget:self action:@selector(favoriteAction:) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:favoriteButton];

    padding = 10.;
    infoView = [[UBPictureInfoView alloc] initWithFrame:CGRectMake(padding, self.view.frame.size.height - padding - 80., self.view.frame.size.width - 2 * padding, 80.)];
    infoView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:infoView];
    [self updatePictureInfoView];
}

#pragma mark - Actions.

- (void)setCurrentPictureIndex:(NSInteger)pictureIndex animated:(BOOL)animated
{
    
    // Because of http://stackoverflow.com/a/18602186/397911
    __block UIPageViewController *pvcw = pageViewController;
    [pageViewController setViewControllers:@[[self photoViewControllerForIndex:pictureIndex]]
                  direction:UIPageViewControllerNavigationDirectionForward
                   animated:animated completion:^(BOOL finished) {
                       UIPageViewController *pvcs = pvcw;
                       if (!pvcs) return;
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [pvcs setViewControllers:@[[self photoViewControllerForIndex:pictureIndex]]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:NO completion:nil];
                       });
                   }];

//    [pageViewController setViewControllers:@[[self photoViewControllerForIndex:pictureIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];    
    
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

- (void)shareAction:(id)sender
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:currentPictureIndex inSection:0];
    id picture = [dataSource objectAtIndexPath:indexPath];
    NSString *title;
    NSString *description;
    NSURL *pictureUrl;
    NSString *pictureUrlString;
    
    if ([picture isKindOfClass:[UBPicture class]]) {
        UBPicture *ubPicture = (UBPicture *)picture;
        title = [NSString stringWithFormat:@"Картинка %ld", (long)ubPicture.pictureId];
        description = ubPicture.title;
        pictureUrlString = [ubPicture.image stringByReplacingOccurrencesOfString:@"/400/" withString:@"/600/"];
        pictureUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://ukrbash.org/picture/%ld", (long)ubPicture.pictureId]];
    } else {
        Picture *cdPicture = (Picture *)picture;
        title = [NSString stringWithFormat:@"Картинка %ld", [cdPicture.pictureId longValue]];
        description = cdPicture.title;
        pictureUrlString = [cdPicture.image stringByReplacingOccurrencesOfString:@"/400/" withString:@"/600/"];
        pictureUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://ukrbash.org/picture/%ld", [cdPicture.pictureId longValue]]];
    }
    
    UIImage *image = [[MediaCenter imageCenter] imageWithUrl:pictureUrlString];

    if (description == nil) {
        description = @"";
    }
    UBVkontakteActivity *vkActivity = [[UBVkontakteActivity alloc] init];
    vkActivity.attachmentTitle = title;
    vkActivity.parentViewController = self;
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[description, pictureUrl, image] applicationActivities:@[vkActivity]];
    if (IS_IOS7) {
        activityViewController.excludedActivityTypes = @[UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact];
    } else {
        activityViewController.excludedActivityTypes = @[UIActivityTypeAssignToContact];
        
    }
    [vkActivity release];
    [activityViewController setCompletionHandler:^(NSString *activityType, BOOL completed) {
        if (IS_IOS7) {
            [self.ubNavigationController setNeedsStatusBarAppearanceUpdate];
        }
    }];
    [self presentViewController:activityViewController animated:YES completion:nil];
    [activityViewController release];
}

- (void)favoriteAction:(id)sender
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:currentPictureIndex inSection:0];

    id picture = [dataSource objectAtIndexPath:indexPath];
    NSManagedObjectContext *context = [(UkrBashAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSError *error = nil;
    BOOL shouldUpdateCurrentPictureIndex = NO;

    if ([picture isKindOfClass:[UBPicture class]]) {
        UBPicture *ubPicture = (UBPicture *)picture;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Picture" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"pictureId == %@", [NSNumber numberWithInteger:ubPicture.pictureId]];
        [fetchRequest setPredicate:predicate];

        Picture *cdPicture = nil;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        if ([fetchedObjects count] > 0) {
            cdPicture = [fetchedObjects objectAtIndex:0];
        }
        [fetchRequest release];
    
        if (!cdPicture) {
            cdPicture = [NSEntityDescription insertNewObjectForEntityForName:@"Picture" inManagedObjectContext:context];
            cdPicture.pictureId = [NSNumber numberWithInteger:ubPicture.pictureId];
            cdPicture.status = [NSNumber numberWithInteger:ubPicture.status];
            cdPicture.type = ubPicture.type;
            cdPicture.addDate = ubPicture.addDate;
            cdPicture.pubDate = ubPicture.pubDate;
            cdPicture.author = ubPicture.author;
            cdPicture.authorId = [NSNumber numberWithInteger:ubPicture.authorId];
            cdPicture.title = ubPicture.title;
            cdPicture.thumbnail = ubPicture.thumbnail;
            cdPicture.image = ubPicture.image;
            cdPicture.rating = [NSNumber numberWithInteger:ubPicture.rating];
        } else {
            // update some fileds if object already in db.
            cdPicture.status = [NSNumber numberWithInteger:ubPicture.status];
            cdPicture.pubDate = ubPicture.pubDate;
            cdPicture.rating = [NSNumber numberWithInteger:ubPicture.rating];
        }
        
        if (!ubPicture.favorite) {
            cdPicture.favorite = [NSNumber numberWithBool:YES];
            ubPicture.favorite = YES;
        } else {
            cdPicture.favorite = [NSNumber numberWithBool:NO];
            ubPicture.favorite = NO;
        }
    } else {
        Picture *cdPicture = (Picture *)picture;
        if (![cdPicture.favorite boolValue]) {
            cdPicture.favorite = [NSNumber numberWithBool:YES];
        } else {
            cdPicture.favorite = [NSNumber numberWithBool:NO];
            shouldUpdateCurrentPictureIndex = YES;
        }
    }
    
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    } else {
        if (shouldUpdateCurrentPictureIndex) {
            if ([dataSource numberOfRowsInSection:0] > 0) {
                if (currentPictureIndex < [dataSource numberOfRowsInSection:0]) {
                    [self setCurrentPictureIndex:currentPictureIndex animated:YES];
                } else {
                    [self setCurrentPictureIndex:currentPictureIndex - 1 animated:YES];
                }
            } else {
                [self backAction:nil];
            }
        } else {
            UBPicture *ubPicture = (UBPicture *)picture;
            if (ubPicture.favorite) {
                [favoriteButton setImage:[UIImage imageNamed:@"favorite-active-white"] forState:UIControlStateNormal];
            } else {
                [favoriteButton setImage:[UIImage imageNamed:@"favorite-white"] forState:UIControlStateNormal];
            }
            if (delegate) {
                [delegate updatePictureAtIndex:currentPictureIndex];
            }
        }
    }
}

- (void)tapGestureHandler:(UITapGestureRecognizer *)tapGesture
{
    if (tapGesture.numberOfTapsRequired == 1 && tapGesture.state == UIGestureRecognizerStateEnded) {
        if (toolbar.hidden) {
            toolbar.alpha = 0;
            infoView.alpha = 0;
            toolbar.hidden = NO;
            infoView.hidden = NO;
            [UIView animateWithDuration:.2
                             animations:^{
                                 toolbar.alpha = 1;
                                 infoView.alpha = 1;
                             }];
        } else {
            [UIView animateWithDuration:.2
                             animations:^{
                                 toolbar.alpha = 0;
                                 infoView.alpha = 0;
                             }
                             completion:^(BOOL finished) {
                                 toolbar.hidden = YES;
                                 infoView.hidden = YES;
                                 toolbar.alpha = 1;
                                 infoView.alpha = 1;
                             }];
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
        id picture = [dataSource objectAtIndexPath:[NSIndexPath indexPathForRow:currentPictureIndex inSection:0]];
        if ([picture isKindOfClass:[UBPicture class]]) {
            UBPicture *ubPicture = (UBPicture *)picture;
            if (ubPicture.favorite) {
                [favoriteButton setImage:[UIImage imageNamed:@"favorite-active-white"] forState:UIControlStateNormal];
            } else {
                [favoriteButton setImage:[UIImage imageNamed:@"favorite-white"] forState:UIControlStateNormal];
            }
        } else {
            [favoriteButton setImage:[UIImage imageNamed:@"favorite-active-white"] forState:UIControlStateNormal];
        }
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
    
    if (delegate) {
        [delegate userDidScroll:self toPictureAtIndex:currentPictureIndex];
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
