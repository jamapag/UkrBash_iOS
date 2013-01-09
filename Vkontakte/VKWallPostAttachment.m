//
//  VKAttachment.m
//  UkrBash
//
//  Created by Michail Grebionkin on 10.12.12.
//
//

#import "VKWallPostAttachment.h"

NSString * kVKWallPostAttachmentURLType = @"url";
NSString * kVKWallPostAttachmentPhotoType = @"photo";
NSString * kVKWallPostAttachmentVideoType = @"video";
NSString * kVKWallPostAttachmentAudioType = @"audio";
NSString * kVKWallPostAttachmentDocType = @"doc";

@interface VKWallPostAttachment ()

- (id)initWithType:(NSString *)type mediaId:(NSString *)mediaId ownerId:(NSString *)ownerId;

@end

@implementation VKWallPostAttachment

+ (id)wallPostAttachmentWithAudioId:(NSString *)audioId ownerId:(NSString *)ownerId
{
    return [[[self alloc] initWithType:kVKWallPostAttachmentAudioType mediaId:audioId ownerId:ownerId] autorelease];
}

+ (id)wallPostAttachmentWithDocId:(NSString *)docId ownerId:(NSString *)ownerId
{
    return [[[self alloc] initWithType:kVKWallPostAttachmentDocType mediaId:docId ownerId:ownerId] autorelease];
}

+ (id)wallPostAttachmentWithPhotoId:(NSString *)photoId ownerId:(NSString *)ownerId
{
    return [[[self alloc] initWithType:kVKWallPostAttachmentPhotoType mediaId:photoId ownerId:ownerId] autorelease];
}

+ (id)wallPostAttachmentWithURL:(NSURL *)URL
{
    return [[[self alloc] initWithType:kVKWallPostAttachmentURLType mediaId:[URL absoluteString] ownerId:nil] autorelease];
}

+ (id)wallPostAttachmentWithVideoId:(NSString *)videoId ownerId:(NSString *)ownerId
{
    return [[[self alloc] initWithType:kVKWallPostAttachmentVideoType mediaId:videoId ownerId:ownerId] autorelease];
}

- (id)initWithType:(NSString *)type mediaId:(NSString *)mediaId ownerId:(NSString *)ownerId
{
    self = [super init];
    if (self) {
        _type = [type copy];
        _mediaId = [mediaId copy];
        _ownerId = [ownerId copy];
    }
    return self;
}

- (NSString *)stringValue
{
    if ([_type isEqualToString:kVKWallPostAttachmentURLType]) {
        return _mediaId;
    }
    return [NSString stringWithFormat:@"%@%@_%@", _type, _ownerId, _mediaId];
}

- (void)dealloc
{
    [_type release];
    [_mediaId release];
    [_ownerId release];
    [super dealloc];
}

@end
