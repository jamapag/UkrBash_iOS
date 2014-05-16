//
//  DownloadOperations.m
//
//  Created by Michail Grebionkin on 19.03.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DownloadOperations.h"
#import "MediaCenter.h"


@implementation DownloadImageOperation


@synthesize urlString;


- (NSString*)actionType {
	return kImageCenterLoadImageAction;
}

//- (void)setCompletion:(UBImageDownloadedCallback)completion
//{
//    if (_completion) {
//        Block_release(_completion);
//    }
//    _completion = Block_copy(completion);
//}


- (id)initWithURLString:(NSString*)_urlString {
	self = [super init];
	if (self != nil) {
		urlString = [_urlString retain];
		fileData = [[NSMutableData alloc] init];
		done = NO;
	}
	return self;
}


- (void)dealloc {
	[urlString release];
	[fileData release];
    [_completion release];
	[super dealloc];
}


- (void)main {
    if ([self isCancelled]) {
        return;
    }
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	NSURL *url = [NSURL URLWithString:urlString];
//	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
	
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[connection start];
	while (!done) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        if ([self isCancelled]) {
            [connection cancel];
            done = YES;
        }
	}
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[connection release];
        
    [pool drain];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[fileData setLength:0];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[fileData appendData:data];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	done = YES;
	NSDictionary *info = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSArray arrayWithObject:urlString], error, nil] 
													 forKeys:[NSArray arrayWithObjects:@"imageUrl", @"error", nil]];
    NSNotification *nofication = [NSNotification notificationWithName:kImageCenterNotification_didFailToLoadImage object:nil userInfo:info];
    [[NSNotificationQueue defaultQueue] enqueueNotification:nofication postingStyle:NSPostASAP];
//	[[MyAppsApplication sharedApplication] enqueueNotificationWithName:kImageCenterNotification_didFailToLoadImage 
//															  userInfo:info
//														  postingStyle:NSPostWhenIdle];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	[[MediaCenter imageCenter] cacheData:fileData withURL:url];
	[[MediaCenter imageCenter] imageWithUrlDownloadEnded:urlString];
	[url release];
	done = YES;
    if (self.completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageWithData:fileData];
            self.completion(image);
        });
    }
}


@end


#pragma mark -


@implementation DownloadMp3Operation


@synthesize urlString;


- (id)initWithURLString:(NSString*)_urlString {
	self = [super init];
	if (self != nil) {
		urlString = [_urlString retain];
		fileData = [[NSMutableData alloc] init];
		done = NO;
	}
	return self;
}


- (void)dealloc {
	[urlString release];
	[fileData release];
	[super dealloc];
}


- (void)main {
	NSURL *url = [NSURL URLWithString:urlString];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[connection start];
	while (!done) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	}
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[connection release];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[fileData setLength:0];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[fileData appendData:data];
	NSDictionary *info = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:urlString, [NSNumber numberWithUnsignedInteger:[fileData length]], nil] 
													 forKeys:[NSArray arrayWithObjects:@"mp3Url", @"bytesLoaded", nil]];
	[[NSNotificationCenter defaultCenter] postNotificationName:kMp3CenterNotification_loadingProgressUpdate object:nil userInfo:info];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	done = YES;
	NSDictionary *info = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:urlString, error, nil] 
													 forKeys:[NSArray arrayWithObjects:@"mp3Url", @"error", nil]];
	[[NSNotificationCenter defaultCenter] postNotificationName:kMp3CenterNotification_didFailToLoadMp3 object:nil userInfo:info];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	done = YES;
	NSURL *url = [NSURL URLWithString:urlString];
	[[MediaCenter mp3Center] cacheData:fileData withURL:url];
	NSDictionary *info = [NSDictionary dictionaryWithObject:urlString forKey:@"mp3Url"];
	[[NSNotificationCenter defaultCenter] postNotificationName:kMp3CenterNotification_didLoadMp3 object:nil userInfo:info];
}


@end
