//
//  MediaCenter.m
//  
//  Created by Dymok on 2/19/09.
//  Copyright 2009 Lidia Rudyuk. All rights reserved.
//


#import <CommonCrypto/CommonDigest.h>
#import "MediaCenter.h"
#import "ImageCenterFriend.h"
#import "DownloadOperations.h"


#define urlStackSize 999
#define DEBUG_LOG(...) 

#define kInfinity -1

NSString *kMediaCenterErrorDomain = @"MediaCenter";


@interface MediaCenter ()

- (NSString *) pathFromURL: (NSURL *) url;
+ (NSString*) md5:(NSString*)str;

@end


@implementation MediaCenter


+ (NSString*)md5:(NSString*)str {
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, strlen(cStr), result );
	
	return [NSString 
			stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1],
			result[2], result[3],
			result[4], result[5],
			result[6], result[7],
			result[8], result[9],
			result[10], result[11],
			result[12], result[13],
			result[14], result[15]
			];
}


//+(id) alloc {
//    NSAssert(defaultImageCenter == nil, @"Attempt to allocate a second instance of ImageCenter");
//    defaultImageCenter = [super alloc];
//    return defaultImageCenter;
//}


-(id) init {
	self = [super init];
	if (self != nil) {
        objectsCache = [[NSMutableDictionary alloc]init];
		urlStack = [[NSMutableArray alloc] initWithCapacity:urlStackSize];
        activeDownloads = [[NSMutableDictionary alloc]init];
        [self setCacheDirectory:[NSTemporaryDirectory() stringByAppendingPathComponent:@"mediaCenterCache"]];
		
		cachedObjectsTTL = 3600 * 24 * 2;
		numberOfParallelDownloads = 2;

		[NSThread detachNewThreadSelector:@selector(cleanupOldObjects) toTarget:self withObject:nil];
		
		downloadQueue = [[NSOperationQueue alloc] init];
		[downloadQueue setMaxConcurrentOperationCount:2];
	}
	return self;
}


- (void)setCachedObjectsTTL:(NSInteger)seconds {
	@synchronized (self) {
		cachedObjectsTTL = seconds;
	}
}


- (void)setNumberOfParallelDownloads:(NSInteger)n {
	@synchronized (self) {
		numberOfParallelDownloads = n;
		[downloadQueue setMaxConcurrentOperationCount:n];
	}
}


- (void)setCacheDirectory:(NSString*)directory {
	[cacheDirectory release];
	cacheDirectory = [directory copy];
	if (![[NSFileManager defaultManager] fileExistsAtPath: cacheDirectory]) {
//		[[NSFileManager defaultManager] createDirectoryAtPath: cacheDirectory attributes:nil];
		NSError *error = nil;
		[[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory
								  withIntermediateDirectories:YES 
												   attributes:nil
														error:&error];
	}
}


-(void) cleanupOldObjects {
	if (cachedObjectsTTL == kInfinity) {
		return;
	}
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:cacheDirectory];
    NSString *file;
    NSString *path;
    NSError *err;
    NSDate *minAllowedTime = [NSDate dateWithTimeIntervalSinceNow:-cachedObjectsTTL];
    NSDate *now = [NSDate date];
    while(file = [enumerator nextObject]) {
        err = nil;
        path = [cacheDirectory stringByAppendingFormat:@"/%@",file];
        NSDictionary *attrs = [[NSFileManager defaultManager]attributesOfItemAtPath:path error:&err];
        if (err) {
            DEBUG_LOG(@"error: %@(%@)",[err localizedDescription],path);
        }
        if (!attrs) continue;
        NSString *type = [attrs objectForKey:NSFileType];
        NSDate *mTime = [attrs objectForKey:NSFileModificationDate];
        if ([type isEqualToString:NSFileTypeRegular] && 
			([mTime compare:minAllowedTime] == NSOrderedAscending || [mTime compare:now] == NSOrderedDescending)) {
			
            DEBUG_LOG(@"removing expired object:%@",path);
            err = nil;
            [[NSFileManager defaultManager] removeItemAtPath:path error:&err];
            if (err) {
                DEBUG_LOG(@"Error removing expired object from file cache:%@",[err localizedDescription]);
            }
        }
    }
    [pool release];
}


