//
//  UBQuoteCell.m
//  UkrBash
//
//  Created by Maks Markovets on 23.12.11.
//  Copyright (c) 2011 smile2mobile. All rights reserved.
//

#import "UBQuoteCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation UBQuoteCell
@synthesize quoteTextLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView.layer setCornerRadius:4.f];
        self.contentView.backgroundColor = [UIColor whiteColor];
        // Initialization code
        quoteTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(5., 5., self.contentView.frame.size.width - 10, self.contentView.frame.size.height - 10)];
        [quoteTextLabel setLineBreakMode:UILineBreakModeWordWrap];
//        [[quoteTextLabel layer] setBorderWidth:2];
        [quoteTextLabel setFont:[UIFont systemFontOfSize:12.f]];
        [quoteTextLabel setNumberOfLines:0];
        [self.contentView addSubview:quoteTextLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    CGRect rect = self.bounds;
    rect.origin.x += 15;
    rect.origin.y += 5;
    rect.size.width -= 20;
    rect.size.height -= 10;
    self.contentView.frame = rect;
    
    self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.contentView.layer.shadowOpacity = 0.7f;
    self.contentView.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    self.contentView.layer.shadowRadius = 3.0f;
    self.contentView.layer.masksToBounds = NO;
    
    CGSize size = self.contentView.bounds.size;
    CGFloat curlFactor = 7.0f;
    CGFloat shadowDepth = 3.0f;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0.0f, 0.0f)];
    [path addLineToPoint:CGPointMake(size.width, 0.0f)];
    [path addLineToPoint:CGPointMake(size.width, size.height + shadowDepth)];
    [path addCurveToPoint:CGPointMake(0.0f, size.height + shadowDepth)
            controlPoint1:CGPointMake(size.width - curlFactor, size.height + shadowDepth - curlFactor)
            controlPoint2:CGPointMake(curlFactor, size.height + shadowDepth - curlFactor)];
    
//    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.contentView.bounds];
    self.contentView.layer.shadowPath = path.CGPath;
    
    quoteTextLabel.frame = CGRectMake(5., 5., self.contentView.frame.size.width - 10, self.contentView.frame.size.height - 10);
    
}

@end
