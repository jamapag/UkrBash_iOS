//
//  UBRequest.h
//  UkrBash
//
//  Created by Maks Markovets on 9/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UBRequest;
@protocol UBRequestDelegate <NSObject>

- (void)request:(UBRequest *)request didFinishWithData:(NSData *)data;
- (void)request:(UBRequest *)request didFailWithError:(NSError *)error;

@end

extern NSString *kAPIBaseURL;

// Methods
extern NSString *const kQuotes_getPublished;
extern NSString *const kQuotes_getUpcoming;
extern NSString *const kQuotes_getTheBest;
extern NSString *const kQuotes_getRandom;

extern NSString *const kPictures_getPublished;
extern NSString *const kPictures_getUpcoming;
extern NSString *const kPictures_getTheBest;
extern NSString *const kPictures_getRandom;

extern NSString *const kSite_getInfo;
extern NSString *const kSite_getTags;
extern NSString *const kSite_getSearch;

// Format
extern NSString *const kFormat;

// Params
extern NSString *const kClient;
extern NSString *const kStart;
extern NSString *const kLimit;
extern NSString *const kAddBefore;
extern NSString *const kAddAfter;
extern NSString *const kPubBefore;
extern NSString *const kPubAfter;
extern NSString *const kWithAuthor;
extern NSString *const kWithoutAuthor;
extern NSString *const kWithTag;
extern NSString *const kWithoutTag;
extern NSString *const kQuery;
extern NSString *const kStats;

@interface UBRequest : NSObject {
    NSURLConnection *connection;
    NSMutableData *loadedData;
    NSString *method;
    BOOL addToTop;
    NSMutableDictionary *params;
    id <UBRequestDelegate> delegate;
}

@property (nonatomic, assign) id <UBRequestDelegate> delegate;
@property (nonatomic, retain) NSString *method;
@property (nonatomic, assign) BOOL addToTop;

- (void)start;
- (void)cancel;

@end
