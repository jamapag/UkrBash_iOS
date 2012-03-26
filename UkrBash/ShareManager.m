//
//  ShareManager.m
//  UkrBash
//
//  Created by Maks Markovets on 22.03.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "ShareManager.h"

@implementation ShareManager

+ (ShareManager *)sharedInstance
{
    static ShareManager *sharedInstance = nil;
    @synchronized (self) {
        if (sharedInstance == nil) {
            sharedInstance = [[ShareManager alloc] init];
        }
    }
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        sharers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (FacebookSharer *)createFacebookSharer
{
    FacebookSharer *facebookSharer = [[FacebookSharer alloc] initWithAppId:@"347506238633558" andDelegate:self];
    [sharers addObject:facebookSharer];
    return [facebookSharer autorelease];
}

- (TwitterSharer *)createTwitterSharerWithViewController:(UIViewController *)aViewController
{
    TwitterSharer *twitterSharer = [[TwitterSharer alloc] initWithViewController:aViewController andDelegate:self];
    [sharers addObject:twitterSharer];
    return [twitterSharer autorelease];
}

- (EMailSharer *)createEmailSharerWithViewController:(UIViewController *)aViewController
{
    EMailSharer *emailSharer = [[EMailSharer alloc] initWithViewController:aViewController andDelegate:self];
    [sharers addObject:emailSharer];
    return [emailSharer autorelease];
}


#pragma mark - SharerDelegate methods

- (void)sharingDidFinishedWithSharer:(BaseSharer *)sharer
{
    [sharers removeObject:sharer];
}

- (void)sharingDidFinishedWithError:(NSError *)error andSharer:(BaseSharer *)sharer
{
    [sharers removeObject:sharer];
}

@end
