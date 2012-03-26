//
//  EMailSharer.h
//  UkrBash
//
//  Created by Maks Markovets on 22.03.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "BaseSharer.h"
#import <MessageUI/MessageUI.h>

@interface EMailSharer : BaseSharer <MFMailComposeViewControllerDelegate>
{
    UIViewController *viewController;
}

- (id)initWithViewController:(UIViewController *)aViewController andDelegate:(id<SharerDelegate>)sharerDelegate;

@end
