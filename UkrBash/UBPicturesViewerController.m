//
//  UBPicturesViewerControllerViewController.m
//  UkrBash
//
//  Created by Михаил Гребенкин on 21.03.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "UBPicturesViewerController.h"
#import <QuartzCore/QuartzCore.h>
#import "MediaCenter.h"
#import "UBPicture.h"
#import <Twitter/Twitter.h>
#import <MessageUI/MessageUI.h>

@interface UBPicturesViewerController ()

@end

@implementation UBPicturesViewerController

@synthesize pictureIndex;

- (void)updateZoom
{
    if (!imageView.image) {
        return;
    }
    scrollView.zoomScale = 1.;

    CGFloat width = imageView.image.size.width;
    CGFloat height = imageView.image.size.height;
    CGFloat minZoomScale = 0;
    CGFloat x = 0;
    CGFloat y = 0;
    if (width > scrollView.frame.size.width) {
        minZoomScale = scrollView.frame.size.width / width;
        y = (scrollView.frame.size.height - height) / 2.;
    } else if (height > scrollView.frame.size.height) {
        minZoomScale = scrollView.frame.size.height / height;
        x = (scrollView.frame.size.width - width) / 2.;
    } else {
        y = (scrollView.frame.size.height - height) / 2.;
        x = (scrollView.frame.size.width - width) / 2.;
        minZoomScale = 1.;
    }
    imageView.frame = CGRectMake(x, y, width, height);
    scrollView.contentSize = CGSizeMake(MAX(width, scrollView.frame.size.width), MAX(height, scrollView.frame.size.height));
    
    scrollView.maximumZoomScale = 1.;
    scrollView.minimumZoomScale = minZoomScale;
    scrollView.zoomScale = minZoomScale;
}

- (void)updatePicture
{
    UBPicture *picture = [[dataSource items] objectAtIndex:pictureIndex];
    UIImage *img = [[MediaCenter imageCenter] imageWithUrl:picture.image];
    if (!img) {
        imageView.image = [[MediaCenter imageCenter] imageWithUrl:picture.thumbnail];
    } else {
        imageView.image = img;
    }
    [self updateZoom];
    [dataSource configurePictureInfoView:infoView forRowAtIndexPath:[NSIndexPath indexPathForRow:pictureIndex inSection:0]];
}

- (void)setPictureIndex:(NSInteger)newIndex
{
    pictureIndex = newIndex;
    if (imageView.image) {
        [self updatePicture];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithDataSource:(UBPicturesDataSource *)_dataSource currentIndex:(NSInteger)index
{
    self = [super init];
    if (self) {
        dataSource = [_dataSource retain];
        pictureIndex = index;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kImageCenterNotification_didLoadImage object:nil];
    [dataSource release];
    [infoView release];
    [scrollView release];
    [backButton release], backButton = nil;
    [imageView release], imageView = nil;
    [super dealloc];
}

#pragma mark - Actions

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
    
}

- (void)twShareAction:(id)sender
{
    
}

- (void)mailShareAction:(id)sender
{
    
}

- (void)tapGestureHandler:(UITapGestureRecognizer*)tapGesture
{
    if (toolbar.hidden) {
        toolbar.hidden = NO;
        infoView.hidden = NO;
    } else {
        toolbar.hidden = YES;
        infoView.hidden = YES;
    }
}

- (void)doubleTapGestureHandler:(UITapGestureRecognizer*)tapGesture
{
    if (scrollView.zoomScale == scrollView.minimumZoomScale) {
        [scrollView setZoomScale:scrollView.maximumZoomScale animated:YES];
    } else {
        [scrollView setZoomScale:scrollView.minimumZoomScale animated:YES];
    }
}

#pragma mark - View life circle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    
    scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView.backgroundColor = [UIColor blackColor];
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureHandler:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [scrollView addGestureRecognizer:doubleTapGesture];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    tapGesture.numberOfTapsRequired = 1;
    [tapGesture requireGestureRecognizerToFail:doubleTapGesture];
    [scrollView addGestureRecognizer:tapGesture];
    [tapGesture release];
    [doubleTapGesture release];
    
    imageView = [[UIImageView alloc] initWithFrame:scrollView.bounds];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.backgroundColor = [UIColor blackColor];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [scrollView addSubview:imageView];
    
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kImageCenterNotification_didLoadImage object:nil];

    [scrollView release], scrollView = nil;
    [infoView release], infoView = nil;
    [backButton release], backButton = nil;
    [imageView release], imageView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kImageCenterNotification_didLoadImage object:nil queue:nil usingBlock:^(NSNotification *note) {
        UBPicture *picture = [[dataSource items] objectAtIndex:pictureIndex];
        for (NSString *url in [[note userInfo] objectForKey:@"imageUrl"]) {
            if ([url isEqualToString:picture.image]) {
                [self updatePicture];
                break;
            } else if (!imageView.image && [url isEqualToString:picture.thumbnail]) {
                [self updatePicture];
            }
        }
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self updateZoom];
    }];
    
    if (!imageView.image) {
        [self updatePicture];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kImageCenterNotification_didLoadImage object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Scroll View delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}

@end
