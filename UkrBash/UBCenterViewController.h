//
//  UBCenterViewController.h
//  UkrBash
//
//  Created by Maks Markovets on 27.10.14.
//
//

#import <UIKit/UIKit.h>
#import "UBViewController.h"

@protocol UBCenterViewControllerDelegate <NSObject>

@optional
- (void)movePanelRight;

@required
- (void)movePanelToOriginalPosition;

@end

@interface UBCenterViewController : UBViewController

@property (nonatomic, assign) id<UBCenterViewControllerDelegate> delegate;

@end
