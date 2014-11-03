//
//  UBPictureView.m
//  UkrBash
//
//  Created by Maks Markovets on 04.07.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "UBPictureView.h"

@implementation UBPictureView

@synthesize imageUrl;
@synthesize thumbnailUrl;
@synthesize index;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDelegate:self];
        [self setShowsVerticalScrollIndicator:NO];
        [self setShowsHorizontalScrollIndicator:NO];
        imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:imageView];
    }
    return self;
}

- (void)dealloc
{
    [imageView release];
    [imageUrl release];
    [thumbnailUrl release];
    [super dealloc];
}

- (void)layoutSubviews 
{
    [super layoutSubviews];
    
    if (CGRectEqualToRect([self bounds], [imageView frame]) == NO) {
        [imageView setFrame:[self bounds]];
    }
}


- (void)setImage:(UIImage *)newImage
{
    [imageView setImage:newImage];
}

- (UIImage *)getImage
{
    return [imageView image];
}

@end
