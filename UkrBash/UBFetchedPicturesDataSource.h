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

@property (nonatomic, retain) UICollectionView *collectionView;

- (NSFetchedResultsController *)fetchedResultsController;

@end
