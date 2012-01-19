//
//  UBRandomQuotesDataSource.m
//  UkrBash
//
//  Created by Maks Markovets on 19.01.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "UBRandomQuotesDataSource.h"
#import "Model.h"

@implementation UBRandomQuotesDataSource

- (NSArray *)getQuotes
{
    return [[Model sharedModel] randomQuotes];
}

- (void)loadMoreQuotes
{
    [[Model sharedModel] loadMoreRandomQuotes];
}

@end
