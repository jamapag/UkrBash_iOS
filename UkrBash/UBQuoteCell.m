//
//  UBQuoteCell.m
//  UkrBash
//
//  Created by Maks Markovets on 23.12.11.
//  Copyright (c) 2011 smile2mobile. All rights reserved.
//

#import "UBQuoteCell.h"
#import <QuartzCore/QuartzCore.h>

#define FONT_SIZE 14.0f
#define INFO_LABELS_HEIGHT 12.0f

CGFloat animationOffset = 52.;

@implementation UBQuoteCell

@synthesize quoteTextLabel;
@synthesize ratingLabel;
@synthesize dateLabel;
@synthesize authorLabel;
@synthesize idLabel;
@synthesize shareButtonsVisible;
@synthesize shareDelegate;

+ (CGFloat)heightForQuoteText:(NSString*)text viewWidth:(CGFloat)width
{
    CGSize constraint = CGSizeMake((width - 20.) - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat height = MAX(size.height, 44.0f);
    
    return height + (CELL_CONTENT_MARGIN * 4) + INFO_LABELS_HEIGHT * 2;
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
        rect.origin.x = self.bounds.origin.x + 15 + animationOffset;
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
        containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        containerView.layer.cornerRadius = 4.;
        containerView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        containerView.layer.borderWidth = .5;
        containerView.layer.shadowColor = [UIColor blackColor].CGColor;
        containerView.layer.shadowOpacity = 0.7f;
        containerView.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
        containerView.layer.shadowRadius = 3.0f;
        containerView.layer.masksToBounds = NO;
        containerView.backgroundColor = [UIColor whiteColor];
        
        CGFloat y = CELL_CONTENT_MARGIN;
        idLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELL_CONTENT_MARGIN, y, (containerView.frame.size.width - CELL_CONTENT_MARGIN * 2.) / 2., INFO_LABELS_HEIGHT)];
        idLabel.font = [UIFont systemFontOfSize:10];
        idLabel.textColor = [UIColor grayColor];
        [containerView addSubview:idLabel];
        
        ratingLabel = [[UILabel alloc] initWithFrame:CGRectMake(idLabel.frame.origin.x + idLabel.frame.size.width, y, (containerView.frame.size.width - CELL_CONTENT_MARGIN * 3.) / 2., INFO_LABELS_HEIGHT)];
        ratingLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        ratingLabel.textAlignment = UITextAlignmentRight;
        ratingLabel.font = [UIFont systemFontOfSize:10];
        ratingLabel.textColor = [UIColor grayColor];
        [containerView addSubview:ratingLabel];
        
        y += ratingLabel.frame.size.height;
        quoteTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELL_CONTENT_MARGIN, y, containerView.frame.size.width - CELL_CONTENT_MARGIN * 2., containerView.frame.size.height - INFO_LABELS_HEIGHT * 2 - CELL_CONTENT_MARGIN * 2)];
        quoteTextLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [quoteTextLabel setLineBreakMode:UILineBreakModeWordWrap];
        [quoteTextLabel setFont:[UIFont systemFontOfSize:FONT_SIZE]];
        [quoteTextLabel setNumberOfLines:0];
        [quoteTextLabel setUserInteractionEnabled:YES];
        [containerView addSubview:quoteTextLabel];
        
        y += quoteTextLabel.frame.size.height + 1;
        authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELL_CONTENT_MARGIN, y, (containerView.frame.size.width - CELL_CONTENT_MARGIN * 2.) / 2., INFO_LABELS_HEIGHT)];
        authorLabel.font = ratingLabel.font;
        authorLabel.textColor = [UIColor grayColor];
        authorLabel.shadowColor = [UIColor darkGrayColor];
        authorLabel.shadowOffset = CGSizeMake(0., -.5);
        [containerView addSubview:authorLabel];
        
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(authorLabel.frame.origin.x + authorLabel.frame.size.width, y, (containerView.frame.size.width - CELL_CONTENT_MARGIN * 3.) / 2., INFO_LABELS_HEIGHT)];
        dateLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        dateLabel.font = ratingLabel.font;
        dateLabel.textColor = [UIColor grayColor];
        dateLabel.textAlignment = UITextAlignmentRight;
        [containerView addSubview:dateLabel];
        
        CGFloat x = containerView.frame.origin.x + 20.;
        CGFloat shareButtonWidth = 32.;
        UIButton *shareBtn = nil;
        
        if ([SharingController isSharingAvailableForNetworkType:SharingFacebookNetwork]) {
            shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            shareBtn.frame = CGRectMake(x, 10., shareButtonWidth, shareButtonWidth);
            shareBtn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
            [shareBtn setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateNormal];
            [shareBtn addTarget:self action:@selector(shareWithFacebookAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:shareBtn];
            x += shareButtonWidth + 10.;
            animationOffset = x;
        }

        if ([SharingController isSharingAvailableForNetworkType:SharingTwitterNetwork]) {
            shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            shareBtn.frame = CGRectMake(x, 10., shareButtonWidth, shareButtonWidth);
            shareBtn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
            [shareBtn setImage:[UIImage imageNamed:@"twitter"] forState:UIControlStateNormal];
            [shareBtn addTarget:self action:@selector(shareWithTwitterAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:shareBtn];
            x += shareButtonWidth + 10.;
            
            animationOffset += shareButtonWidth + 10.;
        }
        
        if ([SharingController isSharingAvailableForNetworkType:SharingEMailNetwork]) {
            shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            shareBtn.frame = CGRectMake(x, 10., shareButtonWidth, shareButtonWidth);
            shareBtn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
            [shareBtn setImage:[UIImage imageNamed:@"gmail"] forState:UIControlStateNormal];
            [shareBtn addTarget:self action:@selector(shareWithEmailAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:shareBtn];
            x += shareButtonWidth + 10.;

            animationOffset += shareButtonWidth + 10.;
        }
        
        if ([SharingController isSharingAvailableForNetworkType:SharingVkontakteNetwork]) {
            shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            shareBtn.frame = CGRectMake(x, 10., shareButtonWidth, shareButtonWidth);
            shareBtn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
            [shareBtn setImage:[UIImage imageNamed:@"vk"] forState:UIControlStateNormal];
            [shareBtn addTarget:self action:@selector(shareWithVkontakteAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:shareBtn];
            x += shareButtonWidth + 10.;

            animationOffset += shareButtonWidth + 10.;
        }
        
        [self.contentView addSubview:containerView];
    }
    return self;
}

- (void)dealloc
{
    [containerView release];
    [quoteTextLabel release];
    [ratingLabel release];
    [dateLabel release];
    [authorLabel release];
    [idLabel release];
    shareDelegate = nil;
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
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    rect.origin.x += 15;
    rect.origin.y += 5;
    rect.size.width -= 20;
    rect.size.height -= 10;
    containerView.frame = rect;
    
    rect = authorLabel.frame;
    rect.origin.y = quoteTextLabel.frame.origin.y + quoteTextLabel.frame.size.height;
    authorLabel.frame = rect;
    
    rect = dateLabel.frame;
    rect.origin.y = quoteTextLabel.frame.origin.y + quoteTextLabel.frame.size.height;
    dateLabel.frame = rect;

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
