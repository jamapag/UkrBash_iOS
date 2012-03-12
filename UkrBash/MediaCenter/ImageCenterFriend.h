//
//  ImageCenterFriend.h
//
//  Created by Michail Grebionkin on 02.02.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MediaCenter(Friend)

- (void) downloadEnded:(NSString*)url;
- (NSString*) popUrlFromQueue;

@end
