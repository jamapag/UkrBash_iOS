//
//  UBRequest.m
//  UkrBash
//
//  Created by Maks Markovets on 9/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UBRequest.h"
#import "UBQuotesParser.h"
#import "ApiKey.h"

@implementation UBRequest

@synthesize delegate;
@synthesize method;

// Sample http://api.ukrbash.org/1/quotes.getPublished.xml?client=apiKey
// Base API Url
const NSString *kAPIBaseURL = @"http://api.ukrbash.org/1/";

// Methods
NSString *const kQuotes_getPublished = @"quotes.getPublished";
NSString *const kQuotes_getUpcoming = @"quotes.getUpcoming";
NSString *const kQuotes_getTheBest = @"quotes.getTheBest";
NSString *const kQuotes_getRandom = @"quotes.getRandom";

NSString *const kPictures_getPublished = @"pictures.getPublished";
NSString *const kPictures_getUpcoming = @"pictures.getUpcoming";
NSString *const kPictures_getTheBest = @"pictures.getTheBest";
NSString *const kPictures_getRandom = @"pictures.getRandom";

NSString *const kSite_getInfo = @"site.getInfo";
NSString *const kSite_getTags = @"site.getTags";
NSString *const kSite_getSearch = @"site.getSearch";

// Format
NSString *const kFormat = @".xml";

// Params
NSString *const kClient = @"client";
NSString *const kStart = @"start";
NSString *const kLimit = @"limit";
NSString *const kAddBefore = @"addBefore";
NSString *const kAddAfter = @"addAfter";
NSString *const kPubBefore = @"pubBefore";
NSString *const kPubAfter = @"pubAfter";
NSString *const kWithAuthor = @"withAuthor";
NSString *const kWithoutAuthor = @"withoutAuthor";
NSString *const kWithTag = @"withTag";
NSString *const kWithoutTag = @"withoutTag";
NSString *const kQuery = @"query";
NSString *const kStats = @"stats";

- (id)init
{
    self = [super init];
    if (self) {
        params = [[NSMutableDictionary alloc] init];
        [params setObject:kApiKey forKey:kClient];
    }
    return self;
}

- (void)dealloc {
    [params release];
    [loadedData release];
    delegate = nil;
    [connection release];
    [method release];
    [super dealloc];
}

- (NSURLRequest *)generateNSURLRequest
{
    NSMutableURLRequest *request = nil;
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", kAPIBaseURL, method, kFormat];
    NSString *paramsSting = @"";
    BOOL first = YES;
    for (NSString *key in params) {
        if (first) {
            paramsSting = [paramsSting stringByAppendingFormat:@"?%@=%@", key, [params objectForKey:key]];
            first = NO;
        } else {
            paramsSting = [paramsSting stringByAppendingFormat:@"&%@=%@", key, [params objectForKey:key]];            
        }
    }
    urlString = [urlString stringByAppendingString:paramsSting];
    NSLog(@"URL: %@", urlString);
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    return [request autorelease];
}

- (void)start
{
    connection = [[NSURLConnection alloc] initWithRequest:[self generateNSURLRequest] delegate:self];
    [connection start];
}

- (void)cancel
{
    [connection cancel];
    [connection release];
    connection = nil;
}

#pragma mark -


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.delegate request:self didFailWithError:error];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//    NSLog(@"Connection did finish loading");
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(request:didFinishWithData:)]) {
        [delegate request:self didFinishWithData:loadedData];
    }
//    NSString *dataString = [[NSString alloc] initWithData:loadedData encoding:NSUTF8StringEncoding];
//    NSLog(@"DATA: %@", dataString);
    return;
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//    NSLog(@"Connection Did Receive data");
    [loadedData appendData:data];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    // TODO: check status code;
//    responseHTTPStatusCode = [response statusCode];
//    NSLog(@"Connectin Did Receive response");
    if (!loadedData) {
        loadedData = [[NSMutableData alloc] init];
    } else {
        [loadedData setLength:0];
    }
}
@end
