//
//  UBPicture.m
//  UkrBash
//
//  Created by Maks Markovets on 26.01.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "UBPicture.h"

@implementation UBPicture

@synthesize pictureId;
@synthesize status;
@synthesize type;
@synthesize addDate;
@synthesize pubDate;
@synthesize author;
@synthesize authorId;
@synthesize image;
@synthesize thumbnail;
@synthesize title;
@synthesize rating;
@synthesize favorite;

- (void)dealloc
{
    [type release];
    [addDate release];
    [pubDate release];
    [author release];
    [image release];
    [thumbnail release];
    [title release];
    [super dealloc];
}

@end
