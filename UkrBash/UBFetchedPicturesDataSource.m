//
//  UBFetchedPicturesDataSource.m
//  UkrBash
//
//  Created by Maks Markovets on 06.05.14.
//
//

#import "UBFetchedPicturesDataSource.h"
#import "UkrBashAppDelegate.h"

@implementation UBFetchedPicturesDataSource

- (id)init
{
    if (self = [super init]) {
        managedObjectContext = [(UkrBashAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    }
    return self;
}

- (void)dealloc
{
    [_fetchedResultsController release];
    [_collectionView release];
    [super dealloc];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    return [_fetchedResultsController objectAtIndexPath:indexPath];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    NSAssert(NO, @"this method should be overloaded by subclasses");
    return nil;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    id  sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

@end
