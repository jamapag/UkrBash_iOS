//
//  BaseSharer.h
//  
//
//  Created by Maks Markovets on 22.03.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BaseSharer;
@protocol SharerDelegate <NSObject>

- (void)sharingDidFinishedWithSharer:(BaseSharer *)sharer;
- (void)sharingDidFinishedWithError:(NSError *)error andSharer:(BaseSharer *)sharer;

@end

@interface BaseSharer : NSObject
{
    NSString *shareMessage;
    NSString *shareUrl;
    id<SharerDelegate> delegate;
}

- (void)shareUrl:(NSString *)url withMessage:(NSString *)message;

@end
