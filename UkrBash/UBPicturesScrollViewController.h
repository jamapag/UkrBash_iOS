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
    id _parentController;
    UIView *toolbar;
    UIButton *backButton;
    
    int firstVisiblePageIndexBeforeRotation_;
    CGFloat percentScrolledIntoFirstVisiblePage_;
    
    id localImageLoadedObserver;
    id localPicturesLoadedObserver;
    
    bool loading;
    UIScrollView *scrollView;
    NSMutableArray *pictureViews;
    
    NSInteger currentPictureIndex;
    NSInteger pictureIndexBeforeRotation;
    UIView *activityView;
    UIActivityIndicatorView *loadingIndicator;
}

@property (nonatomic, assign) id parentController;

- (id)initWithDataSource:(UBPicturesDataSource *)aDataSource andStartPictureIndex:(NSInteger)startIndex;

@end
