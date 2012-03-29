//
//  UBPicturesViewerControllerViewController.h
//  UkrBash
//
//  Created by Михаил Гребенкин on 21.03.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UBPicturesDataSource.h"
#import "UBPictureInfoView.h"

@interface UBPicturesViewerController : UIViewController
{
    UIButton *backButton;
    UBPictureInfoView *infoView;
    UIImageView *imageView;
    
    UBPicturesDataSource *dataSource;
    NSInteger pictureIndex;
}

@property (nonatomic) NSInteger pictureIndex;

- (id)initWithDataSource:(UBPicturesDataSource*)dataSource currentIndex:(NSInteger)index;

@end
