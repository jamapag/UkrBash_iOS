//
//  UBPicturesScrollViewControllerViewController.h
//  UkrBash
//
//  Created by Maks Markovets on 05.07.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UBPicturesDataSource.h"
#import "UBPictureInfoView.h"

@interface UBPicturesScrollViewController : UIViewController <UIScrollViewDelegate>
{
    UBPicturesDataSource *dataSource;
    UBPictureInfoView *infoView;
    UIView *toolbar;
    UIButton *backButton;
    
    int firstVisiblePageIndexBeforeRotation_;
    CGFloat percentScrolledIntoFirstVisiblePage_;
    
    UIScrollView *scrollView;
    NSMutableArray *pictureViews;
    
    NSInteger currentPictureIndex;
}

- (id)initWithDataSource:(UBPicturesDataSource *)aDataSource andStartPictureIndex:(NSInteger)startIndex;

@end
