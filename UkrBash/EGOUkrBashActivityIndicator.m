//
//  EGOUkrBashActivityIndicator.m
//  UkrBash
//
//  Created by Michail Grebionkin on 01.08.13.
//
//

#import "EGOUkrBashActivityIndicator.h"
#import <QuartzCore/QuartzCore.h>

#define kEGOUkrBashActivityIndicatorAnimationID @"kEGOUkrBashActivityIndicatorAnimationID"

@implementation EGOUkrBashActivityIndicator

- (id)init
{
    UIImage *pinImage = [UIImage imageNamed:@"menu-pin"];
    CGFloat padding = 10.;
    self = [super initWithFrame:CGRectMake(0., 0., 3 * pinImage.size.width + 2 * padding, pinImage.size.height)];
    if (self) {
        for (NSInteger pinIndex = 0; pinIndex < 3; pinIndex++) {
            UIImageView *pinImageView = [[UIImageView alloc] initWithFrame:CGRectMake(pinImage.size.width * pinIndex + padding * pinIndex, 0., pinImage.size.width, pinImage.size.height)];
            pinImageView.image = pinImage;
            pinImageView.layer.shadowColor = [[UIColor blackColor] CGColor];
            pinImageView.layer.shadowRadius = 2.;
            pinImageView.layer.shadowOffset = CGSizeMake(0, 0.);
            pinImageView.layer.shadowOpacity = .3;
            pinImageView.layer.shadowPath = [[UIBezierPath bezierPathWithOvalInRect:pinImageView.bounds] CGPath];
            [self addSubview:pinImageView];
            [pinImageView release];
        }
        self.backgroundColor = [UIColor clearColor];
        [UIView beginAnimations:kEGOUkrBashActivityIndicatorAnimationID context:NULL];
        [UIView setAnimationDuration:1.];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationRepeatCount:HUGE_VAL];
        
        for (UIImageView *imageView in self.subviews) {
            imageView.transform = CGAffineTransformMakeRotation(-M_PI);
        }
        [UIView commitAnimations];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)startAnimating
{
}

- (void)stopAnimating
{
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
