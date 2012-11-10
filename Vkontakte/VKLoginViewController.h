//
//  VKLoginViewController.h
//  UkrBash
//
//  Created by Michail Grebionkin on 18.10.12.
//
//

#import <UIKit/UIKit.h>

@interface VKLoginViewController : UINavigationController
{
    NSArray * permissions;
    NSString * appId;
}

@property (nonatomic, retain) NSArray * permissions;
@property (nonatomic, readonly) NSString * appId;

- (id)initWithAppId:(NSString*)appId;
- (id)initWithAppId:(NSString *)appId andPermissions:(NSArray*)permissions;

@end
