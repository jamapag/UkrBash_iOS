//
//  EMailSharer.m
//  UkrBash
//
//  Created by Maks Markovets on 22.03.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "EMailSharer.h"

@implementation EMailSharer

- (id)initWithViewController:(UIViewController *)aViewController andDelegate:(id<SharerDelegate>)sharerDelegate
{
    self = [super init];
    if (self) {
        delegate = sharerDelegate;
        viewController = aViewController;
    }
    return self;
}

- (void)shareUrl:(NSString *)url withMessage:(NSString *)message
{
    NSAssert(viewController != nil, @"View Controller shouldn't be nil");
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        [mailComposer setSubject:@""];
        NSString *body = [NSString stringWithFormat:@"%@ \n%@", message, url];
        [mailComposer setMessageBody:body isHTML:NO];
        [viewController presentModalViewController:mailComposer animated:YES];
        [mailComposer release];
    } else {
        [delegate sharingDidFinishedWithSharer:self];
    }
}

#pragma mark - mail composer delegate

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [viewController dismissModalViewControllerAnimated:YES];
    if (result == MFMailComposeResultSent) {
        [delegate sharingDidFinishedWithSharer:self];
    } else {
        [delegate sharingDidFinishedWithError:error andSharer:self];
    }
}


@end
