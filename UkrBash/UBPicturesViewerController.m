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

- (void)updatePicture
{
    UBPicture *picture = [[dataSource items] objectAtIndex:pictureIndex];
    UIImage *img = [[MediaCenter imageCenter] imageWithUrl:picture.image];
    if (!img) {
        imageView.image = [[MediaCenter imageCenter] imageWithUrl:picture.thumbnail];
    } else {
        imageView.image = img;
    }
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
    
    imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.backgroundColor = [UIColor blackColor];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    
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
                imageView.image = [[MediaCenter imageCenter] imageWithUrl:url];
                break;
            } else if (!imageView.image && [url isEqualToString:picture.thumbnail]) {
                imageView.image = [[MediaCenter imageCenter] imageWithUrl:url];
            }
        }
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

@end
