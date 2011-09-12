//
//  UBRequest.h
//  UkrBash
//
//  Created by Maks Markovets on 9/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UBRequest : NSObject {
    NSURLConnection *connection;
    
}

- (NSURLRequest*)URLRequest;
- (void)start;
- (void)cancel;

@end
