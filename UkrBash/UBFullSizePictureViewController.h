//
//  UBFullSizePictureViewController.h
//  UkrBash
//
//  Created by Maks Markovets on 13.05.14.
//
//

#import <UIKit/UIKit.h>
#import "UBFetchedPicturesDataSource.h"
#import "UBPictureInfoView.h"
#import "UBViewController.h"

@class UBFullSizePictureViewController;

@protocol UBFullSizePictureViewControllerDelegate <NSObject>

- (void)userDidScroll:(UBFullSizePictureViewController *)viewController toPictureAtIndex:(NSInteger)index;
- (void)updatePictureAtIndex:(NSInteger)index;

@end

@interface UBFullSizePictureViewController : UBViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
{
    UIPageViewController *pageViewController;
    UBPicturesDataSource *dataSource;
    UBFetchedPicturesDataSource *fetchedDataSource;
    UBPictureInfoView *infoView;
    UIView *toolbar;
    UIButton *backButton;
    UIButton *favoriteButton;
    
    id <UBFullSizePictureViewControllerDelegate> delegate;
    
    NSInteger currentPictureIndex;
    NSInteger initPictureIndex;
}

@property (nonatomic, assign) id <UBFullSizePictureViewControllerDelegate> delegate;
@property (nonatomic, retain) UBPicturesDataSource *dataSource;

- (id)initWithDataSource:(UBPicturesDataSource *)aDataSource andInitPicuteIndex:(NSInteger)index;
- (void)setCurrentPictureIndex:(NSInteger)pictureIndex animated:(BOOL)animated;

@end
