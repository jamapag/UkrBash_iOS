//
//  UBMenuViewController.h
//  UkrBash
//
//  Created by Михаил Гребенкин on 12.01.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "UBViewController.h"

#define UBContainerTypeKey @"UBContainerTypeKey"
#define UBContainerTypeQuotes @"quotes"
#define UBContainerTypePictures @"pictures"

#define UBContainerDataSourceKey @"UBContainerDataSourceKey"
#define UBContainerTitleKey @"UBContainerTitleKey"

@interface UBMenuViewController : UBViewController <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>
{
    UITableView *_tableView;
    UIButton *logoButton;
    BOOL isQuotesSectionFolded, isImagesSectionFolded;
}

@property (nonatomic, readonly) UITableView *tableView;

@end
