//
//  VKURLParser.m
//  UkrBash
//
//  Created by Michail Grebionkin on 03.12.12.
//
//

#import "VKURLParser.h"

@implementation VKURLParser

+ (NSString *)URLDecode:(NSString *)string
{
    return [[string stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSDictionary *)parseString:(NSString *)string
{
    NSArray * parts = [string componentsSeparatedByString:@"&"];
    NSMutableDictionary * result = [NSMutableDictionary dictionary];
    for (NSString * keyValueString in parts) {
        NSArray * keyValuePair = [keyValueString componentsSeparatedByString:@"="];
        NSString * key = [self URLDecode:[keyValuePair objectAtIndex:0]];
        if (key == nil || [key isEqualToString:@""]) {
            continue;
        }
        
        NSString * value = nil;
        if ([keyValuePair count] > 1) {
            value = [self URLDecode:[keyValuePair objectAtIndex:1]];
        }
        if (value == nil || [value isEqualToString:@""]) {
            [result setObject:[NSNull null] forKey:key];
        }
        else {
            [result setObject:value forKey:key];
        }
    }
    return result;
}


+ (NSDictionary *)dictionaryParamsFromURL:(NSURL *)url
{
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    if (url.query != nil) {
        [params addEntriesFromDictionary:[self parseString:url.query]];
    }
    if (url.fragment != nil) {
        [params addEntriesFromDictionary:[self parseString:url.fragment]];
    }
    return params;
}

@end
