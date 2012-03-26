//
//  UBPicturesContainerController.h
//  UkrBash
//
//  Created by Михаил Гребенкин on 12.03.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "UBViewController.h"
#import "UBPicturesDataSource.h"

@interface UBPicturesContainerController : UBViewController <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *tableView;
    UIButton *logoButton;
    UILabel *categoryLabel;
    
    UBPicturesDataSource *dataSource;
    NSMutableDictionary *pendingImages;
    
    BOOL loading;
}

@property (nonatomic, retain) UBPicturesDataSource *dataSource;

- (id)initWithDataSourceClass:(Class)dataSourceClass;
- (void)showFooter;
- (void)hideFooter;

@end
