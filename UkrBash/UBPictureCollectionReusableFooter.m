//
//  UBPictureCollectionReusableFooter.m
//  UkrBash
//
//  Created by maks on 02.04.13.
//
//

#import "UBPictureCollectionReusableFooter.h"

@implementation UBPictureCollectionReusableFooter

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:activityIndicatorView];
        activityIndicatorView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        [activityIndicatorView startAnimating];
    }
    return self;
}

- (void)dealloc
{
    [activityIndicatorView release];
    [super dealloc];
}

- (void)layoutSubviews
{
    activityIndicatorView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
}

@end
