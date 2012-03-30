//
//  UBUnpablishedQuotesDataSource.m
//  UkrBash
//
//  Created by Maks Markovets on 18.01.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "UBUnpablishedQuotesDataSource.h"
#import "Model.h"
#import "UBQuoteCell.h"
#import "UBQuote.h"

@implementation UBUnpablishedQuotesDataSource

- (NSArray *)items
{
    return [[Model sharedModel] unpablishedQuotes];
}

- (void)loadMoreItems
{
    [[Model sharedModel] loadMoreUnpablishedQuotes];
}

- (void)loadNewItems
{
    [[Model sharedModel] loadNewUnpablishedQuotes];
}

@end
