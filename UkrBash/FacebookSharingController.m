//
//  FacebookSharer.m
//  UkrBash
//
//  Created by Maks Markovets on 22.03.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "FacebookSharingController.h"
#import <Social/Social.h>

/**
 * Protocol for private implementations of Facebook sharing.
 */
@protocol FacebookControllerPrivateImplementation <NSObject>

- (BOOL)handleOpenUrl:(NSURL*)url;

@end

@interface FacebookSocialController : SharingController <FacebookControllerPrivateImplementation>

+ (id)instance;
+ (BOOL)isSharingAvailable;

@end

#pragma mark -

@implementation FacebookSharingController

+ (BOOL)isSharingAvailable
{
    return [FacebookSocialController isSharingAvailable];
}

- (void)dealloc
{
    [super dealloc];
}

- (SharingController<FacebookControllerPrivateImplementation>*)privateImplementation
{
    if ([SLComposeViewController class]) {
        return [FacebookSocialController instance];
    } else {
        return nil;
    }
}

- (BOOL)handleOpenUrl:(NSURL *)url
{
    return [[self privateImplementation] handleOpenUrl:url];
}

- (void)showSharingDialog
{
    SharingController * privateImplementation = [self privateImplementation];
    privateImplementation.rootViewController = self.rootViewController;
    privateImplementation.message = self.message;
    privateImplementation.url = self.url;
    for (UIImage * image in images) {
        [privateImplementation addImage:image];
    }
    [privateImplementation showSharingDialog];
}

@end

#pragma mark -

@implementation FacebookSocialController

+ (id)instance
{
    return [[[self alloc] init] autorelease];
}

+ (BOOL)isSharingAvailable
{
    if ([SLComposeViewController class]) {
        return YES;
    }
    return NO;
}

- (BOOL)handleOpenUrl:(NSURL *)url
{
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
