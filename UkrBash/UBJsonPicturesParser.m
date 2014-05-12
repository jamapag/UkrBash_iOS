//
//  UBJsonPicturesParser.m
//  UkrBash
//
//  Created by maks on 16.04.14.
//
//

#import "UBJsonPicturesParser.h"
#import "UBPicture.h"

@implementation UBJsonPicturesParser

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


- (NSArray *)parsePicturesWithData:(NSData *)jsonData
{
    NSError *error;
    NSMutableArray *pictures = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    if ([jsonObject isKindOfClass:[NSArray class]]) {
        pictures = [[NSMutableArray alloc] init];
        // parsing quotes.
        for (NSDictionary *pictureItem in jsonObject) {
            UBPicture *picture = [[UBPicture alloc] init];
            picture.pictureId = [[pictureItem objectForKey:kName_Id] integerValue];
            picture.status = [[pictureItem objectForKey:kName_Status] integerValue];
            picture.type = [pictureItem objectForKey:kName_Type];
            picture.addDate = [NSDate dateWithTimeIntervalSince1970:[[pictureItem objectForKey:kName_AddDate] longLongValue]];
            if ([[pictureItem objectForKey:kName_PubDate] longLongValue] != 0) {
                picture.addDate = [NSDate dateWithTimeIntervalSince1970:[[pictureItem objectForKey:kName_AddDate] longLongValue]];
            }
            picture.author = [pictureItem objectForKey:kName_Author];
            picture.authorId = [[pictureItem objectForKey:kName_AuthorId] integerValue];
            picture.image = [pictureItem objectForKey:kName_Image];
            picture.thumbnail = [pictureItem objectForKey:kName_Thumbnail];
            picture.title = [pictureItem objectForKey:kName_Title];
            picture.rating = [[pictureItem objectForKey:kName_Rating] integerValue];
            [pictures addObject:picture];
            [picture release];
        }
    }
    return [pictures autorelease];
}

@end
