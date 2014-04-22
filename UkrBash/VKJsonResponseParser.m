//
//  VKJsonResponseParser.m
//  UkrBash
//
//  Created by maks on 22.04.14.
//
//

#import "VKJsonResponseParser.h"

@implementation VKJsonResponseParser

- (NSDictionary *)dictionaryFromData:(NSData *)jsonData error:(NSError **)error
{
    NSDictionary *result = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:error];
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        result = (NSDictionary *)jsonObject;
    }
    
    return result;
}


@end
