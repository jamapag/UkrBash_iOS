//
//  FacebookSharer.m
//  UkrBash
//
//  Created by Maks Markovets on 22.03.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "FacebookSharingController.h"
#import <Social/Social.h>

@implementation FacebookSharingController

+ (BOOL)isSharingAvailable
{
    if ([SLComposeViewController class]) {
        return YES;
    }
    return NO;
}

- (void)showSharingDialog
{
    NSAssert(self.rootViewController != nil, @"");
    SLComposeViewController * composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [composeViewController setInitialText:self.message];
    [composeViewController addURL:[NSURL URLWithString:self.url]];
    for (UIImage * image in images) {
        [composeViewController addImage:image];
    }
    composeViewController.completionHandler = ^(SLComposeViewControllerResult result) {
        [self.rootViewController dismissViewControllerAnimated:YES completion:nil];
    };
    [self.rootViewController presentViewController:composeViewController animated:YES completion:nil];
}

@end
