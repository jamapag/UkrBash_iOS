//
//  UBPicturesCollectionViewController.h
//  UkrBash
//
//  Created by maks on 20.02.13.
//
//

#import "UBViewController.h"
#import "UBPicturesDataSource.h"

@interface UBPicturesCollectionViewController : UBViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_collectionView;
    UIRefreshControl *_refreshControl;
    
    UBPicturesDataSource *dataSource;
    NSMutableDictionary *pendingImages;
    id localImageLoadedObserver;
    id localPicturesLoadedObserver;
    
    bool loading;
    bool shouldShowFooter;
}

- (id)initWithDataSourceClass:(Class)dataSourceClass;

@end
