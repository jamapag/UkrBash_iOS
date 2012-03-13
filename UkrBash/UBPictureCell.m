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
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CELL_CONTENT_MARGIN, CELL_CONTENT_MARGIN, containerView.frame.size.height - CELL_CONTENT_MARGIN * 2., containerView.frame.size.height - CELL_CONTENT_MARGIN * 2.)];
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
    
    CGRect fr = imageView.frame;
    fr.size.width = delta - CELL_CONTENT_MARGIN * 2.;
    fr.size.height = delta - CELL_CONTENT_MARGIN * 2.;
    imageView.frame = fr;
    
    fr = quoteTextLabel.frame;
    fr.origin.x = delta;
    fr.size.width = containerView.frame.size.width - 2 * CELL_CONTENT_MARGIN - delta;
    quoteTextLabel.frame = fr;
    
    fr = idLabel.frame;
    fr.origin.x = delta;
    idLabel.frame = fr;

    fr = authorLabel.frame;
    fr.origin.x = delta;
    authorLabel.frame = fr;
}

- (void)dealloc
{
    [imageView release];
    [super dealloc];
}

@end
