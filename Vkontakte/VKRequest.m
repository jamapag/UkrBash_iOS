//
//  VKRequest.m
//  UkrBash
//
//  Created by Michail Grebionkin on 09.10.12.
//
//

#import "VKRequest.h"

NSString * VKErrorDomain = @"VKErrorDomain";

NSString * VKConnectionErrorKey = @"VKConnectionErrorKey";
NSString * VKParserErrorKey = @"VKParserErrorKey";
NSString * VKResponseErrorMessageKey = @"VKResponseErrorMessageKey";
NSString * VKResponseErrorCodeKey = @"VKResponseErrorCodeKey";

@implementation VKRequest

@synthesize accessToken;
@synthesize params;
@synthesize method;
@synthesize requestMethod;

- (id)init
{
    self = [super init];
    if (self) {
        self.requestMethod = VKRequestGETMethod;
    }
    return self;
}

- (id)initWithResponseParser:(id<VKResponseParser>)parser
{
    self = [super init];
    if (self) {
        self.requestMethod = VKRequestGETMethod;
        responseParser = [parser retain];
    }
    return self;
}

- (void)dealloc
{
    [self.accessToken release];
    [self.params release];
    [self.method release];
    [responseParser release];
    [super dealloc];
}

- (NSString*)paramsString
{
    if (!self.params.count) {
        return nil;
    }
    NSMutableString * paramsString = [NSMutableString string];
    NSInteger i = 0;
    for (NSString * key in [self.params allKeys]) {
        id value = [self.params objectForKey:key];
        if ([value isKindOfClass:[NSNumber class]]) {
            [paramsString appendFormat:@"%@%@=%@", (i != 0 ? @"&" : @""), key, [value stringValue]];
        } else if ([value isKindOfClass:[NSString class]]) {
            [paramsString appendFormat:@"%@%@=%@", (i != 0 ? @"&" : @""), key, value];
        } else {
            NSLog(@"VKRequest Warning: unsupported request param type");
        }
        i++;
    }
    return paramsString;
}

- (NSString*)HTTPMethod
{
    if (self.requestMethod == VKRequestGETMethod) {
        return @"GET";
    }
    else if (self.requestMethod == VKRequestPOSTMethod) {
        return @"POST";
    }
    NSAssert(YES, @"Unsupported VKRequestMethod");
    return nil;
}

- (NSURL*)requestURL
{
    NSString * paramsString = [self paramsString];
    if (paramsString == nil) {
        paramsString = [NSString stringWithFormat:@"access_token=%@", self.accessToken];
    }
    else {
        paramsString = [NSString stringWithFormat:@"%@&access_token=%@", paramsString, self.accessToken];
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/%@.xml?%@", self.method, paramsString]];
}

- (void)performRequestWithHandler:(VKRequestHandler)handler
{
    NSAssert(self.accessToken != nil, @"Access token not defined");
    NSAssert(responseParser != nil, @"Response parser not defined");
    
    [[NSOperationQueue currentQueue] addOperationWithBlock:^{
        NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:[self requestURL]];
        [request setHTTPMethod:[self HTTPMethod]];
        
        NSURLResponse * response = nil;
        NSError * error = nil;
        NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        [request release];
        
        if (!data || error != nil) {
            NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                       error, VKConnectionErrorKey,
                                       @"Can't connect to VK API server.", NSLocalizedDescriptionKey,
                                       nil];
            NSError * requestError = [NSError errorWithDomain:VKErrorDomain code:1 userInfo:userInfo];
            handler(self.method, nil, requestError);
            return;
        }
        
        NSDictionary * result = [responseParser dictionaryFromData:data error:&error];
        if (error != nil) {
            NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                       error, VKParserErrorKey,
                                       @"Can't parse server response.", NSLocalizedDescriptionKey,
                                       nil];
            NSError * requestError = [NSError errorWithDomain:VKErrorDomain code:2 userInfo:userInfo];
            handler(self.method, nil, requestError);
            return;
        }
        
        if ([result objectForKey:@"error"]) {
            NSDictionary * errorObj = [result objectForKey:@"error"];
            NSString * localizedDescription = [NSString stringWithFormat:@"Error (%@): %@", [errorObj objectForKey:@"error_code"], [errorObj objectForKey:@"error_msg"]];
            NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [errorObj objectForKey:@"error_code"], VKResponseErrorCodeKey,
                                       [errorObj objectForKey:@"error_msg"], VKResponseErrorMessageKey,
                                       localizedDescription, NSLocalizedDescriptionKey,
                                       nil];
            NSError * requestError = [NSError errorWithDomain:VKErrorDomain code:3 userInfo:userInfo];
            handler(self.method, result, requestError);
            return;
        }
        
        handler(self.method, result, error);
    }];
}

@end