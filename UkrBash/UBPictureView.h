//
//  UBPictureView.h
//  UkrBash
//
//  Created by Maks Markovets on 04.07.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UBPicturesScrollViewController;
@interface UBPictureView : UIScrollView <UIScrollViewDelegate>
{
    UIImageView *imageView;
    UBPicturesScrollViewController *scroller;
    
    NSString *imageUrl;
    NSString *thumbnailUrl;
    NSInteger index;
}

@property (nonatomic, assign) UBPicturesScrollViewController *scroller;
@property (nonatomic, retain) NSString *imageUrl;
@property (nonatomic, retain) NSString *thumbnailUrl;
@property (nonatomic, assign) NSInteger index;

- (void)setImage:(UIImage *)newImage;
- (UIImage *)getImage;


@end
