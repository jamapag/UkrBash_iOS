//
//  UBPictureCollectionViewCell.h
//  UkrBash
//
//  Created by maks on 20.02.13.
//
//

#import <UIKit/UIKit.h>

@interface UBPictureCollectionViewCell : UICollectionViewCell
{
    UIImageView *imageView;
    UILabel *pictureTittleLabel;
}

@property (nonatomic, retain) UIImageView *imageView;

- (NSString *)pictureTitle;
- (void)setPictureTitle:(NSString *)pictureTitle;

@end
