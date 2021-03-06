//
//  UBTableViewDataSource.h
//  UkrBash
//
//  Created by Михаил Гребенкин on 03.02.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UBTableViewDataSource : NSObject
{
    NSDateFormatter *dateFormatter;
}

- (UITableViewCell *)cellWithReuesIdentifier:(NSString *)reuseIdent;
- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)items;
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (void)loadMoreItems;
- (void)loadNewItems;
- (NSDateFormatter *)dateFormatter;
- (NSString *)ratingStringFromRating:(NSInteger)rating;
- (BOOL)isNoMore;

@end
