//
//  UBBestQuotesDataSource.m
//  UkrBash
//
//  Created by Maks Markovets on 19.01.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "UBBestQuotesDataSource.h"
#import "Model.h"

@implementation UBBestQuotesDataSource

- (NSArray *)getQuotes
{
    return [[Model sharedModel] bestQuotes];
}

- (void)loadMoreQuotes
{
    [[Model sharedModel] loadMoreBestQuotes];
}
@end
