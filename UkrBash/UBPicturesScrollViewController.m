//
//  UBPicturesScrollViewControllerViewController.m
//  UkrBash
//
//  Created by Maks Markovets on 05.07.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "UBPicturesScrollViewController.h"
#import "UBPictureView.h"
#import "UBPicture.h"
#import "MediaCenter.h"
#import <Twitter/Twitter.h>
#import <MessageUI/MessageUI.h>
#import "ShareManager.h"
#import "UkrBashAppDelegate.h"

@interface UBPicturesScrollViewController ()

- (void)setCurrentPictureIndex:(NSInteger)newIndex;

@end

@implementation UBPicturesScrollViewController

- (id)initWithDataSource:(UBPicturesDataSource *)aDataSource andStartPictureIndex:(NSInteger)startIndex
{
    if (self = [super init]) {
        dataSource = [aDataSource retain];
        currentPictureIndex = startIndex;
    }
    return self;
}

- (void)dealloc
{
    [dataSource release];
    [scrollView release];
    [pictureViews release];
    [infoView release];
    [toolbar release];
    [backButton release];
    [super dealloc];
}

- (void)scrollToIndex:(NSInteger)index 
{
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * index;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:NO];
}

- (void)setScrollViewContentSize
{
    NSInteger pageCount = [[dataSource items] count];
    if (pageCount == 0) {
        pageCount = 1;
    }
    
    CGSize size = CGSizeMake(scrollView.frame.size.width * pageCount, 
                             scrollView.frame.size.height);
    [scrollView setContentSize:size];
}

