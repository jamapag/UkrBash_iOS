//
//  UBPicturesController.h
//  UkrBash
//
//  Created by Maks Markovets on 06.05.14.
//
//

#import "UBViewController.h"
#import "UBFetchedPicturesDataSource.h"
#import "UBPictureCollectionViewCell.h"
#import "UBFullSizePictureViewController.h"

@interface UBPicturesController : UBViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UBQuoteCollectionCellDelegate>
{
    UICollectionView *_collectionView;
    UBFullSizePictureViewController *fullSizeController;
    
    id localImageLoadedObserver;
    
    UBFetchedPicturesDataSource *dataSource;
    NSMutableDictionary *pendingImages;
}

- (id)initWithDataSourceClass:(Class)dataSourceClass;

@end
