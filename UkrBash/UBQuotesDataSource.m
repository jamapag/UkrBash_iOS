//
//  UBQuotesDataSource.m
//  UkrBash
//
//  Created by Михаил Гребенкин on 03.02.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "UBQuotesDataSource.h"
#import "UBQuote.h"
#import "UBQuoteCell.h"

@implementation UBQuotesDataSource

- (UITableViewCell *)cellWithReuesIdentifier:(NSString *)reuseIdent
{
    return [[[UBQuoteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdent] autorelease];
}

- (void)configureCell:(UITableViewCell *)_cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert([_cell isKindOfClass:[UBQuoteCell class]], @"cell should be subclass of UBQuoteCell class");
    
    UBQuoteCell *cell = (UBQuoteCell*)_cell;
    
    UBQuote *quote = (UBQuote *)[[self items] objectAtIndex:indexPath.row];
    cell.idLabel.text = [NSString stringWithFormat:@"%d", quote.quoteId];
    cell.quoteTextLabel.text = quote.text;
    cell.ratingLabel.text = [self ratingStringFromRating:quote.rating];
    cell.dateLabel.text = [[self dateFormatter] stringFromDate:quote.pubDate];
    cell.authorLabel.text = quote.author;
}

@end
