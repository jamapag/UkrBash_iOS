//
//  UBBestPicturesDataSource.m
//  UkrBash
//
//  Created by Maks Markovets on 04.02.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "UBBestPicturesDataSource.h"
#import "Model.h"

@implementation UBBestPicturesDataSource

- (NSArray *)items
{
    return [[Model sharedModel] bestImages];
}

- (void)loadMoreItems
{
    [[Model sharedModel] loadMoreBestPictures];
}

- (void)loadNewItems
{
    [[Model sharedModel] loadNewBestPictures];
}

@end
