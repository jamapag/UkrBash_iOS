//
//  UBMenuItemCell.m
//  UkrBash
//
//  Created by Михаил Гребенкин on 16.01.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "UBMenuItemCell.h"

@implementation UBMenuItemCell

/*
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
 */

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
            self.textLabel.textColor = [UIColor blackColor];
            }];
        }
    } else {
        if (selected) {
            self.textLabel.textColor = [UIColor colorWithRed:.04 green:.6 blue:.97 alpha:1.];
        } else {
            self.textLabel.textColor = [UIColor blackColor];
        }
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.imageView.transform = CGAffineTransformIdentity;
    self.indentationLevel = 1;
    self.indentationWidth = 10.;
}

@end
