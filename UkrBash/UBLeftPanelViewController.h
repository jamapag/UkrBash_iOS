//
//  UBLeftViewController.h
//  UkrBash
//
//  Created by Maks Markovets on 27.10.14.
//
//

#import <UIKit/UIKit.h>
#import "UBViewController.h"
#import "UBQuotesDataSource.h"
#import "UBPicturesDataSource.h"

@protocol UBLeftPanelViewControllerDelegate <NSObject>
@required
- (void)quotesWithDataSourceSelected:(Class)dataSource withTitle:(NSString *)title;
- (void)picturesWithDataSourceSelected:(Class)dataSource withTitle:(NSString *)title;
- (void)donateControllerSelected;
@end


@interface UBLeftPanelViewController : UBViewController

@property (nonatomic, assign) id<UBLeftPanelViewControllerDelegate> delegate;

@end
