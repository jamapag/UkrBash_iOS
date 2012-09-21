//
//  UBMenuViewController.m
//  UkrBash
//
//  Created by Михаил Гребенкин on 12.01.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "UBMenuViewController.h"
#import "UBNavigationController.h"
#import "UBViewController.h"
#import "UBQuotesContainerController.h"
#import "UBPicturesContainerController.h"
#import "UBPublishedQuotesDataSource.h"
#import "UBUnpablishedQuotesDataSource.h"
#import "UBBestQuotesDataSource.h"
#import "UBRandomQuotesDataSource.h"
#import "UBMenuItemCell.h"
#import "UBPublishedPicturesDataSource.h"
#import "UBUnpablishedPicturesDataSource.h"
#import "UBRandomPicturesDataSource.h"
#import "UBBestPicturesDataSource.h"

enum UBMenuSections {
    UBMenuQuotesSection,
    UBMenuImagesSection,
    UBMenuInfoSection,
    UBMenuSectionsCount
};

enum UBMenuItems {
    UBMenuItemRateApp,
    UBMenuItemWebsite,
    UBMenuItemsCount
};

enum UBSubMenuItems {
    UBSubMenuItemTitle,
    UBSubMenuItemPublished,
    UBSubMenuItemUnpublished,
    UBSubMenuItemBest,
    UBSubMenuItemRandom,
    UBSubMenuItemsCount
};

@implementation UBMenuViewController

@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [_tableView release];
    [super dealloc];
}

#pragma mark - actions

- (void)scrollToTopAction:(id)sender
{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0. inSection:0.] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];

    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0., -20., self.view.frame.size.width, self.view.frame.size.height)];
    backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    backgroundImageView.image = [UIImage imageNamed:@"view-background"];
    backgroundImageView.contentMode = UIViewContentModeTopLeft;
    [self.view addSubview:backgroundImageView];
    [backgroundImageView release];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0., 44., self.view.frame.size.width, self.view.frame.size.height - 44.) style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.rowHeight = 52.;
    [self.view addSubview:_tableView];

    UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0., 0., self.view.frame.size.width, 44.)];
    headerView.userInteractionEnabled = YES;
    headerView.image = [UIImage imageNamed:@"header"];
    headerView.contentMode = UIViewContentModeTopLeft;
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    headerView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:CGRectMake(0., 0., headerView.image.size.width, headerView.image.size.height)] CGPath];
    headerView.layer.shadowColor = [[UIColor blackColor] CGColor];
    headerView.layer.shadowRadius = 2.;
    headerView.layer.shadowOffset = CGSizeMake(0, 2.);
    headerView.layer.shadowOpacity = .3;
    
    logoButton = [[UIButton alloc] initWithFrame:CGRectMake(0., 4., 135., 30.)];
    logoButton.contentMode = UIViewContentModeScaleToFill;
    logoButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    logoButton.center = CGPointMake(self.view.frame.size.width / 2., logoButton.center.y);
    [logoButton addTarget:self action:@selector(scrollToTopAction:) forControlEvents:UIControlEventTouchUpInside];
    [logoButton setImage:[UIImage imageNamed:@"logo"] forState:UIControlStateNormal];
    [headerView addSubview:logoButton];
    
    [self.view addSubview:headerView];
    [headerView release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    [_tableView release], _tableView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Navigation methods

- (void)pushQuotesContainerWithDataSourceClass:(Class)dataSourceClass title:(NSString*)title
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:title forKey:UBContainerTitleKey];
    [userDefaults setValue:NSStringFromClass(dataSourceClass) forKey:UBContainerDataSourceKey];
    [userDefaults setValue:UBContainerTypeQuotes forKey:UBContainerTypeKey];
    [userDefaults synchronize];
    
    UBQuotesContainerController *quotesContainer = [[UBQuotesContainerController alloc] initWithDataSourceClass:dataSourceClass];
    quotesContainer.title = title;
    [self.ubNavigationController pushViewController:quotesContainer animated:YES];
    [quotesContainer release];
}

- (void)pushPicturesContainerWithDataSourceClass:(Class)dataSourceClass title:(NSString*)title
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:title forKey:UBContainerTitleKey];
    [userDefaults setValue:NSStringFromClass(dataSourceClass) forKey:UBContainerDataSourceKey];
    [userDefaults setValue:UBContainerTypePictures forKey:UBContainerTypeKey];
    [userDefaults synchronize];

    UBPicturesContainerController *picturesContainer = [[UBPicturesContainerController alloc] initWithDataSourceClass:dataSourceClass];
    picturesContainer.title = title;
    [self.ubNavigationController pushViewController:picturesContainer animated:YES];
    [picturesContainer release];
}

