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

- (NSArray *)getQuotes
{
    return [[Model sharedModel] publishedQuotes];
}

- (void)loadMoreQuotes
{
    [[Model sharedModel] loadMorePublishedQuotes];
}

@end
