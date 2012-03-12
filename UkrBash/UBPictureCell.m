//
//  UBImageCell.m
//  UkrBash
//
//  Created by Михаил Гребенкин on 03.02.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "UBPictureCell.h"

@implementation UBPictureCell

- (UIImageView *)imageView
{
    return imageView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)dealloc
{
    [imageView release];
    [super dealloc];
}

@end
