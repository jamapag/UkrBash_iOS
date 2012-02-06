//
//  UBUnpablishedPicturesDataSource.m
//  UkrBash
//
//  Created by Maks Markovets on 04.02.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "UBUnpablishedPicturesDataSource.h"
#import "Model.h"

@implementation UBUnpablishedPicturesDataSource

- (NSArray *)items
{
    return [[Model sharedModel] unpablishedImages];
}

- (void)loadMoreItems
{
    [[Model sharedModel] loadMoreUnpablishedPictures];
}

@end
