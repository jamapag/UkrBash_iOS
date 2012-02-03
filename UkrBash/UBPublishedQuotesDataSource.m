//
//  UBPublishedQuotesDataSource.m
//  UkrBash
//
//  Created by Maks Markovets on 19.01.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "UBPublishedQuotesDataSource.h"
#import "Model.h"

@implementation UBPublishedQuotesDataSource

- (NSArray *)items
{
    return [[Model sharedModel] publishedQuotes];
}

- (void)loadMoreItems
{
    [[Model sharedModel] loadMorePublishedQuotes];
}

@end
