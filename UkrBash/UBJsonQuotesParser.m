//
//  UBJsonQuotesParser.m
//  UkrBash
//
//  Created by maks on 16.04.14.
//
//

#import "UBJsonQuotesParser.h"
#import "UBQuote.h"

@implementation UBJsonQuotesParser

static NSString *kName_Id = @"id";
static NSString *kName_Status = @"status";
static NSString *kName_Type = @"type";
static NSString *kName_AddDate = @"add_date";
static NSString *kName_PubDate = @"pub_date";
static NSString *kName_Author = @"author";
static NSString *kName_AuthorId = @"author_id";
static NSString *kName_Text = @"text";
static NSString *kName_Rating = @"rating";
__unused static NSString *kName_Tags = @"tags";

- (NSArray *)parseQuotesWithData:(NSData *)jsonData
{
    NSError *error;
    NSMutableArray *quotes = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    if ([jsonObject isKindOfClass:[NSArray class]]) {
        quotes = [[NSMutableArray alloc] init];
        // parsing quotes.
        for (NSDictionary *quoteItem in jsonObject) {
            UBQuote *quote = [[UBQuote alloc] init];
            quote.quoteId = [[quoteItem objectForKey:kName_Id] integerValue];
            quote.status = [[quoteItem objectForKey:kName_Status] integerValue];
            quote.type = [quoteItem objectForKey:kName_Type];
            quote.addDate = [NSDate dateWithTimeIntervalSince1970:[[quoteItem objectForKey:kName_AddDate] longLongValue]];
            if ([[quoteItem objectForKey:kName_PubDate] longLongValue] != 0) {
                quote.addDate = [NSDate dateWithTimeIntervalSince1970:[[quoteItem objectForKey:kName_AddDate] longLongValue]];
            }
            quote.author = [quoteItem objectForKey:kName_Author];
            quote.authorId = [[quoteItem objectForKey:kName_AuthorId] integerValue];
            quote.text = [quoteItem objectForKey:kName_Text];
            quote.rating = [[quoteItem objectForKey:kName_Rating] integerValue];
            [quotes addObject:quote];
            [quote release];
        }
    }
    return [quotes autorelease];
}

@end
