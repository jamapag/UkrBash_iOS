//
//  VKAttachment.h
//  UkrBash
//
//  Created by Michail Grebionkin on 10.12.12.
//
//

#import <Foundation/Foundation.h>

extern NSString * kVKWallPostAttachmentURLType;
extern NSString * kVKWallPostAttachmentPhotoType;
extern NSString * kVKWallPostAttachmentVideoType;
extern NSString * kVKWallPostAttachmentAudioType;
extern NSString * kVKWallPostAttachmentDocType;

@interface VKWallPostAttachment : NSObject
{
    NSString * _type;
    NSString * _mediaId;
    NSString * _ownerId;
}

+ (id)wallPostAttachmentWithURL:(NSURL *)URL;
+ (id)wallPostAttachmentWithPhotoId:(NSString *)photoId ownerId:(NSString *)ownerId;
+ (id)wallPostAttachmentWithVideoId:(NSString *)videoId ownerId:(NSString *)ownerId;
+ (id)wallPostAttachmentWithAudioId:(NSString *)audioId ownerId:(NSString *)ownerId;
+ (id)wallPostAttachmentWithDocId:(NSString *)docId ownerId:(NSString *)ownerId;

- (NSString *)stringValue;

@end
