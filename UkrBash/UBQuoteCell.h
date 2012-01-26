//
//  UBQuoteCell.h
//  UkrBash
//
//  Created by Maks Markovets on 23.12.11.
//  Copyright (c) 2011 smile2mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UBQuoteCell : UITableViewCell
{
    UILabel *quoteTextLabel;
    UILabel *ratingLabel;
    UILabel *authorLabel;
    UILabel *dateLabel;
    UILabel *idLabel;
    UIView *containerView;
    BOOL shareButtonsVisible;
}

@property (nonatomic, readonly) UILabel *quoteTextLabel;
@property (nonatomic, readonly) UILabel *ratingLabel;
@property (nonatomic, readonly) UILabel *dateLabel;
@property (nonatomic, readonly) UILabel *authorLabel;
@property (nonatomic, readonly) UILabel *idLabel;
@property (nonatomic, readonly) BOOL shareButtonsVisible;

+ (CGFloat)heightForQuoteText:(NSString*)text viewWidth:(CGFloat)width;

- (void)showShareButtons;
- (void)hideShareButtons;

@end
