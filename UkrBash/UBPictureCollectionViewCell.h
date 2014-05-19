//
//  UBPictureCollectionViewCell.h
//  UkrBash
//
//  Created by Maks Markovets on 08.05.14.
//
//

#import <UIKit/UIKit.h>
#import "SharingController.h"

@protocol UBQuoteCollectionCellDelegate <NSObject>

//- (void)quoteCell:(id)cell shareQuoteWithType:(SharingNetworkType)shareType;
- (void)copyUrlActionForCell:(id)cell;
- (void)openInBrowserActionForCell:(id)cell;
- (void)favoriteActionForCell:(id)cell;
- (void)shareActionForCell:(id)cell andRectForPopover:(CGRect)rect;

@end

@interface UBPictureCollectionViewCell : UICollectionViewCell
{
    UIImageView *imageView;
    UILabel *dateLabel;
    UILabel *pictureTittleLabel;
    UILabel *authorLabel;
    UILabel *ratingLabel;
    UIButton *favoriteButton;
    id<UBQuoteCollectionCellDelegate> shareDelegate;
}

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, readonly) UILabel *authorLabel;
@property (nonatomic, readonly) UILabel *ratingLabel;
@property (nonatomic, readonly) UILabel *dateLabel;
@property (nonatomic, readonly) UIButton *favoriteButton;
@property (nonatomic, assign) id<UBQuoteCollectionCellDelegate> shareDelegate;

- (NSString *)pictureTitle;
- (void)setPictureTitle:(NSString *)pictureTitle;
- (void)copyUrlAction:(id)sender;
- (void)openInBrowserAction:(id)sender;

@end
