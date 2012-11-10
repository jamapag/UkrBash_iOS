//
//  VKXMLResponseParser.h
//  UkrBash
//
//  Created by Michail Grebionkin on 10.10.12.
//
//

#import <Foundation/Foundation.h>
#import "VKResponseParser.h"

@interface VKXMLResponseParser : NSObject <VKResponseParser>

- (NSDictionary *)dictionaryFromData:(NSData *)data error:(NSError **)error;

@end
