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

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self items] objectAtIndex:indexPath.row];
}

- (UITableViewCell *)cellWithReuesIdentifier:(NSString *)reuseIdent
{
    return [[[UBQuoteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdent] autorelease];
}

- (void)configureCell:(UITableViewCell *)_cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert([_cell isKindOfClass:[UBQuoteCell class]], @"cell should be subclass of UBQuoteCell class");
    
    UBQuoteCell *cell = (UBQuoteCell*)_cell;
    
    UBQuote *quote = (UBQuote *)[[self items] objectAtIndex:indexPath.row];
    cell.idLabel.text = [NSString stringWithFormat:@"%ld", (long)quote.quoteId];
    cell.quoteTextLabel.text = quote.text;
    cell.ratingLabel.text = [self ratingStringFromRating:quote.rating];
    if (quote.pubDate) {
        cell.dateLabel.text = [[self dateFormatter] stringFromDate:quote.pubDate];        
    } else {
        cell.dateLabel.text = [[self dateFormatter] stringFromDate:quote.addDate];
    }
    
    if (quote.favorite) {
        [cell.favoriteButton setImage:[UIImage imageNamed:@"favorite_active"] forState:UIControlStateNormal];
    } else {
        [cell.favoriteButton setImage:[UIImage imageNamed:@"favorite"] forState:UIControlStateNormal];
    }

    cell.authorLabel.text = quote.author;
}

@end
