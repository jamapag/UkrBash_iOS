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

- (UIImage *)activityImage
{
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        return [UIImage imageNamed:@"Default"];
    } else {
        return [UIImage imageNamed:@"Default"];
    }
}


- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    // TODO:
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    for (id object in activityItems) {
        if ([object isKindOfClass:[NSString class]]) {
            self.attachmentTitle = object;
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
        [sharingController setAttachmentTitle:self.attachmentTitle];
        [sharingController setAttachmentImagePreview:self.attachmentImage];
        [sharingController showSharingDialog];
    }];
}

@end
