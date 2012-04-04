//
//  UBErrorsParser.h
//  UkrBash
//
//  Created by Maks Markovets on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UBErrorsParser : NSObject {
    
}

- (NSDictionary *)parseErrorWithData:(NSData *)xmlData;

@end
