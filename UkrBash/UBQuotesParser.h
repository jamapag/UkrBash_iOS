//
//  UBQuotesParser.h
//  UkrBash
//
//  Created by Maks Markovets on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UBParser.h"

@interface UBQuotesParser : UBParser {
    
}

- (NSArray *)parseQuotesWithData:(NSData *)xmlData;

@end
