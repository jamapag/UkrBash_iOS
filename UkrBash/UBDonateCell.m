//
//  UBDonateCell.m
//  UkrBash
//
//  Created by Michail Grebionkin on 21.01.13.
//
//

#import "UBDonateCell.h"

@implementation UBDonateCell

@synthesize titleLabel = _titleLabel;
@synthesize valueLabel = _valueLable;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont boldSystemFontOfSize:17.];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor darkGrayColor];
        _titleLabel.shadowColor = [UIColor whiteColor];
        _titleLabel.shadowOffset = CGSizeMake(0., 1.);
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_titleLabel];
        [_titleLabel release];
        
        _buttonBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
        _buttonBackground.image = [[UIImage imageNamed:@"category-button-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0., 10., 0., 10.)];
        [self addSubview:_buttonBackground];
        [_buttonBackground release];
        
        _valueLable = [[UILabel alloc] initWithFrame:CGRectZero];
        _valueLable.font = [UIFont boldSystemFontOfSize:17.];
        _valueLable.backgroundColor = [UIColor clearColor];
        _valueLable.shadowColor = [UIColor whiteColor];
        _valueLable.shadowOffset = CGSizeMake(0., 1.);
        _valueLable.textAlignment = NSTextAlignmentRight;
        [self addSubview:_valueLable];
        [_valueLable release];
        
        [self setNeedsLayout];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat lableHeight = 21.;
    CGFloat lableY = self.frame.size.height / 2. - lableHeight/2.;
    _titleLabel.frame = CGRectMake(45., lableY, self.frame.size.width - 25. - 90., lableHeight);
    _valueLable.frame = CGRectMake(self.frame.size.width - 100., lableY, 80., lableHeight);
    _buttonBackground.frame = CGRectMake(_valueLable.frame.origin.x + 20, self.bounds.size.height / 2. - 18., 75., 36.);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
