//
//  UBPictureViewController.m
//  UkrBash
//
//  Created by Maks Markovets on 13.05.14.
//
//

#import "UBPictureViewController.h"
#import "MediaCenter/MediaCenter.h"

@implementation UBPictureViewController

- (void)dealloc
{
    [scrollView release];
    [imageView release];
    [_imageUrl release];
    [_fullScreenImageUrl release];
    [super dealloc];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure self's view
    // setting self.view frame size same as parent's view controller view size.
    self.view.frame = self.parentViewController.view.frame;
    self.view.backgroundColor = [UIColor blackColor];
    
    // Configure subviews
    scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.delegate = self;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:scrollView];
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.contentMode = UIViewContentModeCenter;
    [scrollView addSubview:imageView];
    UIImage *image = [[MediaCenter imageCenter] imageWithUrl:self.fullScreenImageUrl andCompletion:^(UIImage *loadedImage){
        imageView.image = loadedImage;
        [self updateScrollAndImage];
    }];
    if (image) {
        imageView.image = image;
        [self updateScrollAndImage];
    }
}

- (void)updateScrollAndImage
{
    CGRect newFrame = imageView.frame;
    newFrame.size.width = imageView.image.size.width;
    newFrame.size.height = imageView.image.size.height;
    imageView.frame = newFrame;
    
    [scrollView setContentSize:imageView.frame.size];
    [self adjustScrollViewAnimated:NO];
}

#pragma mark - UIScrollViewDelegate methods.

- (void)scrollViewDidZoom:(UIScrollView *)aScrollView
{
	CGFloat w = MAX((scrollView.frame.size.width - scrollView.contentSize.width) / 2, 0);
	CGFloat h = MAX((scrollView.frame.size.height - scrollView.contentSize.height) / 2, 0);
    
    scrollView.contentInset = UIEdgeInsetsMake(h, w, h, w);
 }

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}

- (CGRect)zommRectWithScale:(float)scale andCenter:(CGPoint)center
{
    CGRect zoomRect;
    
    // The zoom rect is in the content view's coordinates.
    // At a zoom scale of 1.0, it would be the size of the
    // imageScrollView's bounds.
    // As the zoom scale decreases, so more content is visible,
    // the size of the rect grows.
    zoomRect.size.height = scrollView.frame.size.height / scale;
    zoomRect.size.width  = scrollView.frame.size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

#pragma mark -

- (void)doubleTapAtPoint:(CGPoint)point
{
	if (scrollView.zoomScale != scrollView.minimumZoomScale) {
		[scrollView setZoomScale:scrollView.minimumZoomScale animated:YES];
	} else {
		float newScale = scrollView.maximumZoomScale;
        
        // translate parent's view touch location to imageView location.
        CGFloat touchX = point.x;
        CGFloat touchY = point.y;
        touchX *= 1 / scrollView.zoomScale;
        touchY *= 1 / scrollView.zoomScale;
        touchX += scrollView.contentOffset.x;
        touchY += scrollView.contentOffset.y;
        
        CGRect zoomRect = [self zommRectWithScale:newScale andCenter:CGPointMake(touchX, touchY)];
        [scrollView zoomToRect:zoomRect animated:YES];
	}
}

- (void)zoomOutIfNeeded
{
	if (scrollView.zoomScale != scrollView.minimumZoomScale) {
        [scrollView setZoomScale:scrollView.minimumZoomScale animated:NO];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self adjustScrollViewAnimated:YES];
}

- (void)adjustScrollViewAnimated:(BOOL)animated
{
    if (imageView.image == nil) {
        return;
    }
    scrollView.maximumZoomScale = 1.0;
    if (IS_PAD) {
        scrollView.maximumZoomScale = 2.0;
    }
	CGFloat wScale = scrollView.frame.size.width / imageView.image.size.width;
	CGFloat hScale = scrollView.frame.size.height / imageView.image.size.height;
    CGFloat minScale = MIN(wScale, hScale);
    
    if (wScale >= 1 && hScale >= 1) {
		minScale = 1.0;
	}
	scrollView.minimumZoomScale = minScale;
    [scrollView setZoomScale:scrollView.minimumZoomScale animated:animated];
    
    CGFloat w = MAX((scrollView.frame.size.width - scrollView.contentSize.width) / 2, 0);
	CGFloat h = MAX((scrollView.frame.size.height - scrollView.contentSize.height) / 2, 0);
    scrollView.contentInset = UIEdgeInsetsMake(h, w, h, w);
}

@end
