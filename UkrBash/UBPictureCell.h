//
//  UBImageCell.h
//  UkrBash
//
//  Created by Михаил Гребенкин on 03.02.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "UBQuoteCell.h"

@interface UBPictureCell : UBQuoteCell
{
    UIImageView *imageView;
}

@property (nonatomic, readonly) UIImageView *imageView;

@end
