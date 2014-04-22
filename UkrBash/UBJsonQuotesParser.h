//
//  UBJsonQuotesParser.h
//  UkrBash
//
//  Created by maks on 16.04.14.
//
//

#import "UBParser.h"

@interface UBJsonQuotesParser : UBParser

- (NSArray *)parseQuotesWithData:(NSData *)jsonData;

@end
