//
//  UBMainViewController.h
//  UkrBash
//
//  Created by Maks Markovets on 27.10.14.
//
//

#import <UIKit/UIKit.h>
#import "UBCenterViewController.h"
#import "UBLeftPanelViewController.h"

@interface UBMainViewController : UIViewController <UBCenterViewControllerDelegate, UBLeftPanelViewControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, retain) UBCenterViewController *centerViewController;
@property (nonatomic, retain) UBLeftPanelViewController *leftPanelViewController;
@property (nonatomic, assign) BOOL showingLeftPanel;
@property (nonatomic, assign) BOOL showPanel;
@property (nonatomic, assign) CGPoint preVelocity;

- (id)initWithContainerController:(UBCenterViewController *)containerController;

@end
