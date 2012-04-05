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
    
    imageView = [[UIImageView alloc] initWithFrame:scrollView.bounds];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.backgroundColor = [UIColor blackColor];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [scrollView addSubview:imageView];
    
    CGFloat padding = 10.;
    infoView = [[UBPictureInfoView alloc] initWithFrame:CGRectMake(padding, self.view.frame.size.height - padding - 60., self.view.frame.size.width - 2 * padding, 60.)];
    infoView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:infoView];

    padding = 10.;
    backButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    backButton.frame = CGRectMake(padding, padding, 30., 30.);
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
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
