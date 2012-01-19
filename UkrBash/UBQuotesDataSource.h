//
//  UBQuotesDataSource.h
//  UkrBash
//
//  Created by Maks Markovets on 19.01.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UBQuotesDataSource <NSObject>

- (NSArray *)getQuotes;
- (void)loadMoreQuotes;

@end
