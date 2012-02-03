//
//  UBUnpablishedQuotesDataSource.m
//  UkrBash
//
//  Created by Maks Markovets on 18.01.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "UBUnpablishedQuotesDataSource.h"
#import "Model.h"

@implementation UBUnpablishedQuotesDataSource

- (NSArray *)items
{
    return [[Model sharedModel] unpablishedQuotes];
}

- (void)loadMoreItems
{
    [[Model sharedModel] loadMoreUnpablishedQuotes];
}

@end
