//
//  UBPictureViewController.h
//  UkrBash
//
//  Created by Maks Markovets on 13.05.14.
//
//

#import <UIKit/UIKit.h>

@interface UBPictureViewController : UIViewController <UIScrollViewDelegate>
{
    UIImageView *imageView;
    UIScrollView *scrollView;
}

@property (nonatomic, assign) NSInteger pictureIndex;
@property (nonatomic, retain) NSString *imageUrl;
@property (nonatomic, retain) NSString *fullScreenImageUrl;

- (void)doubleTapAtPoint:(CGPoint)center;
- (void)zoomOutIfNeeded;

@end
