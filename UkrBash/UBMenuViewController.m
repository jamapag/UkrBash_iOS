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
#import "UBPublishedQuotesDataSource.h"
#import "UBBestQuotesDataSource.h"
#import "UBRandomQuotesDataSource.h"
#import "UBMenuItemCell.h"

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

    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0., 0., self.view.frame.size.width, self.view.frame.size.height)];
    backgroundImageView.image = [UIImage imageNamed:@"view-background"];
    backgroundImageView.contentMode = UIViewContentModeBottom;
    [self.view addSubview:backgroundImageView];
    [backgroundImageView release];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0., 0., self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.rowHeight = 52.;
    _tableView.contentInset = UIEdgeInsetsMake(55., 0., 0., 0.);
    [self.view addSubview:_tableView];

    logoButton = [[UIButton alloc] initWithFrame:CGRectMake(0., 5., 165., 38.)];
    logoButton.center = CGPointMake(self.view.frame.size.width / 2., logoButton.center.y);
    [logoButton addTarget:self action:@selector(scrollToTopAction:) forControlEvents:UIControlEventTouchUpInside];
    [logoButton setImage:[UIImage imageNamed:@"logo"] forState:UIControlStateNormal];
    [self.view addSubview:logoButton];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.imageView.image = [UIImage imageNamed:@"menu-pin"];
    }
    
    if (indexPath.section == UBMenuImagesSection && indexPath.row == UBSubMenuItemTitle) {
        cell.textLabel.text = @"Картинки";
    } else if (indexPath.section == UBMenuQuotesSection && indexPath.row == UBSubMenuItemTitle) {
        cell.textLabel.text = @"Цитати";

        if (isQuotesSectionFolded) {
            cell.imageView.image = [UIImage imageNamed:@"menu-pin"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"menu-pin-45"];
        }
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
        } else if (UBSubMenuItemPublished == indexPath.row) {
            UBQuotesContainerController *quotesContainer = [[UBQuotesContainerController alloc] initWithDataSourceClass:[UBPublishedQuotesDataSource class]];
            [self.ubNavigationController pushViewController:quotesContainer animated:YES];
            [quotesContainer release];
        } else if (UBSubMenuItemUnpublished == indexPath.row) {
            UBQuotesContainerController *quotesContainer = [[UBQuotesContainerController alloc] initWithDataSourceClass:[UBUnpablishedQuotesDataSource class]];
            [self.ubNavigationController pushViewController:quotesContainer animated:YES];
            [quotesContainer release];
        } else if (UBSubMenuItemBest == indexPath.row) {
            UBQuotesContainerController *quotesContainer = [[UBQuotesContainerController alloc] initWithDataSourceClass:[UBBestQuotesDataSource class]];
            [self.ubNavigationController pushViewController:quotesContainer animated:YES];
            [quotesContainer release];
        } else if (UBSubMenuItemRandom == indexPath.row) {
            UBQuotesContainerController *quotesContainer = [[UBQuotesContainerController alloc] initWithDataSourceClass:[UBRandomQuotesDataSource class]];
            [self.ubNavigationController pushViewController:quotesContainer animated:YES];
            [quotesContainer release];
        }
    }
    if (UBMenuImagesSection == indexPath.section) {
        if (UBSubMenuItemTitle == indexPath.row) {
            isImagesSectionFolded = !isImagesSectionFolded;
            [self tableView:tableView setFolding:isImagesSectionFolded forSection:indexPath.section];
        }
    }
    /*
    if (UBMenuItemImages == indexPath.row) {
        NSLog(@"Not implemented yet");
        return;
//        UBQuotesContainerController *quotesContainer = [[UBQuotesContainerController alloc] init];
//        [self.ubNavigationController pushViewController:quotesContainer animated:YES];
//        [quotesContainer release];
    } else 
     */
    if (UBMenuInfoSection == indexPath.section) {
        if (indexPath.row == UBMenuItemWebsite) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.ukrbash.org/"]];
        }
    }
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    CGFloat alpha = 1;
    if (aScrollView.contentOffset.y < 0) {
        if (abs(aScrollView.contentOffset.y) >= self.tableView.contentInset.top) {
            alpha = 1.;
        } else {
            alpha = 1. - (self.tableView.contentInset.top + aScrollView.contentOffset.y) / 100;
        }
    } else {
        alpha = .5;
    }
    logoButton.alpha = MAX(alpha, .5);
}

@end
