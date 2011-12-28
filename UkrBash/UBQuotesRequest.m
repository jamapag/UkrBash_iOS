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

- (NSURLRequest *)createPublishedQuotesRequestWithStart:(NSInteger)start andLimit:(NSInteger)limit
{
    method = [[NSString alloc] initWithString:kQuotes_getPublished];
    NSMutableURLRequest *request = nil;
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", kAPIBaseURL, kQuotes_getPublished, kFormat];
    NSString *params = [NSString stringWithFormat:@"?%@=%@&%@=%d&%@=%d", kClient, kApiKey, kStart, start, kLimit, limit];
    urlString = [urlString stringByAppendingString:params];
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    return [request autorelease];
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

@end
