//
//  UBDonateCell.h
//  UkrBash
//
//  Created by Michail Grebionkin on 21.01.13.
//
//

#import <UIKit/UIKit.h>

@interface UBDonateCell : UITableViewCell
{
    UILabel * _titleLabel;
    UILabel * _valueLable;
    UIImageView * _buttonBackground;
}

@property (nonatomic, readonly) UILabel * titleLabel;
@property (nonatomic, readonly) UILabel * valueLabel;

@end
