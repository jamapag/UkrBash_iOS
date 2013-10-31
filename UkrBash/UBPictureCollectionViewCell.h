//
//  UBPictureCollectionViewCell.h
//  UkrBash
//
//  Created by maks on 20.02.13.
//
//

#import <UIKit/UIKit.h>
#import "SharingController.h"

@class UBPictureCollectionViewCell;

@protocol UBQuoteCollectionCellDelegate <NSObject>

- (void)quoteCell:(UBPictureCollectionViewCell *)cell shareQuoteWithType:(SharingNetworkType)shareType;
- (void)copyUrlActionForCell:(UBPictureCollectionViewCell *)cell;
- (void)openInBrowserActionForCell:(UBPictureCollectionViewCell *)cell;

@end


@interface UBPictureCollectionViewCell : UICollectionViewCell
{
    UIImageView *imageView;
    UILabel *pictureTittleLabel;
    UILabel *authorLabel;
    UILabel *ratingLabel;
    UIView *sharingOverlay;
    id<UBQuoteCollectionCellDelegate> shareDelegate;
}

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, readonly) UILabel *authorLabel;
@property (nonatomic, readonly) UILabel *ratingLabel;
@property (nonatomic, assign) id<UBQuoteCollectionCellDelegate> shareDelegate;

- (NSString *)pictureTitle;
- (void)setPictureTitle:(NSString *)pictureTitle;
- (void)hideSharingOverlay;
- (void)copyUrlAction:(id)sender;
- (void)openInBrowserAction:(id)sender;

@end