- (void)loadView
{
    [super loadView];
    
    scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [scrollView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [scrollView setDelegate:self];
    [scrollView setBackgroundColor:[UIColor blackColor]];
    [scrollView setAutoresizesSubviews:YES];
    [scrollView setPagingEnabled:YES];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [self.view addSubview:scrollView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    tapGesture.numberOfTapsRequired = 1;
    [scrollView addGestureRecognizer:tapGesture];
    [tapGesture release];
 
    CGFloat padding = 10.;
    infoView = [[UBPictureInfoView alloc] initWithFrame:CGRectMake(padding, self.view.frame.size.height - padding - 60., self.view.frame.size.width - 2 * padding, 60.)];
    infoView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:infoView];
    
    CGFloat sharingButtonHeight = 32.;
    padding = 10.;
    toolbar = [[UIView alloc] initWithFrame:CGRectMake(0., 0., self.view.frame.size.width, padding + sharingButtonHeight)];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    toolbar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:toolbar];
    
    CGFloat x = padding, y = padding;
    backButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    backButton.frame = CGRectMake(x, y, sharingButtonHeight, sharingButtonHeight);
    [backButton setImage:[UIImage imageNamed:@"back-btn"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:backButton];
    padding += 10.;
    x += sharingButtonHeight + padding;
    
    UIButton *fbButton = [UIButton buttonWithType:UIButtonTypeCustom];
    fbButton.frame = CGRectMake(x, y, sharingButtonHeight, sharingButtonHeight);
    [fbButton setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateNormal];
    [fbButton addTarget:self action:@selector(fbShareAction:) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:fbButton];
    x += sharingButtonHeight + padding;
    
    if ([TWTweetComposeViewController canSendTweet]) {
        UIButton *twButton = [UIButton buttonWithType:UIButtonTypeCustom];
        twButton.frame = CGRectMake(x, y, sharingButtonHeight, sharingButtonHeight);
        [twButton setImage:[UIImage imageNamed:@"twitter"] forState:UIControlStateNormal];
        [twButton addTarget:self action:@selector(twShareAction:) forControlEvents:UIControlEventTouchUpInside];
        [toolbar addSubview:twButton];
        x += sharingButtonHeight + padding;
    }
    
    if ([MFMailComposeViewController canSendMail]) {
        UIButton *mailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        mailButton.frame = CGRectMake(x, y, sharingButtonHeight, sharingButtonHeight);
        [mailButton setImage:[UIImage imageNamed:@"gmail"] forState:UIControlStateNormal];
        [mailButton addTarget:self action:@selector(mailShareAction:) forControlEvents:UIControlEventTouchUpInside];
        [toolbar addSubview:mailButton];
        x += sharingButtonHeight + padding;
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setScrollViewContentSize];
    
    NSInteger picturesCount = [[dataSource items] count];
    pictureViews = [[NSMutableArray alloc] initWithCapacity:picturesCount];
    for (int i = 0; i < picturesCount; i++) {
        [pictureViews addObject:[NSNull null]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kImageCenterNotification_didLoadImage object:nil queue:nil usingBlock:^(NSNotification *note) {
        
        for (NSString *url in [[note userInfo] objectForKey:@"imageUrl"]) {
            for (id pictureView in pictureViews) {
                if ([pictureView isKindOfClass:[UBPictureView class]]) {
                    if ([url isEqualToString:[pictureView imageUrl]]) {
                        [pictureView setImage:[[MediaCenter imageCenter] imageWithUrl:url]];
                    } else if (![pictureView getImage] && [url isEqualToString:[pictureView thumbnailUrl]]) {
                        [pictureView setImage:[[MediaCenter imageCenter] imageWithUrl:url]];
                    }
                }
            }
        }
    }];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [pictureViews release], pictureViews = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setScrollViewContentSize];
    [self setCurrentPictureIndex:currentPictureIndex];
    [self scrollToIndex:currentPictureIndex];
}

#pragma mark -
#pragma mark Rotation Magic

- (void)layoutScrollViewSubviews
{
    [self setScrollViewContentSize];
    
    NSArray *subviews = [scrollView subviews];
    
    for (UBPictureView *pictureView in subviews) {
        [pictureView setFrame:[self frameForPageAtIndex:[pictureView index]]];
    }
    
    [self scrollToIndex:pictureIndexBeforeRotation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                duration:(NSTimeInterval)duration 
{
    pictureIndexBeforeRotation = currentPictureIndex;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration 
{
    [self layoutScrollViewSubviews];
}

#pragma mark - Actions

- (void)tapGestureHandler:(UITapGestureRecognizer *)tapGesture
{
    if (toolbar.hidden) {
        toolbar.hidden = NO;
        infoView.hidden = NO;
    } else {
        toolbar.hidden = YES;
        infoView.hidden = YES;
    }
}

- (void)backAction:(id)sender
{
    [UIView animateWithDuration:.3
                     animations:^{
                         self.view.alpha = 0.;
                     }
                     completion:^(BOOL finished) {
                         [self.view removeFromSuperview];
                     }];
}

- (void)fbShareAction:(id)sender
{
    UBPicture *picture = [[dataSource items] objectAtIndex:currentPictureIndex];
    NSString *pictureUrl = [NSString stringWithFormat:@"http://ukrbash.org/picture/%d", picture.pictureId];
    
    FacebookSharer *fbSharer = [[ShareManager sharedInstance] createFacebookSharer];
    UkrBashAppDelegate *delegate = (UkrBashAppDelegate *) [[UIApplication sharedApplication] delegate];
    delegate.facebook = fbSharer.facebook;
        
    [fbSharer shareUrl:pictureUrl withMessage:nil];
}

- (void)twShareAction:(id)sender
{
    UBPicture *picture = [[dataSource items] objectAtIndex:currentPictureIndex];
    NSString *pictureUrl = [NSString stringWithFormat:@"http://ukrbash.org/picture/%d", picture.pictureId];
    TwitterSharer *twitterSharer = [[ShareManager sharedInstance] createTwitterSharerWithViewController:self];
    [twitterSharer shareUrl:pictureUrl withMessage:picture.title];
}

- (void)mailShareAction:(id)sender
{
    UBPicture *picture = [[dataSource items] objectAtIndex:currentPictureIndex];
    NSString *pictureUrl = [NSString stringWithFormat:@"http://ukrbash.org/picture/%d", picture.pictureId];    
    EMailSharer *emailSharer = [[ShareManager sharedInstance] createEmailSharerWithViewController:self];
    [emailSharer shareUrl:pictureUrl withMessage:picture.title];
}

#pragma mark -

- (void)setCurrentPictureIndex:(NSInteger)newIndex
{
    currentPictureIndex = newIndex;
    
    [self loadPictureWithIndex:currentPictureIndex];
    [self loadPictureWithIndex:currentPictureIndex + 1];
    [self loadPictureWithIndex:currentPictureIndex - 1];
    [self unloadPictureWithIndex:currentPictureIndex + 2];
    [self unloadPictureWithIndex:currentPictureIndex - 2];
    
    if (currentPictureIndex >= 0 && currentPictureIndex < [[dataSource items] count]) {
        [dataSource configurePictureInfoView:infoView forRowAtIndexPath:[NSIndexPath indexPathForRow:currentPictureIndex inSection:0]];
    }
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index 
{
    // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
    // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
    // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
    // because it has a rotation transform applied.
    CGRect bounds = [scrollView bounds];
    CGRect pageFrame = bounds;
//    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (bounds.size.width * index);// + PADDING;
    return pageFrame;
}

- (void)loadPictureWithIndex:(NSInteger)index
{
    if (index < 0 || index >= [[dataSource items] count]) {
        return;
    }
    
    id currentPictureView = [pictureViews objectAtIndex:index];
    if (NO == [currentPictureView isKindOfClass:[UBPictureView class]]) {
        // Load the photo view.
        CGRect frame = [self frameForPageAtIndex:index];
        UBPictureView *pictureView = [[UBPictureView alloc] initWithFrame:frame];
        [pictureView setScroller:self];
        [pictureView setBackgroundColor:[UIColor clearColor]];
        
        // Set the picture image.
        
        UBPicture *picture = [[dataSource items] objectAtIndex:index];
        
        [pictureView setImageUrl:picture.image];
        [pictureView setThumbnailUrl:picture.thumbnail];
        [pictureView setIndex:index];
        
        UIImage *image = [[MediaCenter imageCenter] imageWithUrl:picture.image];
        
        if (image) {
            [pictureView setImage:image];
        } else {
            [pictureView setImage:[[MediaCenter imageCenter] imageWithUrl:picture.thumbnail]];
        }
        
    
        [scrollView addSubview:pictureView];
        [pictureViews replaceObjectAtIndex:index withObject:pictureView];
        [pictureView release];
    } 
}

- (void)unloadPictureWithIndex:(NSInteger)index
{
    if (index < 0 || index >= [[dataSource items] count]) {
        return;
    }
    
    id currentPictureView = [pictureViews objectAtIndex:index];
    if ([currentPictureView isKindOfClass:[UBPictureView class]]) {
        [currentPictureView removeFromSuperview];
        [pictureViews replaceObjectAtIndex:index withObject:[NSNull null]];
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView 
{
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = floor(fractionalPage);
	if (page != currentPictureIndex) {
		[self setCurrentPictureIndex:page];
	}
}

@end
