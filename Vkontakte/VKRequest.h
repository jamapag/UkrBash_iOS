//
//  VKRequest.h
//  UkrBash
//
//  Created by Michail Grebionkin on 09.10.12.
//
//

#import <Foundation/Foundation.h>
#import "VKResponseParser.h"

extern NSString * VKErrorDomain;

typedef void(^VKRequestHandler) (NSString * method, NSDictionary * result, NSError * error);

typedef enum {
    VKRequestPOSTMethod,
    VKRequestGETMethod
} VKRequestMethod;

@interface VKRequest : NSObject
{
    id <VKResponseParser> responseParser;
}

@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *method;
@property (nonatomic, retain) NSDictionary *params;
@property (nonatomic) VKRequestMethod requestMethod;

- (id)initWithResponseParser:(id<VKResponseParser>)parser;
- (void)performRequestWithHandler:(VKRequestHandler)handler;

@end
