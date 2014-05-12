//
//  UBPictureCollectionViewCell.m
//  UkrBash
//
//  Created by Maks Markovets on 08.05.14.
//
//

#import "UBPictureCollectionViewCell.h"

@implementation UBPictureCollectionViewCell

@synthesize imageView;
@synthesize authorLabel;
@synthesize ratingLabel;
@synthesize dateLabel;
@synthesize favoriteButton;
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
        
        float imageWidth = self.frame.size.width;
        
        authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, (self.frame.size.width - 20) / 2, 20)];
        [authorLabel setFont:[UIFont systemFontOfSize:14]];
        [authorLabel setNumberOfLines:1];
        authorLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:authorLabel];
        
        ratingLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width / 2, authorLabel.frame.origin.y, (self.frame.size.width - 20) / 2, 20)];
        [ratingLabel setFont:[UIFont systemFontOfSize:14]];
        [ratingLabel setNumberOfLines:1];
        [ratingLabel setTextAlignment:NSTextAlignmentRight];
        ratingLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:ratingLabel];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 40, imageWidth - 4, imageWidth - 4)];
        imageView.backgroundColor = [UIColor lightGrayColor];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self.contentView addSubview:imageView];
        
        pictureTittleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, imageWidth + 40 - 65, imageWidth-4, 65)];
        pictureTittleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [pictureTittleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        if (IS_IOS7) {
            [pictureTittleLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
        } else {
            [pictureTittleLabel setFont:[UIFont systemFontOfSize:18]];
        }
        [pictureTittleLabel setNumberOfLines:0];
        [pictureTittleLabel setUserInteractionEnabled:YES];
        [pictureTittleLabel setTextAlignment:NSTextAlignmentCenter];
        [pictureTittleLabel setTextColor:[UIColor whiteColor]];
        
        
        CAGradientLayer *maskLayer = [CAGradientLayer layer];
        
        CGColorRef outerColor = [UIColor colorWithWhite:0. alpha:0.0].CGColor;
        CGColorRef innerColor = [UIColor colorWithWhite:0. alpha:1.0].CGColor;
        
        maskLayer.colors = [NSArray arrayWithObjects:(id)outerColor,
                            (id)innerColor, nil];
        maskLayer.frame = pictureTittleLabel.frame;
        [self.contentView.layer insertSublayer:maskLayer atIndex:3];
        [self.contentView.layer insertSublayer:maskLayer above:imageView.layer];
        [self.contentView addSubview:pictureTittleLabel];
        
        
        favoriteButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        favoriteButton.frame = CGRectMake(10., self.frame.size.height - 30, 20, 20);
        [favoriteButton setImage:[UIImage imageNamed:@"favorite"] forState:UIControlStateNormal];
        [favoriteButton addTarget:self action:@selector(favoriteAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:favoriteButton];
        
        
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width / 2, self.frame.size.height - 30, (self.frame.size.width - 20) / 2, 20)];
        dateLabel.font = [UIFont systemFontOfSize:14];
        dateLabel.numberOfLines = 1;
        dateLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:dateLabel];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    float imageWidth = self.frame.size.width;
    imageView.frame = CGRectMake(2, 40, imageWidth - 4, imageWidth - 4);
}

- (void)dealloc {
    [imageView release];
    [pictureTittleLabel release];
    [authorLabel release];
    [ratingLabel release];
    [dateLabel release];
    [favoriteButton release];
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

- (void)copyUrlAction:(id)sender
{
    if (self.shareDelegate) {
        [self.shareDelegate copyUrlActionForCell:self];
    }
}

- (void)openInBrowserAction:(id)sender
{
    if (self.shareDelegate) {
        [self.shareDelegate openInBrowserActionForCell:self];
    }
}

- (void)favoriteAction:(id)sender
{
    if (self.shareDelegate) {
        [self.shareDelegate favoriteActionForCell:self];
    }
}

@end
