//
//  UBMenuViewController.h
//  UkrBash
//
//  Created by Михаил Гребенкин on 12.01.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UBViewController.h"

@interface UBMenuViewController : UBViewController <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_tableView;
    UIButton *logoButton;
    BOOL isQuotesSectionFolded, isImagesSectionFolded;
}

@property (nonatomic, readonly) UITableView *tableView;

@end
