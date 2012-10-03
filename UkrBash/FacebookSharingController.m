//
//  FacebookSharer.m
//  UkrBash
//
//  Created by Maks Markovets on 22.03.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "FacebookSharingController.h"
#import "FBConnect.h"
#import <Social/Social.h>

/**
 * Protocol for private implementations of Facebook sharing.
 */
@protocol FacebookControllerPrivateImplementation <NSObject>

- (BOOL)handleOpenUrl:(NSURL*)url;

@end

/**
 * A FacebookConnectController class is a private implementation class of FacebookSocialController. It implements
 * sharing using Facebook Connect SDK. It's implemented as singleton object.
 *
 * @see https://developers.facebook.com/docs/tutorials/ios-sdk-tutorial/
 */
@interface FacebookConnectController : SharingController <FBSessionDelegate, FacebookControllerPrivateImplementation>
{
    BOOL callShare;
}

@property (nonatomic, retain) Facebook * facebook;

+ (id)instance;
+ (BOOL)isSharingAvailable;

@end

/**
 * A FacebookConnectController class is a private implementation class of FacebookSocialController. It implements
 * sharing using Social framework. Requires iOS version 6 or higher.
 *
 * @see https://developer.apple.com/library/ios/#documentation/Social/Reference/Social_Framework/_index.html
 */
@interface FacebookSocialController : SharingController <FacebookControllerPrivateImplementation>

+ (id)instance;
+ (BOOL)isSharingAvailable;

@end

#pragma mark -

@implementation FacebookSharingController

+ (BOOL)isSharingAvailable
{
    return [FacebookConnectController isSharingAvailable] || [FacebookSocialController isSharingAvailable];
}

- (void)dealloc
{
    [super dealloc];
}

- (SharingController<FacebookControllerPrivateImplementation>*)privateImplementation
{
    if ([SLComposeViewController class] && [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        return [FacebookSocialController instance];
    } else {
        return [FacebookConnectController instance];
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

static FacebookConnectController * facebookConnectControllerInstance = nil;

@implementation FacebookConnectController

@synthesize facebook;

+ (id)instance
{
    if (!facebookConnectControllerInstance) {
        facebookConnectControllerInstance = [[self alloc] init];
        facebookConnectControllerInstance.facebook = [[Facebook alloc] initWithAppId:@"347506238633558" andDelegate:facebookConnectControllerInstance];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"FBAccessTokenKey"]
            && [defaults objectForKey:@"FBExpirationDateKey"]) {
            facebookConnectControllerInstance.facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
            facebookConnectControllerInstance.facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
        }
    }
    return facebookConnectControllerInstance;
}

+ (BOOL)isSharingAvailable
{
    return YES;
}

- (BOOL)handleOpenUrl:(NSURL *)url
{
    return [facebookConnectControllerInstance.facebook handleOpenURL:url];
}

- (void)showSharingDialog
{
    if (![facebook isSessionValid]) {
        callShare = YES;
        NSLog(@"fb request permissions");
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"publish_stream",
                                @"offline_access",
                                nil];
        [facebook authorize:permissions];
        [permissions release];
    } else {
        [self share];
    }
}

- (void)share
{
    NSLog(@"fb share");
    if ([facebook isSessionValid]) {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.url, @"link", nil];
        [facebook dialog:@"stream.publish" andParams:params andDelegate:nil];
    }
}

#pragma mark - FBSessionDelegate methods

/**
 * Called when the user successfully logged in.
 */
- (void)fbDidLogin
{
    NSLog(@"fb did login");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    if (callShare) {
        callShare = NO;
        [self share];
    }
}

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled
{
    NSLog(@"fb Did Not login");
}

/**
 * Called after the access token was extended. If your application has any
 * references to the previous access token (for example, if your application
 * stores the previous access token in persistent storage), your application
 * should overwrite the old access token with the new one in this method.
 * See extendAccessToken for more details.
 */
- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt
{
    NSLog(@"fb did extend token");
}

/**
 * Called when the user logged out.
 */
- (void)fbDidLogout
{
    NSLog(@"fb did logout");
    // Remove saved authorization information if it exists
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
    }
}

/**
 * Called when the current session has expired. This might happen when:
 *  - the access token expired
 *  - the app has been disabled
 *  - the user revoked the app's permissions
 *  - the user changed his or her password
 */
- (void)fbSessionInvalidated
{
    NSLog(@"fb Session invalidated");
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
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook];
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
