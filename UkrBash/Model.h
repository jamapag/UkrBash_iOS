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
    NSMutableSet *requests;
}

@property (nonatomic, readonly) NSMutableArray *publishedQuotes;

+ (Model *)sharedModel;
- (void)loadPublishedQuotes;

@end
