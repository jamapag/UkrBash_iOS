//
//  BaseSharer.h
//  
//
//  Created by Maks Markovets on 22.03.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IsSharingNetworkTypeValid(networkType) (((networkType) >= SharingFacebookNetwork && (networkType) < SharingNetworkTypeCount) ? YES : NO)

typedef enum {
    SharingFacebookNetwork = 1,
    SharingTwitterNetwork,
    SharingEMailNetwork,
    SharingVkontakteNetwork,
    SharingNetworkTypeCount
} SharingNetworkType;

@interface SharingController : NSObject
{
    NSMutableArray * images;
}

@property (nonatomic, retain) UIViewController * rootViewController;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, readonly) SharingNetworkType networkType;

/**
 * Returns YES if network available for sharing and NO otherwise. Logic of this method
 * realized in subclasses.
 */
+ (BOOL)isSharingAvailableForNetworkType:(SharingNetworkType)networkType;

+ (id)sharingControllerForNetworkType:(SharingNetworkType)networkType;

- (id)initWithRootViewController:(UIViewController*)rootViewController;

- (void)addImage:(UIImage*)image;
- (void)removeAllImages;
- (void)showSharingDialog;

- (void)setAttachmentTitle:(NSString *)attachmentTitle;
- (void)setAttachmentDescription:(NSString *)attachmentDescription;
- (void)setAttachmentImagePreview:(UIImage *)attachmentPreviewImage;

@end
