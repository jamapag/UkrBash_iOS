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

- (void)startWithNSURLRequest:(NSURLRequest *)request
{
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
}

- (NSURLRequest *)createPublishedQuotesRequest
{
    method = [[NSString alloc] initWithString:kQuotes_getPublished];
    NSMutableURLRequest *request = nil;
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", kAPIBaseURL, kQuotes_getPublished, kFormat];
    NSString *params = [NSString stringWithFormat:@"?%@=%@", kClient, kApiKey];
    urlString = [urlString stringByAppendingString:params];
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];

    return [request autorelease];
}

#pragma -
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(request:didFinishWithData:)]) {
        [delegate request:self didFinishWithData:loadedData];
    }
}

@end
