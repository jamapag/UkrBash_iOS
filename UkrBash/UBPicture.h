//
//  UBPicture.h
//  UkrBash
//
//  Created by Maks Markovets on 26.01.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UBPicture : NSObject
{
    NSInteger pictureId; // ID картинки
    NSInteger status; // 1 – неопублікована, 2 — опублікована, 0 — видалена
    NSString *type; // picture
    NSDate *addDate; // дата додавання, unix time
    NSDate *pubDate; // дата публікації, unix time, 0 якщо status=1
    NSString *author; // login або анонім
    NSInteger authorId; // ID автора, 0 якщо анонім
    NSString *image; // картинка 400х400
    NSString *thumbnail; // картинка 150х150
    NSString *title; // назва картинки
    NSInteger rating; // рейтинг
    BOOL favorite;
}

@property (nonatomic, assign) NSInteger pictureId;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSDate *addDate;
@property (nonatomic, retain) NSDate *pubDate;
@property (nonatomic, retain) NSString *author;
@property (nonatomic, assign) NSInteger authorId;
@property (nonatomic, retain) NSString *image;
@property (nonatomic, retain) NSString *thumbnail;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, assign) NSInteger rating;
@property (nonatomic, assign) BOOL favorite;

@end
