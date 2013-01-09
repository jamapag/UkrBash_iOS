//
//  VKURLParser.h
//  UkrBash
//
//  Created by Michail Grebionkin on 03.12.12.
//
//

#import <Foundation/Foundation.h>

#define IS_NULL(a) ((a) == nil || [(a) isEqual:[NSNull null]])

@interface VKURLParser : NSObject

+ (NSDictionary *)dictionaryParamsFromURL:(NSURL *)url;

@end
