//
//  VKLoginViewController.h
//  UkrBash
//
//  Created by Michail Grebionkin on 18.10.12.
//
//

#import <UIKit/UIKit.h>

@class VKLoginViewController;

@protocol VKLoginViewControllerDelegate <NSObject>

- (void)vkLoginViewController:(VKLoginViewController *)loginViewController didLoginWithAccessToken:(NSString *)accessToken expirationDate:(NSDate *)expirationDate userId:(NSInteger)userId;
- (void)vkLoginViewController:(VKLoginViewController *)loginViewController didFailWithError:(NSError *)error;

@end

@interface VKLoginViewController : UINavigationController <UIWebViewDelegate>
{
    NSArray * permissions;
    NSString * appId;
    id <VKLoginViewControllerDelegate> vkLoginDelegate;
}

@property (nonatomic, retain) NSArray * permissions;
@property (nonatomic, readonly) NSString * appId;
@property (nonatomic, retain) id <VKLoginViewControllerDelegate> vkLoginDelegate;

- (id)initWithAppId:(NSString*)appId;
- (id)initWithAppId:(NSString *)appId andPermissions:(NSArray*)permissions;

@end
