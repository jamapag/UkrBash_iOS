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


@interface UBPicturesCollectionViewController : UBViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UBQuoteCollectionCellDelegate>
{
    UICollectionView *_collectionView;
    UIRefreshControl *_refreshControl;
    
    UBPicturesDataSource *dataSource;
    NSMutableDictionary *pendingImages;
    id localImageLoadedObserver;
    id localPicturesLoadedObserver;
    
    bool loading;
    bool shouldShowFooter;
    bool rotating;
}

- (id)initWithDataSourceClass:(Class)dataSourceClass;

@end
