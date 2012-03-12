//
//  MediaCenter.h
//
//  Created by Dymok on 2/19/09.
//  Copyright 2009 Lidia Rudyuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


extern NSString *kMediaCenterErrorDomain;


typedef enum {
	MediaCenterErrorNoError = 0,
	MediaCenterErrorWrongMIMEType
} MediaCenterErrors;


@interface MediaCenter : NSObject {
	NSMutableArray *urlStack;
	NSMutableDictionary *activeDownloads;
	NSMutableDictionary *objectsCache;
	
	NSInteger cachedObjectsTTL; // default 3 days
	NSInteger numberOfParallelDownloads; // default 2
	NSString *cacheDirectory; // default "(HOME)/Documents/imageCenterCache"
	
	NSOperationQueue *downloadQueue;
}

- (void)setCachedObjectsTTL:(NSInteger)seconds;
- (void)setNumberOfParallelDownloads:(NSInteger)n;
- (void)setCacheDirectory:(NSString*)directory;

- (BOOL) cacheData:(NSData*)image withURL: (NSURL *)url;
- (void) pushUrlToQueue:(NSString*)url;
- (void) cleanUpQueue;
- (void) clearCache;

- (void) addDownloadOperation:(NSOperation*)operatoin;

@end


#pragma mark -
#pragma mark Image Center extantion


extern NSString *kImageCenterNotification_didLoadImage;
extern NSString *kImageCenterNotification_didFailToLoadImage;
extern NSString *kImageCenterLoadImageAction;


@interface MediaCenter(ImageCenter)

+ (MediaCenter*)imageCenter;

- (UIImage*)imageWithUrl:(NSString*)imageUrl;
-(UIImage *) imageWithUrl: (NSString *) imageUrl priority:(NSOperationQueuePriority)priority;

- (void)imageWithUrlDownloadEnded:(NSString *)imageUrl;

- (void)cancelLoadingImagesWithURLs:(NSArray*)URLs;

@end


#pragma mark -
#pragma mark Mp3 Center extantion


extern NSString *kMp3CenterNotification_didLoadMp3;
extern NSString *kMp3CenterNotification_didFailToLoadMp3;
extern NSString *kMp3CenterNotification_loadingProgressUpdate;


@interface MediaCenter(Mp3Center)

+ (MediaCenter*)mp3Center;

- (NSData*)mp3WithUrl:(NSString*)mp3Url;
- (NSData*)mp3WithUrl:(NSString*)mp3Url priority:(NSOperationQueuePriority)priority;
- (BOOL)isMp3CachedWithUrl:(NSString*)mp3Url;

@end


