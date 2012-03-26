//
//  FacebookSharer.m
//  UkrBash
//
//  Created by Maks Markovets on 22.03.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "FacebookSharer.h"

@implementation FacebookSharer

@synthesize facebook;

- (id)initWithAppId:(NSString *)appId andDelegate:(id<SharerDelegate>)sharerDelegate
{
    self = [super init];
    if (self) {
        delegate = sharerDelegate;
        facebook = [[Facebook alloc] initWithAppId:appId andDelegate:self];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"FBAccessTokenKey"] 
            && [defaults objectForKey:@"FBExpirationDateKey"]) {
            facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
            facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
        }
    }
    return self;
}

- (void)dealloc
{
    [facebook release];
    [shareUrl release];
    [super dealloc];
}

- (void)shareUrl:(NSString *)url withMessage:(NSString *)message
{
    NSLog(@"ShareUrl");
    if (shareUrl) {
        [shareUrl release], shareUrl = nil;
    }
    shareUrl = [url retain];
    if (![facebook isSessionValid]) {
        callShare = YES;
        NSLog(@"requestpermissions");
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
    NSLog(@"share");
    if ([facebook isSessionValid]) {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:shareUrl, @"link", nil];
        [facebook dialog:@"stream.publish" andParams:params andDelegate:self];
    }
}

#pragma mark - FBSessionDelegate methods

/**
 * Called when the user successfully logged in.
 */
- (void)fbDidLogin
{
    NSLog(@"did login");
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
    NSLog(@"Did Not login");
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
    NSLog(@"did extend token");
}

/**
 * Called when the user logged out.
 */
- (void)fbDidLogout
{
    NSLog(@"did logout");
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
    NSLog(@"Session invalidated");
}


#pragma mark - FBDialogDelegate

/**
 * Called when the dialog succeeds and is about to be dismissed.
 */
- (void)dialogDidComplete:(FBDialog *)dialog
{
    [delegate sharingDidFinishedWithSharer:self];
}

/**
 * Called when the dialog succeeds with a returning url.
 */
- (void)dialogCompleteWithUrl:(NSURL *)url
{
    [delegate sharingDidFinishedWithSharer:self];
}

/**
 * Called when the dialog get canceled by the user.
 */
- (void)dialogDidNotCompleteWithUrl:(NSURL *)url
{
    [delegate sharingDidFinishedWithSharer:self];
}

/**
 * Called when the dialog is cancelled and is about to be dismissed.
 */
- (void)dialogDidNotComplete:(FBDialog *)dialog
{
    [delegate sharingDidFinishedWithSharer:self];
}

/**
 * Called when dialog failed to load due to an error.
 */
- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError *)error
{
    [delegate sharingDidFinishedWithError:error andSharer:self];
}


@end
