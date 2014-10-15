//
//  UBViewController.m
//  UkrBash
//
//  Created by Михаил Гребенкин on 13.01.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "UBViewController.h"

@implementation UBViewController

@synthesize ubNavigationController;

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
    ubNavigationController = nil;
    [super dealloc];
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

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
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;// (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UIView *)headerViewWithMenuButtonAction:(SEL)menuActionSelector
{
    float iOS7offset = 20;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0., (iOS7offset == 0) ? -20 : 0, self.view.frame.size.width, 64.)];
    headerView.userInteractionEnabled = YES;
    headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"header.png"]];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    headerView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:CGRectMake(0., 0., 2000, headerView.frame.size.height)] CGPath];
    headerView.layer.shadowColor = [[UIColor blackColor] CGColor];
    headerView.layer.shadowRadius = 2.;
    headerView.layer.shadowOffset = CGSizeMake(0, 2.);
    headerView.layer.shadowOpacity = .3;
    
    if (menuActionSelector) {
        CGFloat menuButtonWidth = 35., menuButtonX = 0.;
        
        CGFloat x = menuButtonX + menuButtonWidth + 5.;
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 20., headerView.frame.size.width - x * 2, headerView.frame.size.height - 24.)];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:21.];
        titleLabel.textColor = [UIColor darkGrayColor];
        titleLabel.shadowColor = [UIColor whiteColor];
        titleLabel.shadowOffset = CGSizeMake(0, 1.);
        titleLabel.text = self.title;
        [headerView addSubview:titleLabel];
        [titleLabel release];
        
        UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        menuButton.autoresizingMask = UIViewAutoresizingNone;
        menuButton.imageView.contentMode = UIViewContentModeCenter;
        [menuButton setImage:[UIImage imageNamed:@"menu-button"] forState:UIControlStateNormal];
        [menuButton addTarget:self action:menuActionSelector forControlEvents:UIControlEventTouchUpInside];
        [menuButton setFrame:CGRectMake(menuButtonX, titleLabel.frame.origin.y + (titleLabel.frame.size.height - 44.) / 2., menuButtonWidth + 20, 44.)];
        [headerView addSubview:menuButton];
    }
    
    return [headerView autorelease];
}

@end
