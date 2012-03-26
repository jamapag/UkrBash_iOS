//
//  TwitterSharer.m
//  UkrBash
//
//  Created by Maks Markovets on 22.03.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "TwitterSharer.h"
#import <Twitter/Twitter.h>

@implementation TwitterSharer

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
    if ([TWTweetComposeViewController canSendTweet]) {
        TWTweetComposeViewController *tweetController = [[TWTweetComposeViewController alloc] init];
        [tweetController addURL:[NSURL URLWithString:url]];
        
        if ([message length] > 116) {
            message = [message substringToIndex:114];
            message = [message stringByAppendingString:@"..."];
        }
        
        [tweetController setInitialText:message];
        
        tweetController.completionHandler = ^(TWTweetComposeViewControllerResult result) 
        {
            if (result == TWTweetComposeViewControllerResultCancelled)
                [delegate sharingDidFinishedWithSharer:self];
            else if (result == TWTweetComposeViewControllerResultDone)
                [delegate sharingDidFinishedWithSharer:self];
            
            // Dismiss the controller
            [viewController dismissModalViewControllerAnimated:YES];
        };
        [viewController presentModalViewController:tweetController animated:YES];
        [tweetController release];

    } else {
        [delegate sharingDidFinishedWithError:nil andSharer:self];
    }
}

@end
