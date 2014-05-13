//
//  UBVkontakteActivity.h
//  UkrBash
//
//  Created by Maks Markovets on 13.05.14.
//
//

#import <UIKit/UIKit.h>

static NSString * const UBVkontakteActivityType = @"net.smile2mobile.activity.UBVkontakte";

@interface UBVkontakteActivity : UIActivity

@property (nonatomic, retain) UIViewController *parentViewController;
@property (nonatomic, retain) NSString *attachmentTitle;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) UIImage *attachmentImage;

@end
