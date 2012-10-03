//
//  FacebookSharer.h
//  UkrBash
//
//  Created by Maks Markovets on 22.03.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "SharingController.h"

/**
 * Depending on version of iOS FacebookSharingController is using a Facebook Connect SDK for iOS
 * or Social framework for sharing.
 *
 * NOTE: it always returns YES as result of calling isSharingAvailableForNetworkType method for
 * Facebook network type.
 *
 * @see https://developers.facebook.com/docs/tutorials/ios-sdk-tutorial/
 * @see https://developer.apple.com/library/ios/#documentation/Social/Reference/Social_Framework/_index.html
 */
@interface FacebookSharingController : SharingController

- (BOOL)handleOpenUrl:(NSURL*)url;

@end
