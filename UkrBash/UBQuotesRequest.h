//
//  UBQuotesRequest.h
//  UkrBash
//
//  Created by Maks Markovets on 10/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UBRequest.h"

@interface UBQuotesRequest : UBRequest

- (void)startWithNSURLRequest:(NSURLRequest *)request;
- (NSURLRequest *)createPublishedQuotesRequest;

@end
