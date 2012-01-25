//
//  UBQuoteCell.m
//  UkrBash
//
//  Created by Maks Markovets on 23.12.11.
//  Copyright (c) 2011 smile2mobile. All rights reserved.
//

#import "UBQuoteCell.h"
#import <QuartzCore/QuartzCore.h>

#define FONT_SIZE 12.0f
#define CELL_CONTENT_MARGIN 5.0f

@implementation UBQuoteCell

@synthesize quoteTextLabel;
@synthesize shareButtonsVisible;

+ (CGFloat)heightForQuoteText:(NSString*)text viewWidth:(CGFloat)width
{
    CGSize constraint = CGSizeMake((width - 20.) - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat height = MAX(size.height, 44.0f);
    
    return height + (CELL_CONTENT_MARGIN * 2) + (CELL_CONTENT_MARGIN * 2);
}

- (void)shareWithFacebookAction:(id)sender
{
    
}

- (void)shareWithTwitterAction:(id)sender
{
    
}

- (void)shareWithEmailAction:(id)sender
{
    
}

- (void)hideShareButtons
{
    [UIView animateWithDuration:.4 animations:^(void) {
        CGRect rect = containerView.frame;
        rect.origin.x = self.bounds.origin.x + 15;
        containerView.frame = rect;
    } completion:^(BOOL finished) {
        shareButtonsVisible = NO;
    }];
}

- (void)showShareButtons
{
    [UIView animateWithDuration:.4 animations:^(void) {
        CGRect rect = containerView.frame;
        rect.origin.x = self.bounds.origin.x + 15 + 160.;
        containerView.frame = rect;
    } completion:^(BOOL finished) {
        shareButtonsVisible = YES;
    }];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGRect rect = self.bounds;
        rect.origin.x += 15;
        rect.origin.y += 5;
        rect.size.width -= 20;
        rect.size.height -= 10;
        containerView = [[UIView alloc] initWithFrame:rect];
        containerView.layer.cornerRadius = 4.;
        containerView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        containerView.layer.borderWidth = .5;
        containerView.layer.shadowColor = [UIColor blackColor].CGColor;
        containerView.layer.shadowOpacity = 0.7f;
        containerView.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
        containerView.layer.shadowRadius = 3.0f;
        containerView.layer.masksToBounds = NO;
        containerView.backgroundColor = [UIColor whiteColor];
        
        quoteTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(5., 5., containerView.frame.size.width - 10, containerView.frame.size.height - 10)];
        [quoteTextLabel setLineBreakMode:UILineBreakModeWordWrap];
        [quoteTextLabel setFont:[UIFont systemFontOfSize:FONT_SIZE]];
        [quoteTextLabel setNumberOfLines:0];
        [quoteTextLabel setUserInteractionEnabled:YES];
        [quoteTextLabel setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [containerView addSubview:quoteTextLabel];
        
        CGFloat x = containerView.frame.origin.x + 20.;
        CGFloat shareButtonWidth = 32.;
        UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        shareBtn.frame = CGRectMake(x, 10., shareButtonWidth, shareButtonWidth);
        shareBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [shareBtn setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateNormal];
        [shareBtn addTarget:self action:@selector(shareWithFacebookAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:shareBtn];
        x += shareButtonWidth + 10.;

        shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        shareBtn.frame = CGRectMake(x, 10., shareButtonWidth, shareButtonWidth);
        shareBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [shareBtn setImage:[UIImage imageNamed:@"twitter"] forState:UIControlStateNormal];
        [shareBtn addTarget:self action:@selector(shareWithTwitterAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:shareBtn];
        x += shareButtonWidth + 10.;
        
        shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        shareBtn.frame = CGRectMake(x, 10., shareButtonWidth, shareButtonWidth);
        shareBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [shareBtn setImage:[UIImage imageNamed:@"gmail"] forState:UIControlStateNormal];
        [shareBtn addTarget:self action:@selector(shareWithEmailAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:shareBtn];
        
        [self.contentView addSubview:containerView];
    }
    return self;
}

- (void)dealloc
{
    [containerView release];
    [quoteTextLabel release];
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    if (selected) {
        containerView.layer.borderWidth = 1.;
        containerView.layer.borderColor = [[UIColor colorWithRed:.04 green:.6 blue:.97 alpha:1.] CGColor];
    } else {
        containerView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        containerView.layer.borderWidth = .5;
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    shareButtonsVisible = NO;
}

- (void)layoutSubviews
{
    CGRect rect = self.bounds;
    rect.origin.x += 15;
    rect.origin.y += 5;
    rect.size.width -= 20;
    rect.size.height -= 10;
    containerView.frame = rect;

    CGSize size = containerView.bounds.size;
    CGFloat curlFactor = 7.0f;
    CGFloat shadowDepth = 3.0f;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0.0f, 0.0f)];
    [path addLineToPoint:CGPointMake(size.width, 0.0f)];
    [path addLineToPoint:CGPointMake(size.width, size.height + shadowDepth)];
    [path addCurveToPoint:CGPointMake(0.0f, size.height + shadowDepth)
            controlPoint1:CGPointMake(size.width - curlFactor, size.height + shadowDepth - curlFactor)
            controlPoint2:CGPointMake(curlFactor, size.height + shadowDepth - curlFactor)];
    containerView.layer.shadowPath = path.CGPath;
}

@end
