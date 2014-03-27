//
//  UBPictureInfoView.h
//  UkrBash
//
//  Created by Михаил Гребенкин on 29.03.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UBPictureInfoView : UIView
{
    UILabel *textLabel;
    UILabel *idLabel;
    UILabel *ratingLabel;
    UILabel *authorLabel;
    UILabel *dateLabel;
}

@property (nonatomic, readonly) UILabel *idLabel;
@property (nonatomic, readonly) UILabel *ratingLabel;
@property (nonatomic, readonly) UILabel *textLabel;
@property (nonatomic, readonly) UILabel *authorLabel;
@property (nonatomic, readonly) UILabel *dateLabel;

+ (CGFloat)preferedHeightForQuoteText:(NSString*)text viewWidth:(CGFloat)width;

@end
