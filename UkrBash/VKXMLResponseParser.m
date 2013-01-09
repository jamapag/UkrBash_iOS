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

- (BOOL)hasChildElements:(GDataXMLElement *)element
{
    if (element.childCount == 1 && [[element.children objectAtIndex:0] kind] == GDataXMLTextKind) {
        return NO;
    }
    return element.childCount > 0;
}

- (BOOL)isList:(GDataXMLElement *)element
{
    GDataXMLNode * attrib = [element attributeForName:@"list"];
    if (attrib && [attrib.stringValue isEqualToString:@"true"]) {
        return YES;
    }
    return NO;
}

- (NSUInteger)getListCount:(GDataXMLElement *)listElement
{
    NSArray * countElements = [listElement elementsForName:@"count"];
    if (countElements.count == 0) {
        return 0;
    }
    NSInteger count = [[[countElements objectAtIndex:0] stringValue] integerValue];
    return count < 0 ? NSUIntegerMax : count;
}

- (NSDictionary *)dictionaryFromElement:(GDataXMLElement *)element
{
    if ([self isList:element]) {
        return [self dictionaryFromListElement:element];
    }
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    for (GDataXMLElement * child in [element children]) {
        if ([self hasChildElements:child]) {
            [dict setObject:[self dictionaryFromElement:child] forKey:child.name];
        }
        else {
            [dict setObject:[child stringValue] forKey:child.name];
        }
    }
    return dict;
}

- (NSDictionary *)dictionaryFromListElement:(GDataXMLElement *)element
{
    if (![self isList:element]) {
        return nil;
    }
    NSUInteger count = [self getListCount:element];
    if (count == NSUIntegerMax) {
        return nil;
    }
    NSMutableArray * items = [NSMutableArray array];
    NSDictionary * dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           @(count), @"count",
                           items, @"items",
                           nil];
    for (GDataXMLElement * child in [element children]) {
        if (![child.name isEqualToString:@"count"]) {
            [items addObject:[self dictionaryFromElement:child]];
        }
    }
    return dict;
}

- (NSDictionary *)responseDictionary:(GDataXMLElement *)rootElement error:(NSError **)error
{
    NSDictionary * result = [self dictionaryFromElement:rootElement];
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
