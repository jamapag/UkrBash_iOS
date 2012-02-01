//
//  UBPicturesParser.m
//  UkrBash
//
//  Created by Maks Markovets on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UBPicturesParser.h"
#import "GDataXMLNode.h"
#import "UBPicture.h"


@implementation UBPicturesParser

static NSString *kName_Picture = @"picture";
static NSString *kName_Id = @"id";
static NSString *kName_Status = @"status";
static NSString *kName_Type = @"type";
static NSString *kName_AddDate = @"add_date";
static NSString *kName_PubDate = @"pub_date";
static NSString *kName_Author = @"author";
static NSString *kName_AuthorId = @"author_id";
static NSString *kName_Image = @"image";
static NSString *kName_Thumbnail = @"thumbnail";
static NSString *kName_Title = @"title";
static NSString *kName_Rating = @"rating";

- (NSArray *)parsePicturesWithData:(NSData *)xmlData
{
    NSMutableArray *pictures = [[NSMutableArray alloc] init];
    
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:nil];
    NSArray *items = [doc nodesForXPath:@"pictures" error:nil];
    GDataXMLElement *picturesElement = [items objectAtIndex:0];
    NSArray *picturesArray = [picturesElement elementsForName:kName_Picture];
    
    NSLog(@"Count: %d", [picturesArray count]);
    
    for (GDataXMLElement *pictureElement in picturesArray) {
        UBPicture *picture = [[UBPicture alloc] init];
        NSArray *ids = [pictureElement elementsForName:kName_Id];
        for (GDataXMLElement *pictureId in ids) {
            picture.pictureId = pictureId.stringValue.integerValue;
        }
        NSArray *statuses = [pictureElement elementsForName:kName_Status];
        for (GDataXMLElement *status in statuses) {
            picture.status = status.stringValue.integerValue;
        }
        NSArray *types = [pictureElement elementsForName:kName_Type];
        for (GDataXMLElement *type in types) {
            picture.type = type.stringValue;
        }
        NSArray *addDates = [pictureElement elementsForName:kName_AddDate];
        for (GDataXMLElement *addDate in addDates) {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:addDate.stringValue.longLongValue];
            //            quote.addDate = addDate.stringValue;
            picture.addDate = date;
        }
        NSArray *pubDates = [pictureElement elementsForName:kName_PubDate];
        for (GDataXMLElement *pubDate in pubDates) {
            if (pubDate.stringValue.longLongValue != 0) {
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:pubDate.stringValue.longLongValue];
                picture.pubDate = date;
            }
        }
        NSArray *authors = [pictureElement elementsForName:kName_Author];
        for (GDataXMLElement *author in authors) {
            picture.author = author.stringValue;
        }
        NSArray *authorIds = [pictureElement elementsForName:kName_AuthorId];
        for (GDataXMLElement *authorId in authorIds) {
            picture.authorId = authorId.stringValue.integerValue;
        }
        NSArray *images = [pictureElement elementsForName:kName_Image];
        for (GDataXMLElement *image in images) {
            picture.image = image.stringValue;
        }
        NSArray *thumbnails = [pictureElement elementsForName:kName_Thumbnail];
        for (GDataXMLElement *thumbnail in thumbnails) {
            picture.thumbnail = thumbnail.stringValue;
        }
        NSArray *titles = [pictureElement elementsForName:kName_Title];
        for (GDataXMLElement *title in titles) {
            picture.title = title.stringValue;
        }
        NSArray *raings = [pictureElement elementsForName:kName_Rating];
        for (GDataXMLElement *rating in raings) {
            picture.rating = rating.stringValue.integerValue;
        }
        
        [pictures addObject:picture];
        [picture release];
    }
    [doc release];
    return [pictures autorelease];
}

@end
