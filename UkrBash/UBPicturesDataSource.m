//
//  UBPicturesDataSource.m
//  UkrBash
//
//  Created by Михаил Гребенкин on 03.02.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "UBPicturesDataSource.h"
#import "UBImageCell.h"
#import "UBPicture.h"

@implementation UBPicturesDataSource

- (UITableViewCell *)cellWithReuesIdentifier:(NSString *)reuseIdent
{
    return [[[UBImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdent] autorelease];
}

- (void)configureCell:(UITableViewCell *)_cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert([_cell isKindOfClass:[UBImageCell class]], @"cell should be subclass of UBImageCell class");
    
    UBImageCell *cell = (UBImageCell*)_cell;
    
    UBPicture *picture = (UBPicture *)[[self items] objectAtIndex:indexPath.row];
    cell.idLabel.text = [NSString stringWithFormat:@"%d", picture.pictureId];
    cell.quoteTextLabel.text = picture.title;
    cell.ratingLabel.text = [self ratingStringFromRating:picture.rating];
    cell.dateLabel.text = [[self dateFormatter] stringFromDate:picture.pubDate];
    cell.authorLabel.text = picture.author;
}

@end
