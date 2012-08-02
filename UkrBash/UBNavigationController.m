//
//  UBNavigationController.m
//  UkrBash
//
//  Created by Михаил Гребенкин on 12.01.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "UBNavigationController.h"
#import "UBViewController.h"
#import <QuartzCore/QuartzCore.h>

#define BORDER_WIDTH 15.

@implementation UBNavigationController

@synthesize menuViewController = _menuViewController;
@synthesize viewController = _viewController;

- (id)initWithMenuViewController:(UBViewController *)menuViewController
{
    self = [super init];
    if (self) {
        _menuViewController = [menuViewController retain];
        _menuViewController.ubNavigationController = self;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [_menuViewController release];
    [_viewController release];
    [borderView release];
    [super dealloc];
}

#pragma mark - Navigation

- (void)pushViewController:(UBViewController *)viewController animated:(BOOL)animated
{
    NSAssert(_viewController == nil, @"Can't push two controllers in UBNavigationController");
    if (!_viewController) {
        _viewController = [viewController retain];
        _viewController.ubNavigationController = self;
        _viewController.view.frame = CGRectMake(0., 0., self.view.bounds.size.width, self.view.bounds.size.height);
        _viewController.view.layer.shadowOffset = CGSizeMake(-15., 5.);
        _viewController.view.layer.shadowRadius = 10.;
        _viewController.view.layer.shadowColor = [[UIColor blackColor] CGColor];
        _viewController.view.layer.shadowOpacity = .5;
        _viewController.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:_viewController.view.bounds].CGPath;
        if (animated) {
            CGFloat x = _viewController.view.center.x + self.view.bounds.size.width - BORDER_WIDTH;
            _viewController.view.center = CGPointMake(x, _viewController.view.center.y);
            [borderView removeFromSuperview];
            [self.view addSubview:_viewController.view];
            [UIView animateWithDuration:.4 animations:^ {
                CGFloat newX = self.view.bounds.size.width / 2.;
                _viewController.view.center = CGPointMake(newX, _viewController.view.center.y);
            }];
        } else {
            [borderView removeFromSuperview];
            [self.view addSubview:_viewController.view];
        }
    }
}

- (void)popViewControllerAnimated:(BOOL)animated
{
    NSAssert(_viewController != nil, @"Can't pop menu controller.");
    if (_viewController) {
        if (animated) {
            [UIView animateWithDuration:.5 animations:^(void) {
                CGFloat x = _viewController.view.center.x + self.view.bounds.size.width - BORDER_WIDTH;
                _viewController.view.center = CGPointMake(x, _viewController.view.center.y);
            } completion:^(BOOL finished) {
                _viewController.ubNavigationController = nil;
                [_viewController.view removeFromSuperview];
                [_viewController release], _viewController = nil;
                
                CGFloat height = self.view.bounds.size.height;
                if (height < self.view.bounds.size.width) {
                    height = self.view.bounds.size.width;
                }
                borderView.frame = CGRectMake(self.view.bounds.size.width - BORDER_WIDTH, 0., BORDER_WIDTH, height);
                [self.view addSubview:borderView];
            }];
        } else {
            _viewController.ubNavigationController = nil;
            [_viewController.view removeFromSuperview];
            [_viewController release], _viewController = nil;
            [self.view addSubview:borderView];
        }
    }
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    
    self.view.clipsToBounds = YES;
    
    borderView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - BORDER_WIDTH, 0., BORDER_WIDTH, self.view.frame.size.height)];
    borderView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    borderView.contentMode = UIViewContentModeBottomLeft;
    borderView.image = [UIImage imageNamed:@"border"];
    borderView.layer.shadowOffset = CGSizeMake(-15., 5.);
    borderView.layer.shadowRadius = 10.;
    borderView.layer.shadowColor = [[UIColor blackColor] CGColor];
    borderView.layer.shadowOpacity = .5;
    borderView.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0., -20., borderView.frame.size.width + 20., borderView.frame.size.height + 20.)].CGPath;

    if (_menuViewController) {
        _menuViewController.view.frame = CGRectMake(0., 0., self.view.frame.size.width, self.view.frame.size.height);
        [self.view addSubview:_menuViewController.view];

        if (_viewController) {
            _viewController.view.frame = CGRectMake(0., 0., self.view.frame.size.width, self.view.frame.size.height);
            [self.view addSubview:_viewController.view];
        } else {
            [self.view addSubview:borderView];
        }
    }
    
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    [borderView release], borderView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                duration:(NSTimeInterval)duration
{
    if (_viewController) {
        [_viewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    if (_viewController) {
        [_viewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}


@end