-(void) pushUrlToQueue:(NSString*)url {
    @synchronized(self) {
        int i;
        for(i=[urlStack count]-1;i>=0;i--) {
            if ([[[urlStack objectAtIndex:i] objectForKey:@"url"] isEqualToString:url]) {
                [urlStack removeObjectAtIndex:i];
            }
        }
        i = 0;
        NSTimeInterval now = [[NSDate date] timeIntervalSinceReferenceDate];
        while(i<[urlStack count] && now - [[[urlStack objectAtIndex:i] objectForKey:@"timeAdded"]doubleValue] <= 2) i++;
        [urlStack insertObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                url,@"url",
                                [NSNumber numberWithDouble:now],@"timeAdded",
                                nil] atIndex:i];
        while ([urlStack count] > urlStackSize) {
            [urlStack removeLastObject];
        }
    }
}


-(void) cleanUpQueue {
    [urlStack release];
	urlStack = nil;
    [activeDownloads release];
	activeDownloads = nil;
}


-(void) clearCache {
    DEBUG_LOG(@"clear cache. Removing %d images", [imagesCache count]);
    [objectsCache removeAllObjects];
}


#pragma mark -


- (void) addDownloadOperation:(NSOperation*)operatoin {
	[downloadQueue addOperation:operatoin];
}



-(void) dealloc {
	[objectsCache release];
	objectsCache = nil;
    [self cleanUpQueue];
	[cacheDirectory release];
	
	[downloadQueue release];

	[super dealloc];
}


#pragma mark -
#pragma mark "Private" Methods


-(BOOL) cacheData:(NSData*)data withURL: (NSURL *)url {
    NSString *path = [self pathFromURL: url];
    NSLock *lock = [[NSLock alloc] init];
    [lock setName:@"data caching"];
    [lock lock];    
    BOOL res = [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
    if (!res) {
        NSLog(@"Error creating fiel at path:%@",path);
        NSError *err = nil;
        [[NSFileManager defaultManager]removeItemAtPath:path error:&err];
        if (err) {
            NSLog(@"Error while removing file: %@",[err localizedDescription]);
        }
    }
    [lock unlock];
    [lock release];
    return res;
}


-(NSString *) pathFromURL: (NSURL *) url {
	if (![[NSFileManager defaultManager] fileExistsAtPath: cacheDirectory]) {
		NSError *error = nil;
		[[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory
								  withIntermediateDirectories:YES
												   attributes:nil
														error:&error];
//		[[NSFileManager defaultManager] createDirectoryAtPath: cacheDirectory attributes:nil];
	}
	NSString *path = [MediaCenter md5:[url path]];
	
	NSString *subDir = [cacheDirectory stringByAppendingString:[@"/" stringByAppendingString: [path substringToIndex:1]]];
	if (![[NSFileManager defaultManager] fileExistsAtPath: subDir]) {
		NSError *error = nil;
		[[NSFileManager defaultManager] createDirectoryAtPath:subDir
								  withIntermediateDirectories:YES
												   attributes:nil
														error:&error];
//		[[NSFileManager defaultManager] createDirectoryAtPath: subDir attributes:nil];
	}
	
	NSMutableString *fullPath = [NSMutableString stringWithString:subDir];
	[fullPath appendString:@"/"];
	[fullPath appendString:[path substringFromIndex: 1]];
	[fullPath appendString:[[url path] lastPathComponent]];
	return fullPath;
}


@end


//@interface ImageCenter(Private)
//
//- (void) downloadEnded:(NSString*)url;
//- (NSString*) popUrlFromQueue;
//
//@end

#pragma mark -


@implementation MediaCenter(Friend)


-(NSString*) popUrlFromQueue {
	NSString *ret = nil;
	@synchronized([MediaCenter imageCenter]) {
		if ([urlStack count]) {
			ret = [NSString stringWithString:[[urlStack objectAtIndex:0] objectForKey:@"url"]];
			[urlStack removeObjectAtIndex:0];
		}
	}
	return ret;
}


-(void) downloadEnded:(NSString*)url {
	@synchronized([MediaCenter imageCenter]) {
		[activeDownloads removeObjectForKey:url];
	}
	NSString *nextImage = [self popUrlFromQueue];
	if (nextImage) {
		[self imageWithUrl:nextImage];
	}
}


@end


#pragma mark -


NSString *kImageCenterNotification_didLoadImage = @"ImageCenterNotification_didLoadImage";
NSString *kImageCenterNotification_didFailToLoadImage = @"ImageCenterNotification_didFailToLoadImage";
NSString *kImageCenterLoadImageAction = @"kImageCenterLoadImageAction";


@implementation MediaCenter(ImageCenter)


static NSMutableArray *downloadedImages = nil;


- (void)timerHandler:(NSTimer*)timer {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@synchronized (self) {
		if ([downloadedImages count]) {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSArray arrayWithArray:downloadedImages] forKey:@"imageUrl"];
            NSNotification *nofication = [NSNotification notificationWithName:kImageCenterNotification_didLoadImage object:nil userInfo:userInfo];
            [[NSNotificationQueue defaultQueue] enqueueNotification:nofication postingStyle:NSPostASAP];
			[downloadedImages removeAllObjects];
		}
	}
	[pool drain];
}


