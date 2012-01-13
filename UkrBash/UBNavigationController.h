//
//  UBNavigationController.h
//  UkrBash
//
//  Created by Михаил Гребенкин on 12.01.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UBViewController;

@interface UBNavigationController : UIViewController
{
    UBViewController *_menuViewController;
    UBViewController *_viewController;
    UIImageView *borderView;
}

@property (nonatomic, readonly) UBViewController *menuViewController;
@property (nonatomic, readonly) UBViewController *viewController;

- (id)initWithMenuViewController:(UBViewController*)menuViewController;
- (void)pushViewController:(UBViewController*)viewController animated:(BOOL)animated;
- (void)popViewControllerAnimated:(BOOL)animated;

@end
