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
#import "UBQuote.h"
#import "UBErrorsParser.h"

NSString *const kNotificationDataUpdated = @"kNotificationDataUpdated";

NSInteger const kNumberOfQuotesToLoad = 25;
NSInteger const kNumberOfPicturesToLoad = 26;


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
    UBQuotesRequest *request = [self newQuotesRequestWithMethod:kQuotes_getPublished start:[publishedQuotes count] andLimit:kNumberOfQuotesToLoad];
    [request start];
    [requests addObject:request];
    [request release];
}

- (void)loadMoreUnpablishedQuotes
{
    NSLog(@"Load more upcoming quotes");
    UBQuotesRequest *request = [self newQuotesRequestWithMethod:kQuotes_getUpcoming start:[unpablishedQuotes count] andLimit:kNumberOfQuotesToLoad];
    [request start];
    [requests addObject:request];
    [request release];
}

- (void)loadMoreBestQuotes
{
    NSLog(@"Load more best quotes");
    UBQuotesRequest *request = [self newQuotesRequestWithMethod:kQuotes_getTheBest start:[bestQuotes count] andLimit:kNumberOfQuotesToLoad];
    [request start];
    [requests addObject:request];
    [request release];
}

- (void)loadMoreRandomQuotes
{
    NSLog(@"Load more random quotes");
    UBQuotesRequest *request = [self newQuotesRequestWithMethod:kQuotes_getRandom start:[randomQuotes count] andLimit:kNumberOfQuotesToLoad];
    [request start];
    [requests addObject:request];
    [request release];
}

- (void)loadNewUnpablishedQuotes
{
    NSLog(@"Load New unpablished quotes");
    UBQuotesRequest *request = [self newQuotesRequestWithMethod:kQuotes_getUpcoming start:0 andLimit:kNumberOfQuotesToLoad];
    [request setAddToTop:YES];
    [request start];
    [requests addObject:request];
    [request release];
}

- (void)loadNewPublishedQuotes
{
    NSLog(@"Load new published quotes");
    UBQuotesRequest *request = [self newQuotesRequestWithMethod:kQuotes_getPublished start:0 andLimit:kNumberOfQuotesToLoad];
    [request setAddToTop:YES];
    [request start];
    [requests addObject:request];
    [request release];
}

- (void)loadNewBestQuotes
{
    NSLog(@"Load new published quotes");
    UBQuotesRequest *request = [self newQuotesRequestWithMethod:kQuotes_getTheBest start:0 andLimit:kNumberOfQuotesToLoad];
    [request setAddToTop:YES];
    [request start];
    [requests addObject:request];
    [request release];
}

- (void)loadNewRandomQuotes
{
    NSLog(@"Load new published quotes");
    UBQuotesRequest *request = [self newQuotesRequestWithMethod:kQuotes_getRandom start:0 andLimit:kNumberOfQuotesToLoad];
    [request setAddToTop:YES];
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
    UBImagesRequest *request = [self newPicturesRequestWithMethod:kPictures_getPublished start:[publishedImages count] andLimit:kNumberOfPicturesToLoad];
    [request start];
    [requests addObject:request];
    [request release];
}

- (void)loadMoreUnpablishedPictures
{
    NSLog(@"Load more upcoming pictures");
    UBImagesRequest *request = [self newPicturesRequestWithMethod:kPictures_getUpcoming start:[unpablishedImages count] andLimit:kNumberOfPicturesToLoad];
    [request start];
    [requests addObject:request];
    [request release];
}

- (void)loadMoreRandomPictures
{
    NSLog(@"Load more random pictures");
    UBImagesRequest *request = [self newPicturesRequestWithMethod:kPictures_getRandom start:[randomImages count] andLimit:kNumberOfPicturesToLoad];
    [request start];
    [requests addObject:request];
    [request release];
}

- (void)loadMoreBestPictures
{
    NSLog(@"Load more best pictures");
    UBImagesRequest *request = [self newPicturesRequestWithMethod:kPictures_getTheBest start:[bestImages count] andLimit:kNumberOfPicturesToLoad];
    [request start];
    [requests addObject:request];
    [request release];
}

- (void)loadNewPublishedPictures
{
    NSLog(@"Load new published pictures");
    UBImagesRequest *request = [self newPicturesRequestWithMethod:kPictures_getPublished start:0 andLimit:kNumberOfPicturesToLoad];
    [request setAddToTop:YES];
    [request start];
    [requests addObject:request];
    [request release];
}

- (void)loadNewUnpablishedPictures
{
    NSLog(@"Load new upcoming pictures");
    UBImagesRequest *request = [self newPicturesRequestWithMethod:kPictures_getUpcoming start:0 andLimit:kNumberOfPicturesToLoad];
    [request setAddToTop:YES];
    [request start];
    [requests addObject:request];
    [request release];
}

- (void)loadNewRandomPictures
{
    NSLog(@"Load new random pictures");
    UBImagesRequest *request = [self newPicturesRequestWithMethod:kPictures_getRandom start:0 andLimit:kNumberOfPicturesToLoad];
    [request setAddToTop:YES];
    [request start];
    [requests addObject:request];
    [request release];
}

- (void)loadNewBestPictures
{
    NSLog(@"Load new best pictures");
    UBImagesRequest *request = [self newPicturesRequestWithMethod:kPictures_getTheBest start:0 andLimit:kNumberOfPicturesToLoad];
    [request setAddToTop:YES];
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
    
    if (array == nil) {
        UBErrorsParser *parser = [[UBErrorsParser alloc] init];
        NSDictionary *errorDictionary = [parser parseErrorWithData:data];
        NSLog(@"Error code: %@", [errorDictionary objectForKey:@"code"]);
        [parser release];
    }
    
    if ([request.method isEqualToString:kQuotes_getPublished]) {
        if (request.addToTop) {
            [publishedQuotes removeAllObjects];
        }
        [publishedQuotes addObjectsFromArray:array];
    } else if ([request.method isEqualToString:kQuotes_getUpcoming]) {
        if (request.addToTop) {
            [unpablishedQuotes removeAllObjects];
        }
        [unpablishedQuotes addObjectsFromArray:array];
    } else if ([request.method isEqualToString:kQuotes_getTheBest]) {
        if (request.addToTop) {
            [bestQuotes removeAllObjects];
        }
        [bestQuotes addObjectsFromArray:array];
    } else if ([request.method isEqualToString:kQuotes_getRandom]) {
        if (request.addToTop) {
            [randomQuotes removeAllObjects];
        }
        [randomQuotes addObjectsFromArray:array];
    } else if ([request.method isEqualToString:kPictures_getPublished]) {
        if (request.addToTop) {
            [publishedImages removeAllObjects];
        }
        [publishedImages addObjectsFromArray:array];
    } else if ([request.method isEqualToString:kPictures_getUpcoming]) {
        if (request.addToTop) {
            [unpablishedImages removeAllObjects];
        }
        [unpablishedImages addObjectsFromArray:array];
    } else if ([request.method isEqualToString:kPictures_getRandom]) {
        if (request.addToTop) {
            [randomImages removeAllObjects];
        }
        [randomImages addObjectsFromArray:array];
    } else if ([request.method isEqualToString:kPictures_getTheBest]) {
        if (request.addToTop) {
            [bestImages removeAllObjects];
        }
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
