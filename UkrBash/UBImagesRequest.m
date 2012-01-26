//
//  UBImagesRequest.m
//  UkrBash
//
//  Created by Maks Markovets on 20.01.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "UBImagesRequest.h"

@implementation UBImagesRequest

- (void)setLimit:(NSInteger)limit
{
    [params setObject:[NSNumber numberWithInteger:limit] forKey:kLimit];
}

- (void)setStart:(NSInteger)start
{
    [params setObject:[NSNumber numberWithInteger:start] forKey:kStart];
}

@end
