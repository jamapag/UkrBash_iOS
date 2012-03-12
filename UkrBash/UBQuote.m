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
