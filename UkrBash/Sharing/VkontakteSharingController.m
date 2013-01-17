//
//  VkontakteSharingController.m
//  UkrBash
//
//  Created by Michail Grebionkin on 03.12.12.
//
//

#import "VkontakteSharingController.h"
#import "VKRequest.h"
#import "ApiKey.h"
#import "Vkontakte.h"
#import "VKSharingView.h"
#import "VKXMLResponseParser.h"
#import "VKError.h"

#define VK_ACCESS_TOKEN_KEY @"VK_ACCESS_TOKEN_KEY"
#define VK_ACCESS_TOKEN_EXPIRATION_DATE_KEY @"VK_ACCESS_TOKEN_EXPIRATION_DATE_KEY"
#define VK_USER_ID_KEY @"VK_USER_ID_KEY"

@interface VkontakteSharingController()
{
    Vkontakte * vkontakte;
    NSString * attachmentTitle;
    NSString * attachmentDescription;
    UIImage * attachmentPreviewImage;
}

- (void)showLoginController;
- (void)showSharingController;
- (void)restoreVkontakte;

@end

@implementation VkontakteSharingController

- (id)init
{
    self = [super init];
    if (self) {
        [self restoreVkontakte];
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        [self restoreVkontakte];
    }
    return self;
}

- (void)dealloc
{
    if (vkontakte) {
        [vkontakte release];
    }
    [attachmentTitle release];
    [attachmentDescription release];
    [super dealloc];
}

- (void)restoreVkontakte
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    vkontakte = [[Vkontakte alloc] initWithAccessToken:[userDefaults objectForKey:VK_ACCESS_TOKEN_KEY]
                                        expirationDate:[userDefaults objectForKey:VK_ACCESS_TOKEN_EXPIRATION_DATE_KEY]
                                                userId:[userDefaults integerForKey:VK_USER_ID_KEY]];
    VKXMLResponseParser * vkontakteResponseParser = [[VKXMLResponseParser alloc] init];
    [vkontakte setResponseParser:vkontakteResponseParser];
    [vkontakteResponseParser release];
}

+ (BOOL)isSharingAvailable
{
    return YES;
}

- (void)showSharingDialog
{
    if (vkontakte && [vkontakte isAuthorized]) {
        [self showSharingController];
    } else {
        [self showLoginController];
    }
}

- (void)showLoginController
{
    VKLoginViewController * loginController = [[VKLoginViewController alloc] initWithAppId:kVKApplicationID
                                                                            andPermissions:@[@"offline", @"wall"]];
    loginController.vkLoginDelegate = self;
    [self.rootViewController presentModalViewController:loginController animated:YES];
    [loginController release];
}

- (void)showSharingController
{
    // sharing
    VKSharingView * sharingView = [[VKSharingView alloc] initWithVkontakte:vkontakte];
    [sharingView setAttachment:[VKWallPostAttachment wallPostAttachmentWithURL:[NSURL URLWithString:self.url]]];
    [sharingView setAttachmentDescription:attachmentDescription];
    [sharingView setAttachmentTitle:attachmentTitle];
    [sharingView setAttachmentImagePreview:attachmentPreviewImage];
    [sharingView setSuccessHandler:^{
        [sharingView hide];
    }];
    [sharingView setFailHandler:^(NSError * error) {
        NSAssert(error.code != VKInvalidParamsErrorCode, @"invalid params error");
        
        switch (error.code) {
            case VKApplicationDisabledErrorCode:
            case VKUserAuthorizationFailedErrorCode:
            case VKIncorrectSignatureErrorCode:
                // ask user to relogin
                [sharingView hide];
                [vkontakte invalidate];
                [self showLoginController];
                break;
                
            case VKAccessDeniedErrorCode:
            case VKAddingPostDeniedErrorCode:
            case VKPermissionDeniedErrorCode:
                // ask user to change app settings
            {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Помилка" message:@"Ця операція заборонена. Будьласка перегляньте налаштування додатку." delegate:nil cancelButtonTitle:@"ОК" otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
                break;
                
            case VKTooFrequentlyErrorCode:
            case VKTooManyRequestsErrorCode:
            case VKCaptchaRequiredErrorCode:
                // ask user to try again later
            {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Помилка" message:@"Будьласка спробуйте повторити спробу пізніше." delegate:nil cancelButtonTitle:@"ОК" otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
                break;
                
            case VKUnknownErrorCode:
                // show unknown error message
            {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Помилка" message:@"Трапилась невідома помилка. Будьласка спробуйте повторити спробу пізніше." delegate:nil cancelButtonTitle:@"ОК" otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
                break;
                
            case VKCanceledErrorCode:
                [sharingView hide];
                break;
                
            default:
                break;
        }
    }];
    [sharingView show];
    [sharingView release];
}

- (void)setAttachmentDescription:(NSString *)_attachmentDescription
{
    [attachmentDescription release];
    attachmentDescription = [_attachmentDescription retain];
}

- (void)setAttachmentTitle:(NSString *)_attachmentTitle
{
    [attachmentTitle release];
    attachmentTitle = [_attachmentTitle retain];
}

-(void)setAttachmentImagePreview:(UIImage *)_attachmentPreviewImage
{
    [attachmentPreviewImage release];
    attachmentPreviewImage = [_attachmentPreviewImage retain];
}

#pragma mark - VKLoginViewControllerDelegate

- (void)vkLoginViewController:(VKLoginViewController *)loginViewController didLoginWithAccessToken:(NSString *)accessToken expirationDate:(NSDate *)expirationDate userId:(NSInteger)userId
{
    NSAssert(loginViewController != nil, @"");
    NSAssert(accessToken != nil, @"invalid access token");
    NSAssert(expirationDate != nil, @"invalid expiration date");
    NSAssert(userId > 0, @"invalid user id");
    
    if (vkontakte) {
        [vkontakte release];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:VK_ACCESS_TOKEN_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:expirationDate forKey:VK_ACCESS_TOKEN_EXPIRATION_DATE_KEY];
    [[NSUserDefaults standardUserDefaults] setInteger:userId forKey:VK_USER_ID_KEY];
    
    vkontakte = [[Vkontakte alloc] initWithAccessToken:accessToken expirationDate:expirationDate userId:userId];

    VKXMLResponseParser * vkontakteResponseParser = [[VKXMLResponseParser alloc] init];
    [vkontakte setResponseParser:vkontakteResponseParser];
    [vkontakteResponseParser release];

    [self.rootViewController dismissModalViewControllerAnimated:YES];
    [self showSharingController];
}

- (void)vkLoginViewController:(VKLoginViewController *)loginViewController didFailWithError:(NSError *)error
{
    [self.rootViewController dismissModalViewControllerAnimated:YES];
}

@end
