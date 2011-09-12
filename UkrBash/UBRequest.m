//
//  UBRequest.m
//  UkrBash
//
//  Created by Maks Markovets on 9/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UBRequest.h"


@implementation UBRequest

// Base API Url
static NSString *kAPIBaseURL = @"http://api.ukrbash.org/1/";

// Methods
static NSString *kQuotes_getPublished = @"quotes.getPublished";
static NSString *kQuotes_getUpcoming = @"quotes.getUpcoming";
static NSString *kQuotes_getTheBest = @"quotes.getTheBest";
static NSString *kQuotes_getRandom = @"quotes.getRandom";

static NSString *kPictures_getPublished = @"pictures.getPublished";
static NSString *kPictures_getUpcoming = @"pictures.getUpcoming";
static NSString *kPictures_getTheBest = @"pictures.getTheBest";
static NSString *kPictures_getRandom = @"pictures.getRandom";

static NSString *kSite_getInfo = @"site.getInfo";
static NSString *kSite_getTags = @"site.getTags";
static NSString *kSite_getSearch = @"site.getSearch";

// Format
static NSString *kFormat = @".xml";

// Params
static NSString *kClient = @"client";
static NSString *kStart = @"start";
static NSString *kLimit = @"limit";
static NSString *kAddBefore = @"addBefore";
static NSString *kAddAfter = @"addAfter";
static NSString *kPubBefore = @"pubBefore";
static NSString *kPubAfter = @"pubAfter";
static NSString *kWithAuthor = @"withAuthor";
static NSString *kWithoutAuthor = @"withoutAuthor";
static NSString *kWithTag = @"withTag";
static NSString *kWithoutTag = @"withoutTag";
static NSString *kQuery = @"query";
static NSString *kStats = @"stats";

- (void)start {
    connection = [[NSURLConnection alloc] initWithRequest:[self URLRequest] delegate:self];
    [connection start];
}

- (void)cancel {
    [connection cancel];
    [connection release];
    connection = nil;
}

- (NSURLRequest*)URLRequest {
    return nil;
}




@end
