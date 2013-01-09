//
//  Vkontakte.m
//  UkrBash
//
//  Created by Michail Grebionkin on 04.12.12.
//
//

#import "Vkontakte.h"

#define VK_COOKIES_DOMAIN @"vk.com"

@implementation Vkontakte

@synthesize userId = _userId;
@synthesize accessToken = _accessToken;
@synthesize expirationDate = _expirationDate;

- (id)initWithAccessToken:(NSString *)accessToken expirationDate:(NSDate *)expirationDate userId:(NSInteger)userId
{
    self = [super init];
    if (self) {
        _userId = userId;
        _accessToken = [accessToken copy];
        _expirationDate = [expirationDate copy];
    }
    return self;
}

- (void)dealloc
{
    [_accessToken release];
    [_expirationDate release];
    [_responseParser release];
    [super dealloc];
}

- (void)setResponseParser:(id<VKResponseParser>)responseParser
{
    NSParameterAssert(responseParser != nil);
    if (_responseParser) {
        [_responseParser release];
    }
    _responseParser = [responseParser retain];
}

- (void)invalidate
{
    [_accessToken release], _accessToken = nil;
    [_expirationDate release], _expirationDate = nil;
    _userId = 0;
    
    // TODO: check if cleaning cookies is necessary
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie * cookie in [storage cookies]) {
        
        NSString* domainName = [cookie domain];
        NSRange domainRange = [domainName rangeOfString:VK_COOKIES_DOMAIN];
        
        if(domainRange.location != NSNotFound) {
            [storage deleteCookie:cookie];
        }
    }
}

- (BOOL)isAuthorized
{
    return self.accessToken != nil
        && self.expirationDate != nil
        && [[NSDate date] compare:self.expirationDate] == NSOrderedDescending
        && self.userId > 0;
}

- (void)requestMethod:(NSString *)method withParams:(NSDictionary *)params isPost:(BOOL)isPost handler:(VKRequestHandler)handler
{
    VKRequest * request = [[VKRequest alloc] initWithResponseParser:_responseParser];
    request.params = params;
    request.accessToken = self.accessToken;
    request.method = method;
    request.requestMethod = isPost ? VKRequestPOSTMethod : VKRequestGETMethod;
    [request performRequestWithHandler:handler];
    [request release];
}

- (void)callMethod:(NSString *)method withParams:(NSDictionary *)params handler:(VKRequestHandler)handler
{
    [self requestMethod:method withParams:params isPost:NO handler:handler];
}

- (void)callPostMethod:(NSString *)method withParams:(NSDictionary *)params handler:(VKRequestHandler)handler
{
    [self requestMethod:method withParams:params isPost:YES handler:handler];
}

@end
