//
//  UBQuotesRequest.h
//  UkrBash
//
//  Created by Maks Markovets on 10/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UBRequest.h"

@interface UBQuotesRequest : UBRequest

- (void)setLimit:(NSInteger)limit;
- (void)setStart:(NSInteger)start;
- (void)setAddAfter:(long long)addAfter;
- (void)setPubAfter:(long long)pubAfter;

@end
