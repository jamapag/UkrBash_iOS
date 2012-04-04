//
//  UBQuotesRequest.m
//  UkrBash
//
//  Created by Maks Markovets on 10/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UBQuotesRequest.h"
#import "ApiKey.h"
#import "UBQuotesParser.h"

@implementation UBQuotesRequest

- (void)setLimit:(NSInteger)limit
{
    [params setObject:[NSNumber numberWithInteger:limit] forKey:kLimit];
}

- (void)setStart:(NSInteger)start
{
    [params setObject:[NSNumber numberWithInteger:start] forKey:kStart];
}

- (void)setAddAfter:(long long)addAfter
{
    [params setObject:[NSNumber numberWithLongLong:addAfter] forKey:kAddAfter];
}

- (void)setPubAfter:(long long)pubAfter
{
    [params setObject:[NSNumber numberWithLongLong:pubAfter] forKey:kPubAfter];
}

@end
