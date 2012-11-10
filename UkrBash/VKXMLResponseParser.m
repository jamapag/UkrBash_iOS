//
//  VKXMLResponseParser.m
//  UkrBash
//
//  Created by Michail Grebionkin on 10.10.12.
//
//

#import "VKXMLResponseParser.h"
#import "GDataXMLNode.h"

@implementation VKXMLResponseParser

- (NSString *)stringFromXMLElement:(GDataXMLElement *)element forName:(NSString *)name
{
    return [[[element elementsForName:name] objectAtIndex:0] stringValue];
}

- (NSDictionary *)responseDictionary:(GDataXMLElement *)rootElement error:(NSError **)error
{
    NSMutableDictionary * result = [NSMutableDictionary dictionary];
    
    
    
    
//    GDataXMLNode * node = [[document nodesForXPath:@"response" error:error] objectAtIndex:0];
    return [NSDictionary dictionaryWithObject:result forKey:@"response"];
}

- (NSDictionary *)errorDictionary:(GDataXMLElement *)rootElement error:(NSError **)error
{
    NSMutableDictionary * result = [NSMutableDictionary dictionary];
    
    [result setObject:[self stringFromXMLElement:rootElement forName:@"error_code"] forKey:@"error_code"];
    [result setObject:[self stringFromXMLElement:rootElement forName:@"error_msg"] forKey:@"error_msg"];

    NSMutableArray * request_params = [NSMutableArray array];
    
    NSArray * requestParams = [rootElement elementsForName:@"request_params"];
    for (GDataXMLElement * requestParam in requestParams) {
        NSArray * params = [requestParam elementsForName:@"param"];
        for (GDataXMLElement * param in params) {
            NSString * key = [self stringFromXMLElement:param forName:@"key"];
            NSString * value = [self stringFromXMLElement:param forName:@"value"];
            [request_params addObject:[NSDictionary dictionaryWithObject:value forKey:key]];
        }
    }
    [result setObject:request_params forKey:@"request_params"];

    return [NSDictionary dictionaryWithObject:result forKey:@"error"];
}

- (NSDictionary *)dictionaryFromData:(NSData *)data error:(NSError **)error
{
    NSDictionary * result = nil;
    GDataXMLDocument * doc = [[GDataXMLDocument alloc] initWithData:data options:0 error:nil];
    GDataXMLElement * rootElement = [doc rootElement];
    if ([rootElement.name isEqualToString:@"response"]) {
        result = [self responseDictionary:rootElement error:error];
    }
    else if ([rootElement.name isEqualToString:@"error"]) {
        result = [self errorDictionary:rootElement error:error];
    }
    else {
        NSAssert(YES, @"Unsupport XML structure of XML VK response.");
    }
    
    [doc release];
    return result;
}

@end
