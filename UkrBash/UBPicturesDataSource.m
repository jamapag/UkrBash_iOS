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
#import "Picture.h"
#import "MediaCenter.h"

@implementation UBPicturesDataSource

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self items] objectAtIndex:indexPath.row];
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    return [[self items] count];
}

- (UITableViewCell *)cellWithReuesIdentifier:(NSString *)reuseIdent
{
    return [[[UBPictureCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdent] autorelease];
}

- (void)configureCell:(UITableViewCell *)_cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert([_cell isKindOfClass:[UBPictureCell class]], @"cell should be subclass of UBImageCell class");
    
    UBPictureCell *cell = (UBPictureCell*)_cell;
    
    UBPicture *picture = (UBPicture *)[[self items] objectAtIndex:indexPath.row];
    cell.idLabel.text = [NSString stringWithFormat:@"%ld", (long)picture.pictureId];
    cell.quoteTextLabel.text = picture.title;
    cell.ratingLabel.text = [self ratingStringFromRating:picture.rating];
    if (picture.pubDate) {
        cell.dateLabel.text = [[self dateFormatter] stringFromDate:picture.pubDate];
    } else {
        cell.dateLabel.text = [[self dateFormatter] stringFromDate:picture.addDate];
    }
    cell.authorLabel.text = picture.author;
    cell.imageView.image = [[MediaCenter imageCenter] imageWithUrl:picture.thumbnail];
}

- (void)configurePictureInfoView:(UBPictureInfoView *)infoView forRowAtIndexPath:(NSIndexPath *)indexPath
{
    id picture = [self objectAtIndexPath:indexPath];
    if ([picture isKindOfClass:[UBPicture class]]) {
        UBPicture *ubPicture = (UBPicture *)picture;
        infoView.idLabel.text = [NSString stringWithFormat:@"%ld", (long)ubPicture.pictureId];
        infoView.textLabel.text = ubPicture.title;
        infoView.ratingLabel.text = [self ratingStringFromRating:ubPicture.rating];
        infoView.dateLabel.text = [[self dateFormatter] stringFromDate:ubPicture.addDate];
        infoView.authorLabel.text = ubPicture.author;
    } else if ([picture isKindOfClass:[Picture class]]) {
        Picture *cdPicture = (Picture *)picture;
        infoView.idLabel.text = [NSString stringWithFormat:@"%ld", [cdPicture.pictureId longValue]];
        infoView.textLabel.text = cdPicture.title;
        infoView.ratingLabel.text = [self ratingStringFromRating:[cdPicture.rating integerValue]];
        infoView.dateLabel.text = [[self dateFormatter] stringFromDate:cdPicture.addDate];
        infoView.authorLabel.text = cdPicture.author;
    }
    
    infoView.textLabel.font = GET_FONT();
}

@end
