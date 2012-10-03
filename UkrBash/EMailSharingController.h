//
//  EMailSharer.h
//  UkrBash
//
//  Created by Maks Markovets on 22.03.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "SharingController.h"
#import <MessageUI/MessageUI.h>

/**
 * EMailSharingController class use standart e-mail composer view for sharing
 * content with e-mail.
 *
 * @see https://developer.apple.com/library/ios/#documentation/MessageUI/Reference/MessageUI_Framework_Reference/_index.html
 */
@interface EMailSharingController : SharingController <MFMailComposeViewControllerDelegate>

@end
