//
//  DownloadOperations.h
//
//  Created by Michail Grebionkin on 19.03.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaCenter.h"


@interface DownloadImageOperation : NSOperation {
	NSString *urlString;
	NSMutableData *fileData;
	BOOL done;
}

@property (nonatomic, readonly) NSString *urlString;
@property (nonatomic, readonly) NSString *actionType;
@property (nonatomic, copy) UBImageDownloadedCallback completion;

- (id)initWithURLString:(NSString*)urlString;

@end



@interface DownloadMp3Operation : NSOperation {
	NSString *urlString;
	NSMutableData *fileData;
	BOOL done;
}

@property (nonatomic, readonly) NSString *urlString;

- (id)initWithURLString:(NSString*)urlString;

@end
