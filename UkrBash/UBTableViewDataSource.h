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

- (UITableViewCell*)cellWithReuesIdentifier:(NSString*)reuseIdent;
- (void)configureCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath;
- (NSArray*)items;
- (void)loadMoreItems;
- (NSDateFormatter*)dateFormatter;

@end
