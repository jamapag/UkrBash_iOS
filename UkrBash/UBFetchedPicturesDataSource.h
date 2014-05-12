//
//  UBFetchedPicturesDataSource.h
//  UkrBash
//
//  Created by Maks Markovets on 06.05.14.
//
//

#import "UBPicturesDataSource.h"

@interface UBFetchedPicturesDataSource : UBPicturesDataSource <NSFetchedResultsControllerDelegate>
{
    NSFetchedResultsController *_fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, strong) UICollectionView *collectionView;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (NSFetchedResultsController *)fetchedResultsController;

@end
