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

#define IPHONE_INFO_LABELS_PADDING 5.0f
#define IPAD_INFO_LABELS_PADDING 10.0f

#define IPHONE_CELL_CONTENT_PADDING_TOP 10.0f
#define IPHONE_CELL_CONTENT_PADDING_BOTTOM 10.0f
#define IPHONE_CELL_CONTENT_PADDING_RIGHT 10.0f
#define IPHONE_CELL_CONTENT_PADDING_LEFT 10.0f

#define IPAD_CELL_CONTENT_PADDING_TOP 20.0f
#define IPAD_CELL_CONTENT_PADDING_BOTTOM 20.0f
#define IPAD_CELL_CONTENT_PADDING_LEFT 20.0f
#define IPAD_CELL_CONTENT_PADDING_RIGHT 20.0f

#define IPHONE_CELL_MARGIN_TOP 5.0f
#define IPHONE_CELL_MARGIN_BOTTOM 5.0f
#define IPHONE_CELL_MARGIN_RIGHT 5.0f
#define IPHONE_CELL_MARGIN_LEFT 15.0f

#define IPAD_CELL_MARGIN_TOP 5.0f
#define IPAD_CELL_MARGIN_BOTTOM 5.0f
#define IPAD_CELL_MARGIN_RIGHT 5.0f
#define IPAD_CELL_MARGIN_LEFT 15.0f

#define FONT_SIZE 14.0f
#define IPAD_FONT_SIZE 18.0f
#define GET_FONT() IS_IOS7 ? [UIFont preferredFontForTextStyle:UIFontTextStyleBody] : IS_PAD ? [UIFont systemFontOfSize:IPAD_FONT_SIZE] : [UIFont systemFontOfSize:FONT_SIZE]

@class UBQuoteCell;

@protocol UBQuoteCellDelegate <NSObject>

//- (void)quoteCell:(UBQuoteCell *)cell shareQuoteWithType:(SharingNetworkType)shareType;
- (void)favoriteActionForCell:(UBQuoteCell *)cell;
- (void)shareActionForCell:(id)cell andRectForPopover:(CGRect)rect;

@end

@interface UBQuoteCell : UITableViewCell
{
    UILabel *quoteTextLabel;
    UILabel *ratingLabel;
    UILabel *authorLabel;
    UILabel *dateLabel;
    UILabel *idLabel;
    UIButton *favoriteButton;
    UIView *containerView;
    BOOL shareButtonsVisible;
    id <UBQuoteCellDelegate> shareDelegate;
}

@property (nonatomic, readonly) UILabel *quoteTextLabel;
@property (nonatomic, readonly) UILabel *ratingLabel;
@property (nonatomic, readonly) UILabel *dateLabel;
@property (nonatomic, readonly) UILabel *authorLabel;
@property (nonatomic, readonly) UILabel *idLabel;
@property (nonatomic, readonly) UIButton *favoriteButton;
@property (nonatomic, readonly) BOOL shareButtonsVisible;

@property (nonatomic, assign) id <UBQuoteCellDelegate> shareDelegate;

+ (CGFloat)heightForQuoteText:(NSString *)text viewWidth:(CGFloat)width;

- (void)showShareButtons;
- (void)hideShareButtons;

@end
