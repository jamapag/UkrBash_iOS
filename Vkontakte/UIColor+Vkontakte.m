//
//  UIColor+Vkontakte.m
//  UkrBash
//
//  Created by Michail Grebionkin on 06.12.12.
//
//

#import "UIColor+Vkontakte.h"

@implementation UIColor (Vkontakte)

+ (UIColor *)vkSharingAttachmentHeaderTextColor
{
    return [self colorWithRed:0.27 green:0.40 blue:0.55 alpha:1];
}

+ (UIColor *)vkSharingViewBackgroundColor
{
    return [self colorWithWhite:0.945 alpha:1.];
}

+ (UIColor *)vkSharingViewInnerBlockBorderColor
{
    return [self colorWithRed:0.75 green:0.79 blue:0.83 alpha:1.];
}

+ (UIColor *)vkButtonBlueBackgroundColor
{
    return [self colorWithRed:0.38 green:0.50 blue:0.65 alpha:1.];
}

+ (UIColor *)vkButtonBlueBorderColor
{
    return [self colorWithRed:0.35 green:0.50 blue:0.66 alpha:1.];
}

@end
