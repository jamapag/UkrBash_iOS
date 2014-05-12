//
//  UBFetchedQuotesDataSource.h
//  UkrBash
//
//  Created by Maks Markovets on 30.04.14.
//
//

#import <Foundation/Foundation.h>
#import "UBQuotesDataSource.h"

@interface UBFetchedQuotesDataSource : UBQuotesDataSource <NSFetchedResultsControllerDelegate>
{
    NSFetchedResultsController *_fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, strong) UITableView *tableView;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;

@end
