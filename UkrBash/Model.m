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
#import "UBPicturesParser.h"
#import "UBImagesRequest.h"

NSString *const kNotificationDataUpdated = @"kNotificationDataUpdated";

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
        publishedImages = [[NSMutableArray alloc] init];
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

- (UBQuotesRequest *)newQuotesRequestWithMethod:(NSString *)method start:(NSInteger)start andLimit:(NSInteger)limit
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
    UBQuotesRequest *request = [self newQuotesRequestWithMethod:kQuotes_getPublished start:[publishedQuotes count] andLimit:25];
    [request start];
    [requests addObject:request];
    [request release];
}

- (void)loadMoreUnpablishedQuotes
{
    NSLog(@"Load more upcoming quotes");
    UBQuotesRequest *request = [self newQuotesRequestWithMethod:kQuotes_getUpcoming start:[unpablishedQuotes count] andLimit:25];
    [request start];
    [requests addObject:request];
    [request release];
}

- (void)loadMoreBestQuotes
{
    NSLog(@"Load more best quotes");
    UBQuotesRequest *request = [self newQuotesRequestWithMethod:kQuotes_getTheBest start:[bestQuotes count] andLimit:25];
    [request start];
    [requests addObject:request];
    [request release];
}

- (void)loadMoreRandomQuotes
{
    NSLog(@"Load more random quotes");
    UBQuotesRequest *request = [self newQuotesRequestWithMethod:kQuotes_getRandom start:[randomQuotes count] andLimit:25];
    [request start];
    [requests addObject:request];
    [request release];
}

- (void)loadMorePublishedPictures
{
    NSLog(@"Load more pictures");
    UBImagesRequest *request = [[UBImagesRequest alloc] init];
    request.delegate = self;
    request.method = kPictures_getPublished;
    [request setLimit:25];
    [request setStart:[publishedImages count]];
    [request start];
    [requests addObject:request];
    [request release];
}

#pragma mark - UBQuotesRequestDelegate
- (void)request:(UBRequest *)request didFinishWithData:(NSData *)data
{
    NSLog(@"Did finish with data");
    // TODO: Add errors parser
    NSArray *array = nil;
    if ([request isKindOfClass:[UBQuotesRequest class]]) {
        UBQuotesParser *parser = [[UBQuotesParser alloc] init];
        array = [parser parseQuotesWithData:data];
        [parser release];
    } else {
        UBPicturesParser *parser = [[UBPicturesParser alloc] init];
        array = [parser parsePicturesWithData:data];
        [parser release];
    }
    
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

    [requests removeObject:request];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDataUpdated object:nil];
}

- (void)request:(UBRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Fail with error: %@", [error localizedDescription]);
}

@end
