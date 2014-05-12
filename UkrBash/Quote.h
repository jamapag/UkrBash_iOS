//
//  Quote.h
//  UkrBash
//
//  Created by Maks Markovets on 23.04.14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Quote : NSManagedObject

@property (nonatomic, retain) NSNumber *status;
@property (nonatomic, retain) NSString *author;
@property (nonatomic, retain) NSNumber *rating;
@property (nonatomic, retain) NSNumber *authorId;
@property (nonatomic, retain) NSNumber *favorite;
@property (nonatomic, retain) NSDate *addDate;
@property (nonatomic, retain) NSDate *pubDate;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSNumber *quoteId;
@property (nonatomic, retain) NSString *text;

@end
