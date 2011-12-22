//
//  Model.m
//  UkrBash
//
//  Created by Maks Markovets on 10/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Model.h"
#import "UBQuotesRequest.h"
#import "UBQuotesParser.h"

NSString *const kNotificationPublishedQuotesUpdated = @"kNotificationPublishedQuotesUpdated";

@implementation Model

@synthesize publishedQuotes;

static Model *sharedModel = nil;

+ (Model *)sharedModel
{
    @synchronized(self) {
        if (sharedModel == nil) {
            sharedModel = [[self alloc] init];
        }
    }
    return sharedModel;
}

- (id)init
{
    self = [super init];
    if (self) {
        requests = [[NSMutableSet alloc] init];
        publishedQuotes = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc 
{
    [publishedQuotes release];
    [super dealloc];
}


- (void)loadPublishedQuotes
{
    UBQuotesRequest *request = [[UBQuotesRequest alloc] init];
    request.delegate = self;
    [request startWithNSURLRequest:[request createPublishedQuotesRequest]];
    [requests addObject:request];
    [request release];
}

#pragma mark - UBQuotesRequestDelegate
- (void)request:(UBRequest *)request didFinishWithData:(NSData *)data
{
    // if request is quotes request && request type == published quotes -> then 
    UBQuotesParser *parser = [[UBQuotesParser alloc] init];
    NSArray *array = [parser parseQuotesWithData:data];
    if ([request.method isEqualToString:kQuotes_getPublished]) {
        [publishedQuotes addObjectsFromArray:array];
    }
    [parser release];
    [requests removeObject:request];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPublishedQuotesUpdated object:nil];
    // TODO: send notification about new quotes
}

- (void)request:(UBRequest *)request didFinishWithError:(NSError *)error
{
}

@end
