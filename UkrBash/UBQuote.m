//
//  UBQuote.m
//  UkrBash
//
//  Created by Maks Markovets on 22.12.11.
//  Copyright (c) 2011 smile2mobile. All rights reserved.
//

#import "UBQuote.h"

@implementation UBQuote

@synthesize quoteId;
@synthesize status;
@synthesize type;
@synthesize addDate;
@synthesize pubDate;
@synthesize author;
@synthesize authorId;
@synthesize rating;
@synthesize text;
@synthesize favorite;


- (id)initWithQuote:(Quote *)quote
{
    if (self = [super init]) {
        self.quoteId = [quote.quoteId integerValue];
        self.status = [quote.status integerValue];
        self.type = quote.type;
        self.addDate = quote.addDate;
        self.pubDate = quote.pubDate;
        self.author = quote.author;
        self.authorId = [quote.authorId integerValue];
        self.rating = [quote.rating integerValue];
        self.text = quote.text;
        self.favorite = [quote.favorite boolValue];
    }
    return self;
}

- (void)dealloc
{
    [type release];
    [addDate release];
    [pubDate release];
    [author release];
    [text release];
    [super dealloc];
}

@end
