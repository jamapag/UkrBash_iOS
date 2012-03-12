//
//  UIKitExtentions.m
//  MyApps
//
//  Created by Michail Grebionkin on 30.04.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIKitExtentions.h"

static NSInteger networkActivityIndicatorCounter = 0;


@implementation UIApplication(Extentions)


- (void)showNetworkActivityIndicator {
	networkActivityIndicatorCounter++;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = (networkActivityIndicatorCounter != 0);
}


- (void)hideNetworkActivityIndicator {
	networkActivityIndicatorCounter--;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = (networkActivityIndicatorCounter != 0);
}


@end