//
//  UBPublishedPicturesDataSource.m
//  UkrBash
//
//  Created by Maks Markovets on 26.01.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "UBPublishedPicturesDataSource.h"
#import "Model.h"

@implementation UBPublishedPicturesDataSource

- (NSArray *)items
{
    return [[Model sharedModel] publishedImages];
}

- (void)loadMoreItems
{
    [[Model sharedModel] loadMorePublishedPictures];
}

@end
