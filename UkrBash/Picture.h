//
//  Picture.h
//  UkrBash
//
//  Created by Maks Markovets on 06.05.14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Picture : NSManagedObject

@property (nonatomic, retain) NSNumber *pictureId;
@property (nonatomic, retain) NSNumber *status;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSDate *addDate;
@property (nonatomic, retain) NSDate *pubDate;
@property (nonatomic, retain) NSString *author;
@property (nonatomic, retain) NSNumber *authorId;
@property (nonatomic, retain) NSString *image;
@property (nonatomic, retain) NSString *thumbnail;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSNumber *rating;
@property (nonatomic, retain) NSNumber *favorite;

@end
