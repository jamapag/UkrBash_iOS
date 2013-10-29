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
#import "UBDonateViewController.h"
#import "UBPicturesCollectionViewController.h"

enum UBMenuSections {
    UBMenuQuotesSection,
    UBMenuImagesSection,
    UBMenuInfoSection,
    UBMenuSectionsCount
};

enum UBMenuItems {
    UBMenuItemDonate,
    UBMenuItemRateApp,
    UBMenuItemWebsite,
    UBMenuItemContact,
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

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"texture.png"]];
    
    float y = 0;
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // Load resources for iOS 6.1 or earlier;
        NSLog(@"IOS6");
        y = 0;
    } else {
        // Load resources for iOS 7 or later
        y = 20;
        NSLog(@"IOS7");
    }
    
    
    UIView *headerView = [[self headerViewWithMenuButtonAction:nil] retain];
    
    logoButton = [[UIButton alloc] initWithFrame:CGRectMake(0., 24, 135., 30.)];
    logoButton.contentMode = UIViewContentModeScaleToFill;
    logoButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    logoButton.center = CGPointMake(self.view.frame.size.width / 2., logoButton.center.y);
    [logoButton addTarget:self action:@selector(scrollToTopAction:) forControlEvents:UIControlEventTouchUpInside];
    [logoButton setImage:[UIImage imageNamed:@"logo"] forState:UIControlStateNormal];
    [headerView addSubview:logoButton];
    
    [self.view addSubview:headerView];

    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0., headerView.frame.size.height + headerView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - headerView.frame.size.height - headerView.frame.origin.y) style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.rowHeight = 52.;
    [self.view addSubview:_tableView];
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

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone || ![UICollectionView class]) {
        UBPicturesContainerController *picturesContainer = [[UBPicturesContainerController alloc] initWithDataSourceClass:dataSourceClass];
        picturesContainer.title = title;
        [self.ubNavigationController pushViewController:picturesContainer animated:YES];
        [picturesContainer release];
    } else {
        UBPicturesCollectionViewController *collecitonController = [[UBPicturesCollectionViewController alloc] initWithDataSourceClass:dataSourceClass];
        collecitonController.title = title;
        [self.ubNavigationController pushViewController:collecitonController animated:YES];
        [collecitonController release];
    }
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
        cell = [[[UBMenuItemCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"] autorelease];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.shadowColor = [UIColor whiteColor];
        cell.textLabel.shadowOffset = CGSizeMake(0., 1.);
        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
        cell.detailTextLabel.shadowColor = [UIColor whiteColor];
        cell.detailTextLabel.shadowOffset = CGSizeMake(0., 1.);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.imageView.image = [UIImage imageNamed:@"menu-pin.png"];
    }
    
    cell.detailTextLabel.text = @"";

    if (indexPath.section == UBMenuImagesSection && indexPath.row == UBSubMenuItemTitle) {
        cell.textLabel.text = @"Картинки";

        if (isImagesSectionFolded) {
            cell.imageView.image = [UIImage imageNamed:@"menu-pin.png"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"menu-pin-45.png"];
        }
    } else if (indexPath.section == UBMenuQuotesSection && indexPath.row == UBSubMenuItemTitle) {
        cell.textLabel.text = @"Цитати";

        if (isQuotesSectionFolded) {
            cell.imageView.image = [UIImage imageNamed:@"menu-pin.png"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"menu-pin-45.png"];
        }
    } else {
        cell.imageView.image = [UIImage imageNamed:@"menu-pin.png"];
    }
    if (indexPath.section == UBMenuImagesSection || indexPath.section == UBMenuQuotesSection) {
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
        if (indexPath.row == UBMenuItemDonate) {
            cell.textLabel.text = @"Підтримати розробку";
        } else if (indexPath.row == UBMenuItemRateApp) {
            cell.textLabel.text = @"Оцінити програму";
        } else if (indexPath.row == UBMenuItemWebsite) {
            cell.textLabel.text = @"www.ukrbash.org";
            cell.detailTextLabel.text = @"Відкрити у Safari";
        } else if (indexPath.row == UBMenuItemContact) {
            cell.textLabel.text = @"Зв`язатися з розробником";
            cell.detailTextLabel.text = @"Маєте пропозицію чи зауваження?";
        }
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == UBMenuImagesSection || indexPath.section == UBMenuQuotesSection) {
        if (UBSubMenuItemTitle != indexPath.row) {
            return 2;
        }
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView setFolding:(BOOL)isFolded forSection:(NSInteger)section
{
    [tableView beginUpdates];
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
        cell.imageView.image = isFolded ? [UIImage imageNamed:@"menu-pin.png"] : [UIImage imageNamed:@"menu-pin-45.png"];
    }];
    [tableView endUpdates];
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
        if (indexPath.row == UBMenuItemDonate) {
            UBDonateViewController *donateViewController = [[UBDonateViewController alloc] init];
            [self.ubNavigationController pushViewController:donateViewController animated:YES];
            [donateViewController release];
        } else if (indexPath.row == UBMenuItemRateApp) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=517226573"]];
        } else if (indexPath.row == UBMenuItemWebsite) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.ukrbash.org/"]];
        } else if (indexPath.row == UBMenuItemContact) {
            if ([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController * mailComposer = [[MFMailComposeViewController alloc] init];
                mailComposer.mailComposeDelegate = self;
                [mailComposer setToRecipients:[NSArray arrayWithObject:@"info@smile2mobile.net"]];
                [mailComposer setSubject:@"UkrBash iOS feedback"];
                if ([self.ubNavigationController respondsToSelector:@selector(presentViewController:animated:completion:)]) {
                    [self.ubNavigationController presentViewController:mailComposer animated:YES completion:nil];
                } else {
                    [self.ubNavigationController presentModalViewController:mailComposer animated:YES];
                }
            } else {
                NSURL *url = [NSURL URLWithString:@"mailto:info@smile2mobile.net?subject=UkrBash%20iOS%20feedback"];
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if ([self.ubNavigationController respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        [self.ubNavigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.ubNavigationController dismissModalViewControllerAnimated:YES];
    }
    if (!error && result == MFMailComposeResultSent) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Дякуєм!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
}

@end
