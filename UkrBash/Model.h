//
//  Model.h
//  UkrBash
//
//  Created by Maks Markovets on 10/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UBRequest.h"
#import "UBParser.h"

extern NSString *const kNotificationDataUpdated;

@interface Model : NSObject <UBRequestDelegate>
{
    NSMutableArray *publishedQuotes;
    NSMutableArray *unpablishedQuotes;
    NSMutableArray *bestQuotes;
    NSMutableArray *randomQuotes;
    
    NSMutableArray *publishedImages;
    NSMutableArray *unpablishedImages;
    NSMutableArray *bestImages;
    NSMutableArray *randomImages;
    
    NSMutableSet *requests;
}

@property (nonatomic, readonly) NSMutableArray *publishedQuotes;
@property (nonatomic, readonly) NSMutableArray *unpablishedQuotes;
@property (nonatomic, readonly) NSMutableArray *bestQuotes;
@property (nonatomic, readonly) NSMutableArray *randomQuotes;
@property (nonatomic, readonly) NSMutableArray *publishedImages;
@property (nonatomic, readonly) NSMutableArray *unpablishedImages;
@property (nonatomic, readonly) NSMutableArray *bestImages;
@property (nonatomic, readonly) NSMutableArray *randomImages;

+ (Model *)sharedModel;
- (void)loadMorePublishedQuotes;
- (void)loadMoreUnpablishedQuotes;
- (void)loadMoreBestQuotes;
- (void)loadMoreRandomQuotes;
- (void)loadMorePublishedPictures;
- (void)loadMoreUnpablishedPictures;
- (void)loadMoreRandomPictures;
- (void)loadMoreBestPictures;

@end
