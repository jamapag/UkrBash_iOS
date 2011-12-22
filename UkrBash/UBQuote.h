//
//  UBQuote.h
//  UkrBash
//
//  Created by Maks Markovets on 22.12.11.
//  Copyright (c) 2011 smile2mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UBQuote : NSObject
{
    NSInteger quoteId;
    NSInteger status;
    NSString *type;
    NSDate *addDate;
    NSDate *pubDate;
    NSString *author;
    NSInteger authorId;
    NSString *text;
    NSInteger rating;
}

@property (nonatomic, assign) NSInteger quoteId;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSDate *addDate;
@property (nonatomic, retain) NSDate *pubDate;
@property (nonatomic, retain) NSString *author;
@property (nonatomic, assign) NSInteger authorId;
@property (nonatomic, assign) NSInteger rating;
@property (nonatomic, retain) NSString *text;

@end
