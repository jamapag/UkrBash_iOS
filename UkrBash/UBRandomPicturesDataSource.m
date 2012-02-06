//
//  UBRandomPicturesDataSource.m
//  UkrBash
//
//  Created by Maks Markovets on 04.02.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "UBRandomPicturesDataSource.h"
#import "Model.h"

@implementation UBRandomPicturesDataSource

- (NSArray *)items
{
    return [[Model sharedModel] randomImages];
}

- (void)loadMoreItems
{
    [[Model sharedModel] loadMoreRandomPictures];
}

@end
