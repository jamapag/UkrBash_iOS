//
//  BaseSharer.m
//  UkrBash
//
//  Created by Maks Markovets on 22.03.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "BaseSharer.h"

@implementation BaseSharer

- (void)shareUrl:(NSString *)url withMessage:(NSString *)message
{
    NSAssert(NO, @"this method should be overloaded by subclasses");
}

@end
