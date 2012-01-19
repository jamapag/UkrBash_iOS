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

- (NSArray *)getQuotes
{
    return [[Model sharedModel] unpablishedQuotes];
}

- (void)loadMoreQuotes
{
    [[Model sharedModel] loadMoreUnpablishedQuotes];
}

@end
