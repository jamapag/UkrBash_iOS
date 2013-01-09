//
//  VKSharingViewController.h
//  UkrBash
//
//  Created by Michail Grebionkin on 06.12.12.
//
//

#import <UIKit/UIKit.h>
#import "Vkontakte.h"
#import "VKWallPostAttachment.h"

typedef void(^VKSharingViewSuccessHandler) (void);
typedef void(^VKSharingViewFailHandler) (NSError * error);

@interface VKSharingView : UIView

@property (nonatomic, copy) VKSharingViewSuccessHandler successHandler;
@property (nonatomic, copy) VKSharingViewFailHandler failHandler;

- (id)initWithVkontakte:(Vkontakte *)vkontakte;
- (void)setAttachment:(VKWallPostAttachment *)attachment;
- (void)setAttachmentTitle:(NSString *)attachmentTitle;
- (void)setAttachmentDescription:(NSString *)attachmentDescription;
- (void)setAttachmentImagePreview:(UIImage *)previewImage;
- (void)show;
- (void)hide;

@end
