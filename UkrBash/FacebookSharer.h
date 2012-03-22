//
//  FacebookSharer.h
//  UkrBash
//
//  Created by Maks Markovets on 22.03.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "BaseSharer.h"
#import "FBConnect.h"

@interface FacebookSharer : BaseSharer <FBSessionDelegate, FBDialogDelegate>
{
    Facebook *facebook;
    BOOL callShare; 
}

@property (nonatomic, retain) Facebook *facebook;

- (id)initWithAppId:(NSString *)appId andDelegate:(id<SharerDelegate>)sharerDelegate;

@end
