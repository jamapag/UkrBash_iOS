//
//  UBViewController.h
//  UkrBash
//
//  Created by Михаил Гребенкин on 13.01.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UBNavigationController;

@interface UBViewController : UIViewController
{
    UBNavigationController *ubNavigationController;
}

@property (nonatomic, assign) UBNavigationController *ubNavigationController;
@property (nonatomic, retain) UIButton *menuButton;
@property (nonatomic, getter=isModal) BOOL modal;

- (UIView *)headerViewWithMenuButtonAction:(SEL)menuActionSelector;

@end
