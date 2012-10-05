//
//  UBQuoteCell.h
//  UkrBash
//
//  Created by Maks Markovets on 23.12.11.
//  Copyright (c) 2011 smile2mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharingController.h"

#define CELL_CONTENT_MARGIN 5.0f


@class UBQuoteCell;

@protocol UBQuoteCellDelegate <NSObject>

- (void)quoteCell:(UBQuoteCell*)cell shareQuoteWithType:(SharingNetworkType)shareType;

@end

@interface UBQuoteCell : UITableViewCell
{
    UILabel *quoteTextLabel;
    UILabel *ratingLabel;
    UILabel *authorLabel;
    UILabel *dateLabel;
    UILabel *idLabel;
    UIView *containerView;
    BOOL shareButtonsVisible;
    id <UBQuoteCellDelegate> shareDelegate;
}

@property (nonatomic, readonly) UILabel *quoteTextLabel;
@property (nonatomic, readonly) UILabel *ratingLabel;
@property (nonatomic, readonly) UILabel *dateLabel;
@property (nonatomic, readonly) UILabel *authorLabel;
@property (nonatomic, readonly) UILabel *idLabel;
@property (nonatomic, readonly) BOOL shareButtonsVisible;

@property (nonatomic, assign) id <UBQuoteCellDelegate> shareDelegate;

+ (CGFloat)heightForQuoteText:(NSString*)text viewWidth:(CGFloat)width;

- (void)showShareButtons;
- (void)hideShareButtons;

@end
