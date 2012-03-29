//
//  UBPictureInfoView.m
//  UkrBash
//
//  Created by Михаил Гребенкин on 29.03.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "UBPictureInfoView.h"
#import <QuartzCore/QuartzCore.h>

@implementation UBPictureInfoView

@synthesize idLabel;
@synthesize ratingLabel;
@synthesize textLabel;
@synthesize authorLabel;
@synthesize dateLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:0. alpha:.6];
        self.layer.cornerRadius = 5.;
        
        CGFloat padding = 4.;
        idLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, padding, (self.frame.size.width - 2 * padding) / 2., 12.)];
        idLabel.font = [UIFont systemFontOfSize:10];
        idLabel.backgroundColor = [UIColor clearColor];
        idLabel.textColor = [UIColor lightGrayColor];
        [self addSubview:idLabel];
        
        ratingLabel = [[UILabel alloc] initWithFrame:CGRectMake(idLabel.frame.origin.x + idLabel.frame.size.width, padding, idLabel.frame.size.width, idLabel.frame.size.height)];
        ratingLabel.font = idLabel.font;
        ratingLabel.backgroundColor = [UIColor clearColor];
        ratingLabel.textColor = [UIColor lightGrayColor];
        ratingLabel.textAlignment = UITextAlignmentRight;
        ratingLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:ratingLabel];
        
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, idLabel.frame.origin.y + idLabel.frame.size.height, self.frame.size.width - 2 * padding, self.frame.size.height - 2 * padding - 2 * idLabel.frame.size.height)];
        textLabel.font = [UIFont systemFontOfSize:12.];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textColor = [UIColor whiteColor];
        textLabel.numberOfLines = 0;
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:textLabel];
        
        authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, textLabel.frame.origin.y + textLabel.frame.size.height, idLabel.frame.size.width, idLabel.frame.size.height)];
        authorLabel.font = idLabel.font;
        authorLabel.backgroundColor = [UIColor clearColor];
        authorLabel.textColor = [UIColor lightGrayColor];
        [self addSubview:authorLabel];
        
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(ratingLabel.frame.origin.x, authorLabel.frame.origin.y, ratingLabel.frame.size.width, authorLabel.frame.size.height)];
        dateLabel.font = idLabel.font;
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.textColor = [UIColor lightGrayColor];
        dateLabel.textAlignment = UITextAlignmentRight;
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
