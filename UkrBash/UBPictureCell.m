//
//  UBImageCell.m
//  UkrBash
//
//  Created by Михаил Гребенкин on 03.02.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "UBPictureCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation UBPictureCell

- (UIImageView *)imageView
{
    return imageView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        float margin = CELL_CONTENT_MARGIN;
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(margin, margin, containerView.frame.size.height - margin * 2., containerView.frame.size.height - margin * 2.)];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.clipsToBounds = YES;
        imageView.layer.cornerRadius = 2.;
        imageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        imageView.layer.borderWidth = .5;
        [containerView addSubview:imageView];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat delta = containerView.frame.size.height;
    
    float margin = CELL_CONTENT_MARGIN;
    
    CGRect fr = imageView.frame;
    fr.size.width = delta - margin * 2.;
    fr.size.height = delta - margin * 2.;
    imageView.frame = fr;
    
    fr = quoteTextLabel.frame;
    fr.origin.x = delta;
    fr.size.width = containerView.frame.size.width - 2 * margin - delta;
    quoteTextLabel.frame = fr;
    
    fr = idLabel.frame;
    fr.origin.x = delta;
    fr.size.width = (containerView.frame.size.width - margin - delta) / 2;
    idLabel.frame = fr;
    
    fr = ratingLabel.frame;
    fr.origin.x = idLabel.frame.origin.x + idLabel.frame.size.width;
    fr.size.width = (containerView.frame.size.width - margin - delta) / 2;
    ratingLabel.frame = fr;
    
    fr = authorLabel.frame;
    fr.origin.x = delta;
    fr.size.width = (containerView.frame.size.width - margin - delta) / 2;
    authorLabel.frame = fr;
    
    fr = dateLabel.frame;
    fr.origin.x = authorLabel.frame.origin.x + authorLabel.frame.size.width;
    fr.origin.y = quoteTextLabel.frame.origin.y + quoteTextLabel.frame.size.height;
    fr.size.width = (containerView.frame.size.width - margin - delta) / 2;
    dateLabel.frame = fr;
}

- (void)dealloc
{
    [imageView release];
    [super dealloc];
}

@end
