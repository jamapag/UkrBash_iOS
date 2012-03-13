//
//  UBPicturesDataSource.m
//  UkrBash
//
//  Created by Михаил Гребенкин on 03.02.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "UBPicturesDataSource.h"
#import "UBPictureCell.h"
#import "UBPicture.h"
#import "MediaCenter.h"

@implementation UBPicturesDataSource

- (UITableViewCell *)cellWithReuesIdentifier:(NSString *)reuseIdent
{
    return [[[UBPictureCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdent] autorelease];
}

- (void)configureCell:(UITableViewCell *)_cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert([_cell isKindOfClass:[UBPictureCell class]], @"cell should be subclass of UBImageCell class");
    
    UBPictureCell *cell = (UBPictureCell*)_cell;
    
    UBPicture *picture = (UBPicture *)[[self items] objectAtIndex:indexPath.row];
    cell.idLabel.text = [NSString stringWithFormat:@"%d", picture.pictureId];
    cell.quoteTextLabel.text = picture.title;
    cell.ratingLabel.text = [self ratingStringFromRating:picture.rating];
    cell.dateLabel.text = [[self dateFormatter] stringFromDate:picture.pubDate];
    cell.authorLabel.text = picture.author;
    cell.imageView.image = [[MediaCenter imageCenter] imageWithUrl:picture.thumbnail];
}

@end
