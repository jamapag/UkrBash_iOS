//
//  UBTableViewDataSource.m
//  UkrBash
//
//  Created by Михаил Гребенкин on 03.02.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "UBTableViewDataSource.h"

@implementation UBTableViewDataSource

- (void)dealloc
{
    [dateFormatter release];
    [super dealloc];
}

- (NSDateFormatter *)dateFormatter
{
    if (!dateFormatter)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"uk_UA"] autorelease];
        [dateFormatter setLocale:locale];
        [dateFormatter setDoesRelativeDateFormatting:YES];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    }
    return dateFormatter;
}

- (NSString *)ratingStringFromRating:(NSInteger)rating
{
    if (rating > 0) {
        return [NSString stringWithFormat:@"+%ld", (long)rating];
    } else if (rating < 0) {
        return [NSString stringWithFormat:@"%ld", (long)rating];
    } else {
        return @"0";
    }
}

- (UITableViewCell *)cellWithReuesIdentifier:(NSString *)reuseIdent
{
    return [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdent] autorelease];
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"this method should be overloaded by subclasses");
}

- (NSArray *)items
{
    NSAssert(NO, @"this method should be overloaded by subclasses");
    return nil;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"this method should be overloaded by subclasses");
    return nil;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    NSAssert(NO, @"this method should be overloaded by subclasses");
    return 0;
}

- (void)loadMoreItems
{
    NSAssert(NO, @"this method should be overloaded by subclasses");
}

- (void)loadNewItems
{
    NSAssert(NO, @"this method should be overloaded by subclasses");
}

- (BOOL)isNoMore
{
    return false;
}

@end
