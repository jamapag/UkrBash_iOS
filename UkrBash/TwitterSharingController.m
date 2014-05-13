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
        return YES;
    }
    return NO;
}

- (void)showSharingDialog
{
    NSAssert(self.rootViewController != nil, @"root view controller should not be nil");
    if ([SLComposeViewController class]) {
        SLComposeViewController * composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [composeViewController setInitialText:self.message];
        [composeViewController addURL:self.url];
        for (UIImage *image in images) {
            [composeViewController addImage:image];
        }
        [self.rootViewController presentViewController:composeViewController animated:YES completion:nil];
    }
}

@end
