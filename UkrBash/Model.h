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

extern NSString *const kNotificationPublishedQuotesUpdated;

@interface Model : NSObject <UBRequestDelegate>
{
    NSMutableArray *publishedQuotes;
    NSMutableArray *unpablishedQuotes;
    NSMutableArray *bestQuotes;
    NSMutableArray *randomQuotes;
    NSMutableSet *requests;
}

@property (nonatomic, readonly) NSMutableArray *publishedQuotes;
@property (nonatomic, readonly) NSMutableArray *unpablishedQuotes;
@property (nonatomic, readonly) NSMutableArray *bestQuotes;
@property (nonatomic, readonly) NSMutableArray *randomQuotes;

+ (Model *)sharedModel;
- (void)loadMorePublishedQuotes;
- (void)loadMoreUnpablishedQuotes;
- (void)loadMoreBestQuotes;
- (void)loadMoreRandomQuotes;

@end
