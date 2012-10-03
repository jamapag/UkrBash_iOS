//
//  BaseSharer.m
//  UkrBash
//
//  Created by Maks Markovets on 22.03.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "SharingController.h"
#import "FacebookSharingController.h"
#import "TwitterSharingController.h"
#import "EMailSharingController.h"

@interface SharingController ()
{
    SharingNetworkType _networkType;
}

+ (BOOL)isSharingAvailable;

@end

@implementation SharingController

@synthesize message;
@synthesize url;
@synthesize rootViewController = _rootViewController;

+ (BOOL)isSharingAvailableForNetworkType:(SharingNetworkType)networkType
{
    NSAssert(IsSharingNetworkTypeValid(networkType), @"undefined sharing network type");
    switch (networkType) {
        case SharingFacebookNetwork:
            return [FacebookSharingController isSharingAvailable];
            break;
        case SharingTwitterNetwork:
            return [TwitterSharingController isSharingAvailable];
            break;
        case SharingEMailNetwork:
            return [EMailSharingController isSharingAvailable];
            break;
        default:
            break;
    }
    return NO;
}

+ (id)sharingControllerForNetworkType:(SharingNetworkType)networkType
{
    NSAssert(IsSharingNetworkTypeValid(networkType), @"undefined sharing network type");
    switch (networkType) {
        case SharingFacebookNetwork:
            return [[[FacebookSharingController alloc] init] autorelease];
            break;
        case SharingTwitterNetwork:
            return [[[TwitterSharingController alloc] init] autorelease];
            break;
        case SharingEMailNetwork:
            return [[[EMailSharingController alloc] init] autorelease];
            break;
        default:
            break;
    }
    return nil;
}

+ (BOOL)isSharingAvailable
{
    NSAssert(NO, @"this method should be overloaded by subclasses");
    return NO;
}

- (SharingNetworkType)networkType
{
    NSAssert(IsSharingNetworkTypeValid(_networkType), @"undefined sharing network type");
    return _networkType;
}

- (id)init
{
    self = [super init];
    if (self) {
        images = [[NSMutableArray alloc] init];
        _networkType = 0;
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController*)rootViewController
{
    self = [self init];
    if (self) {
        self.rootViewController = rootViewController;
    }
    return self;
}

- (void)dealloc
{
    [self.message release];
    [self.url release];
    [self.rootViewController release];
    [images release];
    [super dealloc];
}

- (void)addImage:(UIImage*)image
{
    [images addObject:image];
}

- (void)removeAllImages
{
    [images removeAllObjects];
}

- (void)showSharingDialog
{
    NSAssert(NO, @"this method should be overloaded by subclasses");
}

@end
