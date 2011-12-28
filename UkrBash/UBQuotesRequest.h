//
//  UBQuotesRequest.h
//  UkrBash
//
//  Created by Maks Markovets on 10/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UBRequest.h"

@interface UBQuotesRequest : UBRequest


- (NSURLRequest *)createPublishedQuotesRequestWithStart:(NSInteger)start andLimit:(NSInteger)limit;
- (NSURLRequest *)createPublishedQuotesRequest;

@end
