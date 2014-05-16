//
//  UBPictureInfoView.m
//  UkrBash
//
//  Created by Михаил Гребенкин on 29.03.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "UBPictureInfoView.h"
#import <QuartzCore/QuartzCore.h>
#import "UBQuoteCell.h"

#define UBPictureInfoViewPadding 4.

@implementation UBPictureInfoView

@synthesize idLabel;
@synthesize ratingLabel;
@synthesize textLabel;
@synthesize authorLabel;
@synthesize dateLabel;

+ (CGFloat)preferedHeightForQuoteText:(NSString*)text viewWidth:(CGFloat)width
{
    CGSize constraint = CGSizeMake(width, MAXFLOAT);
    CGSize size;

    if (IS_IOS7) {
        NSDictionary *attributes = @{NSFontAttributeName:GET_FONT()};
        NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
        [context setMinimumScaleFactor:1];
        CGRect rect = [text boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:context];
        size.width = ceilf(rect.size.width);
        size.height  = ceilf(rect.size.height);
        [context release];
    } else {
        size = [text sizeWithFont:GET_FONT() constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    }
    CGFloat height = MAX(size.height, UBPictureInfoViewPadding * 2);

    return height + 16 * 2;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:0. alpha:.6];
        self.layer.cornerRadius = 5.;
        
        idLabel = [[UILabel alloc] initWithFrame:CGRectMake(UBPictureInfoViewPadding, UBPictureInfoViewPadding, (self.frame.size.width - 2 * UBPictureInfoViewPadding) / 2., 12.)];
        idLabel.font = [UIFont systemFontOfSize:10];
        idLabel.backgroundColor = [UIColor clearColor];
        idLabel.textColor = [UIColor lightGrayColor];
        [self addSubview:idLabel];
        
        ratingLabel = [[UILabel alloc] initWithFrame:CGRectMake(idLabel.frame.origin.x + idLabel.frame.size.width, idLabel.frame.origin.y, idLabel.frame.size.width, idLabel.frame.size.height)];
        ratingLabel.font = idLabel.font;
        ratingLabel.backgroundColor = [UIColor clearColor];
        ratingLabel.textColor = [UIColor lightGrayColor];
        ratingLabel.textAlignment = NSTextAlignmentRight;
        ratingLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:ratingLabel];
        
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(idLabel.frame.origin.x, idLabel.frame.origin.y + idLabel.frame.size.height, self.frame.size.width - 2 * UBPictureInfoViewPadding, self.frame.size.height - 2 * UBPictureInfoViewPadding - 2 * idLabel.frame.size.height)];
        textLabel.font = GET_FONT();
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textColor = [UIColor whiteColor];
        textLabel.numberOfLines = 0;
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:textLabel];
        
        authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(idLabel.frame.origin.x, textLabel.frame.origin.y + textLabel.frame.size.height, idLabel.frame.size.width, idLabel.frame.size.height)];
        authorLabel.font = idLabel.font;
        authorLabel.backgroundColor = [UIColor clearColor];
        authorLabel.textColor = [UIColor lightGrayColor];
        [self addSubview:authorLabel];
        
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(ratingLabel.frame.origin.x, authorLabel.frame.origin.y, ratingLabel.frame.size.width, authorLabel.frame.size.height)];
        dateLabel.font = idLabel.font;
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.textColor = [UIColor lightGrayColor];
        dateLabel.textAlignment = NSTextAlignmentRight;
        dateLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:dateLabel];
    }
    return self;
}

- (void)dealloc
{
    [idLabel release];
    [ratingLabel release];
    [textLabel release];
    [authorLabel release];
    [dateLabel release];
    [super dealloc];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    authorLabel.frame = CGRectMake(idLabel.frame.origin.x, textLabel.frame.origin.y + textLabel.frame.size.height, idLabel.frame.size.width, idLabel.frame.size.height);
    dateLabel.frame = CGRectMake(ratingLabel.frame.origin.x, authorLabel.frame.origin.y, ratingLabel.frame.size.width, authorLabel.frame.size.height);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
