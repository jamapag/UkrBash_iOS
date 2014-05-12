//
//  UBFavoritePicturesDataSource.h
//  UkrBash
//
//  Created by Maks Markovets on 06.05.14.
//
//

#import "UBFetchedPicturesDataSource.h"

@interface UBFavoritePicturesDataSource : UBFetchedPicturesDataSource
{
    NSMutableArray *_objectChanges;
    NSMutableArray *_sectionChanges;
}

@end
