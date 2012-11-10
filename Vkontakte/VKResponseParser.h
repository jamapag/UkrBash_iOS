//
//  VKResponseParser.h
//  UkrBash
//
//  Created by Michail Grebionkin on 10.10.12.
//
//

#import <Foundation/Foundation.h>

@protocol VKResponseParser <NSObject>

- (NSDictionary*)dictionaryFromData:(NSData*)data error:(NSError**)error;

@end
