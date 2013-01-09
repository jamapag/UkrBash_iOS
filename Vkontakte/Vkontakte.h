//
//  Vkontakte.h
//  UkrBash
//
//  Created by Michail Grebionkin on 04.12.12.
//
//

#import <Foundation/Foundation.h>
#import "VKResponseParser.h"
#import "VKRequest.h"

@interface Vkontakte : NSObject
{
    NSInteger _userId;
    NSString * _accessToken;
    NSDate * _expirationDate;
    id <VKResponseParser> _responseParser;
}

@property (nonatomic, readonly) NSInteger userId;
@property (nonatomic, readonly) NSString * accessToken;
@property (nonatomic, readonly) NSDate * expirationDate;

- (id)initWithAccessToken:(NSString *)accessToken expirationDate:(NSDate *)expirationDate userId:(NSInteger)userId;

- (void)invalidate;

- (void)setResponseParser:(id<VKResponseParser>)responseParser;
- (BOOL)isAuthorized;

- (void)callMethod:(NSString *)method withParams:(NSDictionary *)params handler:(VKRequestHandler)handler;
- (void)callPostMethod:(NSString *)method withParams:(NSDictionary *)params handler:(VKRequestHandler)handler;

@end