+ (MediaCenter*)imageCenter {
	static MediaCenter *defaultImageCenter = nil;
	@synchronized (self) {
		if (defaultImageCenter == nil) {
			defaultImageCenter = [[MediaCenter alloc] init];
			downloadedImages = [[NSMutableArray alloc] init];

			NSTimer *notificationsTimer = [NSTimer timerWithTimeInterval:2. 
																  target:defaultImageCenter
																selector:@selector(timerHandler:)
																userInfo:nil
																 repeats:YES];
			[[NSRunLoop mainRunLoop] addTimer:notificationsTimer forMode:NSDefaultRunLoopMode];
			[notificationsTimer fire];
//			NSLog(@"images notification timer started");
		}
	}
	return defaultImageCenter;
}


- (void)imageWithUrlDownloadEnded:(NSString *)imageUrl {
	@synchronized (self) {
		[downloadedImages addObject:imageUrl];
	}
}


-(UIImage *) imageFromFileSystemWithURL: (NSURL *) url {
    if ([objectsCache objectForKey:[url absoluteString]]) {
        return [objectsCache objectForKey:[url absoluteString]];
    }
	NSError * errorPtr = nil;
    NSLock *lock = [[NSLock alloc] init];
    [lock setName:@"image caching"];
    [lock lock];
	UIImage *retImage = [UIImage imageWithData: [NSData dataWithContentsOfURL: url options: NSMappedRead error: &errorPtr]];
    if (retImage) {
        [objectsCache setObject:retImage forKey:[url absoluteString]];
    }
    [lock unlock];
    [lock release];
	if (errorPtr)
		DEBUG_LOG(@"error %@", errorPtr);
	
	return retImage;
}


-(UIImage *) imageFromCacheByURL: (NSURL *) url {
    if ([objectsCache objectForKey:[url absoluteString]]) {
        return [objectsCache objectForKey:[url absoluteString]];
    }
	NSString *path = [self pathFromURL: url];
	NSData *data = [[NSFileManager defaultManager] contentsAtPath: path];
	UIImage *retImage = nil;
	if (data)
		retImage = [UIImage imageWithData:data];
    if (retImage) {
    }
	if (retImage == nil && [[NSFileManager defaultManager] fileExistsAtPath:path]) {
//        NSError *err=nil;
//		[[NSFileManager defaultManager] removeItemAtPath:path error:&err];
//        if (err) {
//            DEBUG_LOG(@"%@",[err localizedDescription]);
//        }
//        [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"corrupted" ofType:@"png"]
//                                                toPath:path error:&err];
//        if (err) {
//            DEBUG_LOG(@"%@",[err localizedDescription]);
//        }
//		retImage = [UIImage imageWithContentsOfFile:path];
	}
    if (retImage) {
        [objectsCache setObject:retImage forKey:[url absoluteString]];
    }
	
	return retImage;
}


