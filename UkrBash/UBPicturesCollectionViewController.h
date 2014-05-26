//
//  UBPicturesCollectionViewController.h
//  UkrBash
//
//  Created by maks on 20.02.13.
//
//

#import "UBViewController.h"
#import "UBPicturesDataSource.h"
#import "UBPictureCollectionViewCell.h"
#import "UBFullSizePictureViewController.h"


@interface UBPicturesCollectionViewController : UBViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UBQuoteCollectionCellDelegate, UBFullSizePictureViewControllerDelegate>
{
    UICollectionView *_collectionView;
    UIRefreshControl *_refreshControl;
    
    UBPicturesDataSource *dataSource;
    NSMutableDictionary *pendingImages;
    
    UBFullSizePictureViewController *fullSizeController;
    id localImageLoadedObserver;
    id localPicturesLoadedObserver;
    
    bool loading;
    bool shouldShowFooter;
    bool rotating;
}

- (id)initWithDataSourceClass:(Class)dataSourceClass;

@end
