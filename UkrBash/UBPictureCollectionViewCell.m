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

@end
