//
//  UBImagesRequest.h
//  UkrBash
//
//  Created by Maks Markovets on 20.01.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "UBRequest.h"

@interface UBImagesRequest : UBRequest

- (void)setLimit:(NSInteger)limit;
- (void)setStart:(NSInteger)start;

@end
