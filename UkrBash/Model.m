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
#import "UBImagesRequest.h"

NSString *const kNotificationPublishedQuotesUpdated = @"kNotificationPublishedQuotesUpdated";

@implementation Model

@synthesize publishedQuotes;
@synthesize unpablishedQuotes;
@synthesize bestQuotes;
@synthesize randomQuotes;
@synthesize publishedImages;

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
        unpablishedQuotes = [[NSMutableArray alloc] init];
        bestQuotes = [[NSMutableArray alloc] init];
        randomQuotes = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc 
{
    [publishedQuotes release];
    [unpablishedQuotes release];
    [bestQuotes release];
    [requests release];
    [randomQuotes release];
    [publishedImages release];
    [super dealloc];
}

- (UBQuotesRequest *)createQuotesRequestWithMethod:(NSString *)method start:(NSInteger)start andLimit:(NSInteger)limit
{
    UBQuotesRequest *request = [[UBQuotesRequest alloc] init];
    request.delegate = self;
    request.method = method;
    [request setLimit:limit];
    [request setStart:start];
    return request;
}

- (void)loadMorePublishedQuotes
{
    NSLog(@"Load more published quotes");
    UBQuotesRequest *request = [self createQuotesRequestWithMethod:kQuotes_getPublished start:[publishedQuotes count] andLimit:25];
    [request start];
    [requests addObject:request];
    [request release];
}

- (void)loadMoreUnpablishedQuotes
{
    NSLog(@"Load more upcoming quotes");
    UBQuotesRequest *request = [self createQuotesRequestWithMethod:kQuotes_getUpcoming start:[unpablishedQuotes count] andLimit:25];
    [request start];
    [requests addObject:request];
    [request release];
}

- (void)loadMoreBestQuotes
{
    NSLog(@"Load more best quotes");
    UBQuotesRequest *request = [self createQuotesRequestWithMethod:kQuotes_getTheBest start:[bestQuotes count] andLimit:25];
    [request start];
    [requests addObject:request];
    [request release];
}

- (void)loadMoreRandomQuotes
{
    NSLog(@"Load more random quotes");
    UBQuotesRequest *request = [self createQuotesRequestWithMethod:kQuotes_getRandom start:[randomQuotes count] andLimit:25];
    [request start];
    [requests addObject:request];
    [request release];
}

- (void)loadMoreImages
{
    NSLog(@"Load more images");
    UBImagesRequest *request = [[UBImagesRequest alloc] init];
    request.delegate = self;
    request.method = kPictures_getPublished;
    [request setLimit:25];
    [request setStart:0];
    [requests addObject:request];
    [request release];
}

#pragma mark - UBQuotesRequestDelegate
- (void)request:(UBRequest *)request didFinishWithData:(NSData *)data
{
    NSLog(@"Did finish with data");
    // TODO: Add errors parser
    UBQuotesParser *parser = [[UBQuotesParser alloc] init];
    NSArray *array = [parser parseQuotesWithData:data];
    if ([request.method isEqualToString:kQuotes_getPublished]) {
        [publishedQuotes addObjectsFromArray:array];
    } else if ([request.method isEqualToString:kQuotes_getUpcoming]) {
        [unpablishedQuotes addObjectsFromArray:array];
    } else if ([request.method isEqualToString:kQuotes_getTheBest]) {
        [bestQuotes addObjectsFromArray:array];
    } else if ([request.method isEqualToString:kQuotes_getRandom]) {
        [randomQuotes addObjectsFromArray:array];
    } else if ([request.method isEqualToString:kPictures_getPublished]) {
        [publishedImages addObjectsFromArray:array];
    }
    [parser release];
    [requests removeObject:request];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPublishedQuotesUpdated object:nil];
}

- (void)request:(UBRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Fail with error: %@", [error localizedDescription]);
}

@end
