//
//  UBPictureCollectionViewCell.m
//  UkrBash
//
//  Created by maks on 20.02.13.
//
//

#import "UBPictureCollectionViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation UBPictureCollectionViewCell
@synthesize imageView;
@synthesize authorLabel;
@synthesize ratingLabel;
@synthesize shareDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        self.contentView.layer.cornerRadius = 4.;
        self.contentView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.contentView.layer.borderWidth = .5;
        self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.contentView.layer.shadowOpacity = 0.7f;
        self.contentView.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
        self.contentView.layer.shadowRadius = 3.0f;
        self.contentView.layer.masksToBounds = NO;
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width / 2 - 200, 10, 400, 400)];
        imageView.backgroundColor = [UIColor whiteColor];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:imageView];
        
        pictureTittleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width / 2 - 200, 420, 400, 65)];
        pictureTittleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [pictureTittleLabel setLineBreakMode:UILineBreakModeWordWrap];
        [pictureTittleLabel setFont:[UIFont systemFontOfSize:18]];
        [pictureTittleLabel setNumberOfLines:0];
        [pictureTittleLabel setUserInteractionEnabled:YES];
        [pictureTittleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.contentView addSubview:pictureTittleLabel];
        
        authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, self.frame.size.height - 40, 400, 20)];
        [authorLabel setFont:[UIFont systemFontOfSize:18]];
        [authorLabel setNumberOfLines:1];
        authorLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:authorLabel];
        
        ratingLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width / 2, self.frame.size.height - 40, (self.frame.size.width - 40) / 2, 20)];
        [ratingLabel setFont:[UIFont systemFontOfSize:18]];
        [ratingLabel setNumberOfLines:1];
        [ratingLabel setTextAlignment:NSTextAlignmentRight];
        ratingLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:ratingLabel];
        
        shareButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [shareButton setBackgroundImage:[UIImage imageNamed:@"right.png"] forState:UIControlStateNormal];
        shareButton.backgroundColor = [UIColor grayColor];
//        [shareButton setTitle:@">" forState:UIControlStateNormal];
//        [shareButton.titleLabel setFont:[UIFont systemFontOfSize:22]];
//        [shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        shareButton.frame = CGRectMake(0, self.frame.size.height / 2 - 22, 22, 44);
        [shareButton addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:shareButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    imageView.frame = CGRectMake(self.frame.size.width / 2 - 200, 10, 400, 400);
}

- (void)dealloc {
    [imageView release];
    [pictureTittleLabel release];
    [authorLabel release];
    [ratingLabel release];
    [shareButton release];
    [sharingOverlay release];
    [super dealloc];
}

- (NSString *)pictureTitle
{
    return pictureTittleLabel.text;
}

- (void)setPictureTitle:(NSString *)pictureTitle
{
    pictureTittleLabel.text = pictureTitle;
}

- (void)shareButtonAction:(id)sender
{
    self.selected = !self.selected;
    if (self.selected) {
        if (!sharingOverlay) {
            sharingOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, shareButton.frame.origin.y - 5, 300, 54)];
            sharingOverlay.backgroundColor = [UIColor grayColor];
            UIButton *shareBtn = nil;
            CGFloat shareButtonWidth = 44.;
            float x = 10 + 22;
            if ([SharingController isSharingAvailableForNetworkType:SharingFacebookNetwork]) {
                shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                shareBtn.frame = CGRectMake(x, 5., shareButtonWidth, shareButtonWidth);
                shareBtn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
                [shareBtn setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateNormal];
                [shareBtn addTarget:self action:@selector(shareWithFacebookAction:) forControlEvents:UIControlEventTouchUpInside];
                [sharingOverlay addSubview:shareBtn];
                x += shareButtonWidth + 5.;
            }
            
            if ([SharingController isSharingAvailableForNetworkType:SharingTwitterNetwork]) {
                shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                shareBtn.frame = CGRectMake(x, 5., shareButtonWidth, shareButtonWidth);
                shareBtn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
                [shareBtn setImage:[UIImage imageNamed:@"twitter"] forState:UIControlStateNormal];
                [shareBtn addTarget:self action:@selector(shareWithTwitterAction:) forControlEvents:UIControlEventTouchUpInside];
                [sharingOverlay addSubview:shareBtn];
                x += shareButtonWidth + 5.;
            }
            
            if ([SharingController isSharingAvailableForNetworkType:SharingEMailNetwork]) {
                shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                shareBtn.frame = CGRectMake(x, 5., shareButtonWidth, shareButtonWidth);
                shareBtn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
                [shareBtn setImage:[UIImage imageNamed:@"gmail"] forState:UIControlStateNormal];
                [shareBtn addTarget:self action:@selector(shareWithEmailAction:) forControlEvents:UIControlEventTouchUpInside];
                [sharingOverlay addSubview:shareBtn];
                x += shareButtonWidth + 5.;
            }
            
            if ([SharingController isSharingAvailableForNetworkType:SharingVkontakteNetwork]) {
                shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                shareBtn.frame = CGRectMake(x, 5., shareButtonWidth, shareButtonWidth);
                shareBtn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
                [shareBtn setImage:[UIImage imageNamed:@"vk"] forState:UIControlStateNormal];
                [shareBtn addTarget:self action:@selector(shareWithVkontakteAction:) forControlEvents:UIControlEventTouchUpInside];
                [sharingOverlay addSubview:shareBtn];
                x += shareButtonWidth + 5.;
            }
            sharingOverlayWidth = x;
            sharingOverlay.clipsToBounds = YES;
        }
        sharingOverlay.frame = shareButton.frame;
        [self.contentView addSubview:sharingOverlay];
        [self.contentView bringSubviewToFront:shareButton];
        [UIView animateWithDuration:.3
                              delay:0.
                            options:UIViewAnimationCurveLinear
                         animations:^ {
                             sharingOverlay.frame = CGRectMake(0, shareButton.frame.origin.y - 5, sharingOverlayWidth, 54);
                             [shareButton setBackgroundImage:[UIImage imageNamed:@"left.png"] forState:UIControlStateNormal];
                         }
                         completion:NULL];

    } else {
        [UIView animateWithDuration:.4 animations:^ {
            [sharingOverlay removeFromSuperview];
            [shareButton setBackgroundImage:[UIImage imageNamed:@"right.png"] forState:UIControlStateNormal];
        }];
    }
}

- (void)shareWithFacebookAction:(id)sender
{
    if (self.shareDelegate) {
        [self.shareDelegate quoteCell:self shareQuoteWithType:SharingFacebookNetwork];
    }
}

- (void)shareWithTwitterAction:(id)sender
{
    if (self.shareDelegate) {
        [self.shareDelegate quoteCell:self shareQuoteWithType:SharingTwitterNetwork];
    }
}

- (void)shareWithEmailAction:(id)sender
{
    if (self.shareDelegate) {
        [self.shareDelegate quoteCell:self shareQuoteWithType:SharingEMailNetwork];
    }
}

- (void)shareWithVkontakteAction:(id)sender
{
    if (self.shareDelegate) {
        [self.shareDelegate quoteCell:self shareQuoteWithType:SharingVkontakteNetwork];
    }
}

- (void)hideSharingOverlay
{
    if (sharingOverlay) {
        [sharingOverlay removeFromSuperview];
        [shareButton setBackgroundImage:[UIImage imageNamed:@"right.png"] forState:UIControlStateNormal];
    }
}

- (void)showSharingOverlay
{
    [self.contentView addSubview:sharingOverlay];
    [self.contentView bringSubviewToFront:shareButton];
}

@end
