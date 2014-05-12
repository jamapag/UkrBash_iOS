//
//  UBFavoriteQuotesDataSource.m
//  UkrBash
//
//  Created by Maks Markovets on 24.04.14.
//
//

#import "UBFavoriteQuotesDataSource.h"
#import "UkrBashAppDelegate.h"
#import "Model.h"
#import "UBQuoteCell.h"
#import "Quote.h"

@implementation UBFavoriteQuotesDataSource

- (NSArray *)items
{
    NSLog(@"Itemscalled");
    return [[[_fetchedResultsController sections] objectAtIndex:0] objects];
}

- (void)loadNewItems
{
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    NSLog(@"AFTER PERFORM FETCH");
    [self.tableView reloadData];
}

- (void)loadMoreItems
{
    [self loadNewItems];
}

- (BOOL)isNoMore
{
    return YES;
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    [NSFetchedResultsController deleteCacheWithName:@"FavoriteQuotesCache"];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Quote" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"quoteId" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [sort release];
    
    NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"favorite == %@", [NSNumber numberWithBool:YES]];
    [fetchRequest setPredicate:fetchPredicate];

    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:@"FavoriteQuotesCache"];
    _fetchedResultsController = [theFetchedResultsController retain];
    _fetchedResultsController.delegate = self;
    
    [fetchRequest release];
    [theFetchedResultsController release];
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"Begin updates");
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    NSLog(@"UPDATING");
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] forRowAtIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"end updates");
    [self.tableView endUpdates];
}

- (void)configureCell:(UITableViewCell *)_cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert([_cell isKindOfClass:[UBQuoteCell class]], @"cell should be subclass of UBQuoteCell class");
    
    UBQuoteCell *cell = (UBQuoteCell*)_cell;
    
    Quote *quote = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.idLabel.text = [NSString stringWithFormat:@"%ld", [quote.quoteId longValue]];
    cell.quoteTextLabel.text = quote.text;
    cell.ratingLabel.text = [self ratingStringFromRating:[quote.rating integerValue]];
    if (quote.pubDate) {
        cell.dateLabel.text = [[self dateFormatter] stringFromDate:quote.pubDate];        
    } else {
        cell.dateLabel.text = [[self dateFormatter] stringFromDate:quote.addDate];
    }
    
    if ([quote.favorite boolValue]) {
        [cell.favoriteButton setImage:[UIImage imageNamed:@"favorite_active"] forState:UIControlStateNormal];
    }

    cell.authorLabel.text = quote.author;
}
@end