-(UIImage *) imageWithUrl: (NSString *) imageUrl priority:(NSOperationQueuePriority)priority {
	UIImage *retImage = nil;
	NSURL *url = [NSURL URLWithString: imageUrl];
	if (url == nil)
		return nil;
	
	if ([url isFileURL]) {
		retImage = [self imageFromFileSystemWithURL: url];
	}
	else {
        retImage = [self imageFromCacheByURL:url];
        if (retImage) {
            return retImage;
        }
		else {
//			[self AsyncImageFromHTTPWithURL: url];
//			[self AsyncDataFromHTTPWithURL: url withLoader:[ImageLoader loaderWithURL:url]];
			DownloadImageOperation *operation = [[DownloadImageOperation alloc] initWithURLString:imageUrl];
			[operation setQueuePriority:priority];
			[downloadQueue addOperation:operation];
			[operation release];
		}
	}
	return retImage;
}


-(UIImage *) imageWithUrl: (NSString *) imageUrl {
	return [self imageWithUrl:imageUrl priority:NSOperationQueuePriorityNormal];
}


- (void)cancelLoadingImagesWithURLs:(NSArray*)URLs {
    for (DownloadImageOperation *downloadOperation in [downloadQueue operations]) {
        if ([URLs containsObject:downloadOperation.urlString]) {
            [downloadOperation cancel];
        }
    }
}


@end


#pragma mark -


NSString *kMp3CenterNotification_didLoadMp3 = @"Mp3CenterNotification_didLoadMp3";
NSString *kMp3CenterNotification_didFailToLoadMp3 = @"Mp3CenterNotification_didFailToLoadMp3";
NSString *kMp3CenterNotification_loadingProgressUpdate = @"kMp3CenterNotification_loadingProgressUpdate";


@implementation MediaCenter(Mp3Center)


+ (MediaCenter*)mp3Center {
	static MediaCenter *mp3Center = nil;
	@synchronized (self) {
		if (mp3Center == nil) {
			mp3Center = [[MediaCenter alloc] init];
			[mp3Center setCachedObjectsTTL:kInfinity];
			[mp3Center setNumberOfParallelDownloads:1];
		}
	}
	return mp3Center;
}


- (NSData*)mp3FromFileSystemWithURL:(NSURL*) url {
	NSError * errorPtr = nil;
	NSData *mp3Data = [NSData dataWithContentsOfURL: url options: NSMappedRead error: &errorPtr];
	if (errorPtr)
		DEBUG_LOG(@"error %@", errorPtr);
	
	return mp3Data;
}


- (BOOL)isUrlStringPending:(NSString*)urlString {
	for (DownloadMp3Operation *operation in [downloadQueue operations]) {
		if ([operation.urlString isEqualToString:urlString]) {
			return YES;
		}
	}
	return NO;
}


- (NSData*)mp3WithUrl:(NSString*)mp3Url {
	return [self mp3WithUrl:mp3Url priority:NSOperationQueuePriorityNormal];
}


- (NSData*)mp3WithUrl:(NSString *)mp3Url priority:(NSOperationQueuePriority)priority {
	NSData *mp3Data = nil;
	NSURL *url = [NSURL URLWithString: mp3Url];
	if (url == nil)
		return nil;
	
	if ([url isFileURL]) {
		mp3Data = [self mp3FromFileSystemWithURL: url];
	}
	else {
		mp3Data = [[NSFileManager defaultManager] contentsAtPath: [self pathFromURL:url]];
        if (mp3Data) {
            return mp3Data;
        }
		else if ([self isUrlStringPending:mp3Url]) {
			return nil;
		}
		else {
			DownloadMp3Operation *operation = [[DownloadMp3Operation alloc] initWithURLString:mp3Url];
			[operation setQueuePriority:priority];
			[downloadQueue addOperation:operation];
			[operation release];
		}
	}
	return mp3Data;
}


- (BOOL)isMp3CachedWithUrl:(NSString*)mp3Url {
	NSURL *url = [NSURL URLWithString: mp3Url];
	if (url == nil)
		return NO;
	if ([url isFileURL]) {
		NSString *u = [[url absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
		return [[NSFileManager defaultManager] fileExistsAtPath:u];
	}
	return [[NSFileManager defaultManager] fileExistsAtPath:[self pathFromURL:url]];
}


@end
