//
//  UBVkontakteActivity.m
//  UkrBash
//
//  Created by Maks Markovets on 13.05.14.
//
//

#import "UBVkontakteActivity.h"
#import "SharingController.h"

@implementation UBVkontakteActivity

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryShare;
}

- (NSString *)activityType
{
    return UBVkontakteActivityType;
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"Vkontakte", nil);
}

- (UIImage *)_activityImage
{
    if (!IS_PAD) {
        if (IS_LATER_IOS6) {
            return [UIImage imageNamed:@"vk-icon-60.png"];
        } else {
            return [UIImage imageNamed:@"vk-icon-43"];
        }
    } else {
        if (IS_LATER_IOS6) {
            return [UIImage imageNamed:@"vk-icon-76"];
        } else {
            return [UIImage imageNamed:@"vk-icon-60"];
        }
    }
}


- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    // TODO: add activity items checking.
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    for (id object in activityItems) {
        if ([object isKindOfClass:[NSString class]]) {
            self.attachmentDescription = object;
        } else if ([object isKindOfClass:[UIImage class]]) {
            self.attachmentImage = object;
        } else if ([object isKindOfClass:[NSURL class]]) {
            self.url = object;
        }
    }
}

- (void)performActivity
{
    [self.parentViewController.presentedViewController dismissViewControllerAnimated:YES completion:^{
        SharingController *sharingController = [SharingController sharingControllerForNetworkType:SharingVkontakteNetwork];
        sharingController.url = self.url;
        sharingController.rootViewController = self.parentViewController;
        [sharingController setAttachmentDescription:self.attachmentDescription];
        [sharingController setAttachmentTitle:self.attachmentTitle];
        [sharingController setAttachmentImagePreview:self.attachmentImage];
        [sharingController showSharingDialog];
    }];
}

@end
