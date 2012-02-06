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
@synthesize unpablishedImages;
@synthesize bestImages;
@synthesize randomImages;

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
        unpablishedImages = [[NSMutableArray alloc] init];
        bestImages = [[NSMutableArray alloc] init];
        randomImages = [[NSMutableArray alloc] init];
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
    [unpablishedImages release];
    [bestImages release];
    [randomImages release];
    [super dealloc];
}

#pragma mark - Quotes Loaders

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

#pragma mark - Pictures Loaders

- (UBImagesRequest *)newPicturesRequestWithMethod:(NSString *)method start:(NSInteger)start andLimit:(NSInteger)limit
{
    UBImagesRequest *request = [[UBImagesRequest alloc] init];
    request.delegate = self;
    request.method = method;
    [request setLimit:limit];
    [request setStart:start];
    return request;
}

- (void)loadMorePublishedPictures
{
    NSLog(@"Load more published pictures");
    UBImagesRequest *request = [self newPicturesRequestWithMethod:kPictures_getPublished start:[publishedImages count] andLimit:25];
    [request start];
    [requests addObject:request];
    [request release];
}

- (void)loadMoreUnpablishedPictures
{
    NSLog(@"Load more upcoming pictures");
    UBImagesRequest *request = [self newPicturesRequestWithMethod:kPictures_getUpcoming start:[unpablishedImages count] andLimit:25];
    [request start];
    [requests addObject:request];
    [request release];
}

- (void)loadMoreRandomPictures
{
    NSLog(@"Load more random pictures");
    UBImagesRequest *request = [self newPicturesRequestWithMethod:kPictures_getRandom start:[randomImages count] andLimit:25];
    [request start];
    [requests addObject:request];
    [request release];
}

- (void)loadMoreBestPictures
{
    NSLog(@"Load more best pictures");
    UBImagesRequest *request = [self newPicturesRequestWithMethod:kPictures_getTheBest start:[bestImages count] andLimit:25];
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
    } else if ([request.method isEqualToString:kPictures_getUpcoming]) {
        [unpablishedImages addObjectsFromArray:array];
    } else if ([request.method isEqualToString:kPictures_getRandom]) {
        [randomImages addObjectsFromArray:array];
    } else if ([request.method isEqualToString:kPictures_getTheBest]) {
        [bestImages addObjectsFromArray:array];
    }

    [requests removeObject:request];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDataUpdated object:nil];
}

- (void)request:(UBRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Fail with error: %@", [error localizedDescription]);
}

@end
