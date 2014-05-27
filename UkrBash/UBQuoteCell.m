//
//  UBQuoteCell.m
//  UkrBash
//
//  Created by Maks Markovets on 23.12.11.
//  Copyright (c) 2011 smile2mobile. All rights reserved.
//

#import "UBQuoteCell.h"
#import <QuartzCore/QuartzCore.h>


#define INFO_LABELS_HEIGHT 12.0f
#define INFO_LABELS_PADDING (IS_PAD ? IPAD_INFO_LABELS_PADDING : IPHONE_INFO_LABELS_PADDING)

#define MARGIN_TOP IS_PAD ? IPAD_CELL_MARGIN_TOP : IPHONE_CELL_MARGIN_TOP
#define MARGIN_BOTTOM IS_PAD ? IPAD_CELL_MARGIN_BOTTOM : IPHONE_CELL_MARGIN_BOTTOM
#define MARGIN_LEFT IS_PAD ? IPAD_CELL_MARGIN_LEFT : IPHONE_CELL_MARGIN_LEFT
#define MARGIN_RIGHT IS_PAD ? IPAD_CELL_MARGIN_RIGHT : IPHONE_CELL_MARGIN_RIGHT

#define CONTENT_PADDING_TOP IS_PAD ? IPAD_CELL_CONTENT_PADDING_TOP : IPHONE_CELL_CONTENT_PADDING_TOP
#define CONTENT_PADDING_BOTTOM IS_PAD ? IPAD_CELL_CONTENT_PADDING_BOTTOM : IPHONE_CELL_CONTENT_PADDING_BOTTOM
#define CONTENT_PADDING_LEFT IS_PAD ? IPAD_CELL_CONTENT_PADDING_LEFT : IPHONE_CELL_CONTENT_PADDING_LEFT
#define CONTENT_PADDING_RIGHT IS_PAD ? IPAD_CELL_CONTENT_PADDING_RIGHT : IPHONE_CELL_CONTENT_PADDING_RIGHT

CGFloat animationOffset = 52.;

@implementation UBQuoteCell

@synthesize quoteTextLabel;
@synthesize ratingLabel;
@synthesize dateLabel;
@synthesize authorLabel;
@synthesize idLabel;
@synthesize favoriteButton;
@synthesize shareButtonsVisible;
@synthesize shareDelegate;

+ (CGFloat)heightForQuoteText:(NSString*)text viewWidth:(CGFloat)width
{
    width = width - (((CONTENT_PADDING_LEFT) + (CONTENT_PADDING_RIGHT)) + (MARGIN_RIGHT) + (MARGIN_LEFT));
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

    CGFloat height = MAX(size.height, 44.0f);
    
    return height + (INFO_LABELS_PADDING * 2) + (INFO_LABELS_HEIGHT * 2) + (CONTENT_PADDING_TOP) + (CONTENT_PADDING_BOTTOM) + (MARGIN_TOP) + (MARGIN_BOTTOM);
}

-(void)favoriteAction:(id)sender
{
    if (self.shareDelegate) {
        [self.shareDelegate favoriteActionForCell:self];
    }
}

