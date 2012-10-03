//
//  TwitterSharer.m
//  UkrBash
//
//  Created by Maks Markovets on 22.03.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "TwitterSharingController.h"
#import <Twitter/Twitter.h>
#import <Social/Social.h>

@implementation TwitterSharingController

+ (BOOL)isSharingAvailable
{
    if ([SLComposeViewController class]) {
        return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
    }
    else if ([TWTweetComposeViewController class]) {
        return [TWTweetComposeViewController canSendTweet];
    }
    return NO;
}

- (void)showSharingDialog
{
    NSAssert(self.rootViewController != nil, @"root view controller should not be nil");
    if ([SLComposeViewController class]) {
        SLComposeViewController * composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [composeViewController setInitialText:self.message];
        [composeViewController addURL:[NSURL URLWithString:self.url]];
        for (UIImage * image in images) {
            [composeViewController addImage:image];
        }
        composeViewController.completionHandler = ^(TWTweetComposeViewControllerResult result) {
            [self.rootViewController dismissModalViewControllerAnimated:YES];
        };
        if ([self.rootViewController respondsToSelector:@selector(presentViewController:animated:completion:)]) {
            [self.rootViewController presentViewController:composeViewController animated:YES completion:nil];
        }
        else {
            composeViewController.completionHandler = ^(SLComposeViewControllerResult result) {
                [self.rootViewController dismissModalViewControllerAnimated:YES];
            };
            [self.rootViewController presentModalViewController:composeViewController animated:YES];
        }
    }
    else if ([TWTweetComposeViewController class]) {
        TWTweetComposeViewController * composeViewController = [[TWTweetComposeViewController alloc] init];
        [composeViewController setInitialText:self.message];
        [composeViewController addURL:[NSURL URLWithString:self.url]];
        for (UIImage * image in images) {
            [composeViewController addImage:image];
        }
        composeViewController.completionHandler = ^(TWTweetComposeViewControllerResult result) {
            [self.rootViewController dismissModalViewControllerAnimated:YES];
        };
        if ([self.rootViewController respondsToSelector:@selector(presentViewController:animated:completion:)]) {
            [self.rootViewController presentViewController:composeViewController animated:YES completion:nil];
        }
        else {
            [self.rootViewController presentModalViewController:composeViewController animated:YES];
        }
        [composeViewController release];
    }
}

@end
