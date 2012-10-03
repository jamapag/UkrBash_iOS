//
//  EMailSharer.m
//  UkrBash
//
//  Created by Maks Markovets on 22.03.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "EMailSharingController.h"

@implementation EMailSharingController

+ (BOOL)isSharingAvailable
{
    return [MFMailComposeViewController canSendMail];
}

- (void)showSharingDialog
{
    NSAssert(self.rootViewController != nil, @"root view controller should not be nil");
    NSAssert([MFMailComposeViewController canSendMail], @"can't send mails");

    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    [mailComposer setSubject:@""];
    NSString *body = [NSString stringWithFormat:@"%@ \n%@", (self.message) ? self.message : @"", self.url];
    [mailComposer setMessageBody:body isHTML:NO];
    if ([self.rootViewController respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        [self.rootViewController presentViewController:mailComposer animated:YES completion:nil];
    }
    else {
        [self.rootViewController presentModalViewController:mailComposer animated:YES];
    }
    [mailComposer release];
    
    /**
     * Needs to retain self because self assigned as delegate of mail compose view. So it should not be 
     * released until mail compose view is visible.
     */
    [self retain];
}

#pragma mark - mail composer delegate

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if ([self.rootViewController respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        [self.rootViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.rootViewController dismissModalViewControllerAnimated:YES];
    }
    /**
     * Mail compose view no more visible. Now we can release self.
     */
    [self release];
}


@end