#pragma mark - Table View Datasource/Delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return UBMenuSectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (UBMenuQuotesSection == section) {
        if (isQuotesSectionFolded) {
            return 1;
        } else {
            return UBSubMenuItemsCount;
        }
    } else if (UBMenuImagesSection == section) {
        if (isImagesSectionFolded) {
            return 1;
        } else {
            return UBSubMenuItemsCount;
        }
    }
    return UBMenuItemsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[[UBMenuItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.shadowColor = [UIColor whiteColor];
        cell.textLabel.shadowOffset = CGSizeMake(0., 1.);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.imageView.image = [UIImage imageNamed:@"menu-pin"];
    }
    
    if (indexPath.section == UBMenuImagesSection && indexPath.row == UBSubMenuItemTitle) {
        cell.textLabel.text = @"Картинки";

        if (isImagesSectionFolded) {
            cell.imageView.image = [UIImage imageNamed:@"menu-pin"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"menu-pin-45"];
        }
    } else if (indexPath.section == UBMenuQuotesSection && indexPath.row == UBSubMenuItemTitle) {
        cell.textLabel.text = @"Цитати";

        if (isQuotesSectionFolded) {
            cell.imageView.image = [UIImage imageNamed:@"menu-pin"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"menu-pin-45"];
        }
    } else {
        cell.imageView.image = [UIImage imageNamed:@"menu-pin"];
    }
    if (indexPath.section == UBMenuImagesSection || indexPath.section == UBMenuQuotesSection) {
        if (UBSubMenuItemTitle != indexPath.row) {
            cell.indentationLevel = 2;
        } else {
            cell.indentationLevel = 0;
        }
        if (UBSubMenuItemPublished == indexPath.row) {
            cell.textLabel.text = @"Опубліковане";
        } else if (UBSubMenuItemUnpublished == indexPath.row) {
            cell.textLabel.text = @"Неопубліковане";
        } else if (UBSubMenuItemBest == indexPath.row) {
            cell.textLabel.text = @"Найкраще";
        } else if (UBSubMenuItemRandom == indexPath.row) {
            cell.textLabel.text = @"Випадкове";
        }
    } else if (indexPath.section == UBMenuInfoSection) {
        cell.indentationLevel = 0;
        if (indexPath.row == UBMenuItemRateApp) {
            cell.textLabel.text = @"Оцінити програму";
        } else if (indexPath.row == UBMenuItemWebsite) {
            cell.textLabel.text = @"www.ukrbash.org";
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView setFolding:(BOOL)isFolded forSection:(NSInteger)section
{
    NSMutableArray *rows = [NSMutableArray array];
    for (NSInteger i = 1; i < UBSubMenuItemsCount; i++) {
        [rows addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
    if (isFolded) {
        [tableView deleteRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationTop];
    } else {
        [tableView insertRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationTop];
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    [UIView animateWithDuration:.3 animations:^{
        cell.imageView.transform = CGAffineTransformRotate(cell.imageView.transform, -M_PI_4);
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UBMenuQuotesSection == indexPath.section) {
        if (UBSubMenuItemTitle == indexPath.row) {
            isQuotesSectionFolded = !isQuotesSectionFolded;
            [self tableView:tableView setFolding:isQuotesSectionFolded forSection:indexPath.section];
        } else {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            NSString *title = cell.textLabel.text;
            if (UBSubMenuItemPublished == indexPath.row) {
                [self pushQuotesContainerWithDataSourceClass:[UBPublishedQuotesDataSource class] title:title];
            } else if (UBSubMenuItemUnpublished == indexPath.row) {
                [self pushQuotesContainerWithDataSourceClass:[UBUnpablishedQuotesDataSource class] title:title];
            } else if (UBSubMenuItemBest == indexPath.row) {
                [self pushQuotesContainerWithDataSourceClass:[UBBestQuotesDataSource class] title:title];
            } else if (UBSubMenuItemRandom == indexPath.row) {
                [self pushQuotesContainerWithDataSourceClass:[UBRandomQuotesDataSource class] title:title];
            }
        }
    }
    if (UBMenuImagesSection == indexPath.section) {
        if (UBSubMenuItemTitle == indexPath.row) {
            isImagesSectionFolded = !isImagesSectionFolded;
            [self tableView:tableView setFolding:isImagesSectionFolded forSection:indexPath.section];
        } else {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            NSString *title = cell.textLabel.text;
            if (UBSubMenuItemPublished == indexPath.row) {
                [self pushPicturesContainerWithDataSourceClass:[UBPublishedPicturesDataSource class] title:title];
            } else if (UBSubMenuItemUnpublished == indexPath.row) {
                [self pushPicturesContainerWithDataSourceClass:[UBUnpablishedPicturesDataSource class] title:title];
            } else if (UBSubMenuItemRandom == indexPath.row) {
                [self pushPicturesContainerWithDataSourceClass:[UBRandomPicturesDataSource class] title:title];
            } else if (UBSubMenuItemBest == indexPath.row) {
                [self pushPicturesContainerWithDataSourceClass:[UBBestPicturesDataSource class] title:title];
            }
        }
    }

    if (UBMenuInfoSection == indexPath.section) {
        if (indexPath.row == UBMenuItemRateApp) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=517226573"]];
        }
        if (indexPath.row == UBMenuItemWebsite) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.ukrbash.org/"]];
        }
    }
}

@end
