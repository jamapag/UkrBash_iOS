//
//  TwitterSharer.h
//  UkrBash
//
//  Created by Maks Markovets on 22.03.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "BaseSharer.h"

@interface TwitterSharer : BaseSharer
{
    UIViewController *viewController;
}

- (id)initWithViewController:(UIViewController *)aViewController andDelegate:(id<SharerDelegate>)sharerDelegate;
@end
