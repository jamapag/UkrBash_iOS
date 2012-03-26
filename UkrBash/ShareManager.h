//
//  ShareManager.h
//  UkrBash
//
//  Created by Maks Markovets on 22.03.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FacebookSharer.h"
#import "TwitterSharer.h"
#import "EMailSharer.h"

@interface ShareManager : NSObject <SharerDelegate>
{
    NSMutableArray *sharers;
}

+ (ShareManager *)sharedInstance;
- (FacebookSharer *)createFacebookSharer;
- (TwitterSharer *)createTwitterSharerWithViewController:(UIViewController *)aViewController;
- (EMailSharer *)createEmailSharerWithViewController:(UIViewController *)aViewController;

@end
