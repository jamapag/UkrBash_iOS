//
//  UBMenuItemCell.m
//  UkrBash
//
//  Created by Михаил Гребенкин on 16.01.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "UBMenuItemCell.h"

@implementation UBMenuItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    if (animated) {
        if (selected) {
            [UIView animateWithDuration:1. animations:^ {
                self.textLabel.textColor = [UIColor colorWithRed:.04 green:.6 blue:.97 alpha:1.];
            }];
        } else {
            [UIView animateWithDuration:1. animations:^ {
                self.textLabel.textColor = [UIColor colorWithWhite:.25 alpha:1.];
            }];
        }
    } else {
        if (selected) {
            self.textLabel.textColor = [UIColor colorWithRed:.04 green:.6 blue:.97 alpha:1.];
            self.textLabel.shadowOffset = CGSizeZero;
        } else {
            self.textLabel.textColor = [UIColor colorWithWhite:.25 alpha:1.];
            self.textLabel.shadowOffset = CGSizeMake(0., 1.);
        }
    }
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
    } else {
        if (self.indentationLevel == 2) {
            float indentPoints = self.indentationLevel * self.indentationWidth;
            self.imageView.frame = CGRectMake(self.imageView.frame.origin.x + indentPoints,
                                              self.imageView.frame.origin.y,
                                              self.imageView.frame.size.width,
                                              self.imageView.frame.size.height
                                              );
        }
    }
}

@end