- (void)shareAction:(UIButton *)sender
{
    if (self.shareDelegate) {
        [self.shareDelegate shareActionForCell:self andRectForPopover:sender.frame];
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
        self.backgroundColor = [UIColor clearColor];
        
        CGRect rect = self.bounds;
        rect.origin.x += (MARGIN_LEFT);
        rect.origin.y += (MARGIN_TOP);
        rect.size.width -= ((MARGIN_LEFT) + (MARGIN_RIGHT));
        rect.size.height -= ((MARGIN_TOP) + (MARGIN_BOTTOM));
        containerView = [[UIView alloc] initWithFrame:rect];
        containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        containerView.layer.cornerRadius = 4.;
        containerView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        containerView.layer.borderWidth = .5;
        containerView.backgroundColor = [UIColor whiteColor];

        
        CGFloat y = INFO_LABELS_PADDING;
        idLabel = [[UILabel alloc] initWithFrame:CGRectMake(INFO_LABELS_PADDING, y, (containerView.frame.size.width - INFO_LABELS_PADDING * 2.) / 2., INFO_LABELS_HEIGHT)];
        idLabel.font = [UIFont systemFontOfSize:10];
        idLabel.textColor = [UIColor grayColor];
        idLabel.backgroundColor = [UIColor clearColor];
        [containerView addSubview:idLabel];
        
        ratingLabel = [[UILabel alloc] initWithFrame:CGRectMake(idLabel.frame.origin.x + idLabel.frame.size.width, y, (containerView.frame.size.width - INFO_LABELS_PADDING * 2.) / 2., INFO_LABELS_HEIGHT)];
        ratingLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        ratingLabel.textAlignment = NSTextAlignmentRight;
        ratingLabel.font = [UIFont systemFontOfSize:10];
        ratingLabel.textColor = [UIColor grayColor];
        ratingLabel.backgroundColor = [UIColor clearColor];
        [containerView addSubview:ratingLabel];
        
        y += ratingLabel.frame.size.height + (CONTENT_PADDING_TOP);
        quoteTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(CONTENT_PADDING_LEFT, y, containerView.frame.size.width - ((CONTENT_PADDING_LEFT) + (CONTENT_PADDING_RIGHT)), containerView.frame.size.height - (INFO_LABELS_HEIGHT * 2 + (INFO_LABELS_PADDING) * 2 + ((CONTENT_PADDING_TOP) + (CONTENT_PADDING_BOTTOM))))];
        quoteTextLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        quoteTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        quoteTextLabel.font = GET_FONT();
        quoteTextLabel.numberOfLines = 0;
        quoteTextLabel.userInteractionEnabled = YES;
        [containerView addSubview:quoteTextLabel];
        
        y += quoteTextLabel.frame.size.height + 1;
        authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(INFO_LABELS_PADDING, y, (containerView.frame.size.width - INFO_LABELS_PADDING * 2.) / 2., INFO_LABELS_HEIGHT)];
        authorLabel.font = ratingLabel.font;
        authorLabel.textColor = [UIColor grayColor];
        authorLabel.shadowColor = [UIColor darkGrayColor];
        authorLabel.shadowOffset = CGSizeMake(0., -.5);
        authorLabel.backgroundColor = [UIColor clearColor];
        [containerView addSubview:authorLabel];
        
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(authorLabel.frame.origin.x + authorLabel.frame.size.width, y, (containerView.frame.size.width - INFO_LABELS_PADDING * 2.) / 2., INFO_LABELS_HEIGHT)];
        dateLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        dateLabel.font = ratingLabel.font;
        dateLabel.textColor = [UIColor grayColor];
        dateLabel.textAlignment = NSTextAlignmentRight;
        dateLabel.backgroundColor = [UIColor clearColor];
        [containerView addSubview:dateLabel];
        
        CGFloat x = containerView.frame.origin.x + 20.;
        CGFloat shareButtonWidth = 34.;
        UIButton *shareBtn = nil;
        
        animationOffset = 52.;
        
        favoriteButton = [[UIButton buttonWithType:UIButtonTypeCustom]  retain];
        favoriteButton.frame = CGRectMake(x, 15., shareButtonWidth, shareButtonWidth);
        favoriteButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        favoriteButton.imageView.contentMode = UIViewContentModeCenter;
        [favoriteButton setImage:[UIImage imageNamed:@"favorite"] forState:UIControlStateNormal];
        [favoriteButton addTarget:self action:@selector(favoriteAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:favoriteButton];
        x += shareButtonWidth + 15.;
        animationOffset = x;
        
        shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        shareBtn.frame = CGRectMake(x, 15, shareButtonWidth, shareButtonWidth);
        shareBtn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        shareBtn.imageView.contentMode = UIViewContentModeCenter;
        [shareBtn setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
        [shareBtn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:shareBtn];
        x += shareButtonWidth + 15.;
        animationOffset = x - 5;
        
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
    [favoriteButton release];
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
    rect.origin.x += (MARGIN_LEFT);
    rect.origin.y += (MARGIN_TOP);
    rect.size.width -= ((MARGIN_LEFT) + (MARGIN_RIGHT));
    rect.size.height -= ((MARGIN_TOP) + (MARGIN_BOTTOM));
    containerView.frame = rect;
    
    rect = idLabel.frame;
    rect.size.width = (containerView.frame.size.width - INFO_LABELS_PADDING * 2) / 2;
    idLabel.frame = rect;
    
    rect = ratingLabel.frame;
    rect.origin.x = idLabel.frame.origin.x + idLabel.frame.size.width;
    rect.size.width = (containerView.frame.size.width - INFO_LABELS_PADDING * 2.) / 2;
    ratingLabel.frame = rect;
    
    rect = authorLabel.frame;
    rect.origin.y = (containerView.frame.size.height - (INFO_LABELS_PADDING + INFO_LABELS_HEIGHT));
    rect.size.width = (containerView.frame.size.width - INFO_LABELS_PADDING * 2) / 2;
    authorLabel.frame = rect;
    
    rect = dateLabel.frame;
    rect.origin.x = authorLabel.frame.origin.x + authorLabel.frame.size.width;
    rect.origin.y = (containerView.frame.size.height - (INFO_LABELS_PADDING + INFO_LABELS_HEIGHT));
    rect.size.width = (containerView.frame.size.width - INFO_LABELS_PADDING * 2.) / 2;
    dateLabel.frame = rect;
    
    rect = quoteTextLabel.frame;
    rect.origin.x = CONTENT_PADDING_LEFT;
    rect.origin.y = INFO_LABELS_PADDING + INFO_LABELS_HEIGHT + (CONTENT_PADDING_TOP);
    rect.size.height = containerView.frame.size.height - (INFO_LABELS_PADDING * 2 + INFO_LABELS_HEIGHT * 2 + ((CONTENT_PADDING_TOP) + (CONTENT_PADDING_BOTTOM)));
    quoteTextLabel.frame = rect;
}

@end
