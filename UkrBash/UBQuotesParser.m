//
//  UBQuotesParser.m
//  UkrBash
//
//  Created by Maks Markovets on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UBQuotesParser.h"
#import "GDataXMLNode.h"
#import "UBQuote.h"


@implementation UBQuotesParser

static NSString *kName_Quote = @"quote";
static NSString *kName_Id = @"id";
static NSString *kName_Status = @"status";
static NSString *kName_Type = @"type";
static NSString *kName_AddDate = @"add_date";
static NSString *kName_PubDate = @"pub_date";
static NSString *kName_Author = @"author";
static NSString *kName_AuthorId = @"author_id";
static NSString *kName_Text = @"text";
static NSString *kName_Rating = @"rating";
static NSString *kName_Tags = @"tags";

- (NSArray *)parseQuotesWithData:(NSData *)xmlData
{
    NSMutableArray *quotes = [[NSMutableArray alloc] init];
    
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:nil];
    NSArray *items = [doc nodesForXPath:@"quotes" error:nil];
    GDataXMLElement *quotesElement = [items objectAtIndex:0];
    NSArray *quotesArray = [quotesElement elementsForName:kName_Quote];
//    NSLog(@"Count: %d", [quotesArray count]);
    for (GDataXMLElement *quoteElement in quotesArray) {
        UBQuote *quote = [[UBQuote alloc] init];
        NSArray *ids = [quoteElement elementsForName:kName_Id];
        for (GDataXMLElement *quoteId in ids) {
            quote.quoteId = quoteId.stringValue.integerValue;
        }
        NSArray *statuses = [quoteElement elementsForName:kName_Status];
        for (GDataXMLElement *status in statuses) {
            quote.status = status.stringValue.integerValue;
        }
        NSArray *types = [quoteElement elementsForName:kName_Type];
        for (GDataXMLElement *type in types) {
            quote.type = type.stringValue;
        }
        NSArray *addDates = [quoteElement elementsForName:kName_AddDate];
        for (GDataXMLElement *addDate in addDates) {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:addDate.stringValue.longLongValue];
//            quote.addDate = addDate.stringValue;
            quote.addDate = date;
        }
        NSArray *pubDates = [quoteElement elementsForName:kName_PubDate];
        for (GDataXMLElement *pubDate in pubDates) {
            if (pubDate.stringValue.longLongValue != 0) {
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:pubDate.stringValue.longLongValue];
                quote.pubDate = date;
            }
        }
        NSArray *authors = [quoteElement elementsForName:kName_Author];
        for (GDataXMLElement *author in authors) {
            quote.author = author.stringValue;
        }
        NSArray *authorIds = [quoteElement elementsForName:kName_AuthorId];
        for (GDataXMLElement *authorId in authorIds) {
            quote.authorId = authorId.stringValue.integerValue;
        }
        NSArray *texts = [quoteElement elementsForName:kName_Text];
        for (GDataXMLElement *text in texts) {
            quote.text = text.stringValue;
        }
        NSArray *raings = [quoteElement elementsForName:kName_Rating];
        for (GDataXMLElement *rating in raings) {
            quote.rating = rating.stringValue.integerValue;
        }
        
        [quotes addObject:quote];
        [quote release];
    }
    [doc release];
    return [quotes autorelease];
}

@end
