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

@interface UBFullSizePictureViewController : UBViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
{
    UIPageViewController *pageViewController;
    UBPicturesDataSource *dataSource;
    UBFetchedPicturesDataSource *fetchedDataSource;
    UBPictureInfoView *infoView;
    UIView *toolbar;
    UIButton *backButton;
    
    
    NSInteger currentPictureIndex;
    NSInteger initPictureIndex;
}

@property (nonatomic, retain) UBPicturesDataSource *dataSource;

- (id)initWithDataSource:(UBPicturesDataSource *)aDataSource andInitPicuteIndex:(NSInteger)index;
- (void)setCurrentPictureIndex:(NSInteger)pictureIndex;

@end
