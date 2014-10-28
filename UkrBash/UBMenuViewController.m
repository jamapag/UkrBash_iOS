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
#import "UBUnpablishedQuotesDataSource.h"
#import "UBBestQuotesDataSource.h"
#import "UBRandomQuotesDataSource.h"
#import "UBFavoriteQuotesDataSource.h"
#import "UBMenuItemCell.h"
#import "UBPublishedPicturesDataSource.h"
#import "UBUnpablishedPicturesDataSource.h"
#import "UBRandomPicturesDataSource.h"
#import "UBBestPicturesDataSource.h"
#import "UBFavoritePicturesDataSource.h"
#import "UBDonateViewController.h"
#import "UBPicturesCollectionViewController.h"
#import "UBQuotesController.h"
#import "UBPicturesController.h"

enum UBMenuSections {
    UBMenuQuotesSection,
    UBMenuImagesSection,
    UBMenuInfoSection,
    UBMenuSectionsCount,
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
    UBSubMenuItemFavorite,
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
        } else if (UBSubMenuItemFavorite == indexPath.row) {
            cell.textLabel.text = @"Улюблене";
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
            Class dataSourceClass = nil;
            if (UBSubMenuItemPublished == indexPath.row) {
                dataSourceClass = [UBPublishedQuotesDataSource class];
            } else if (UBSubMenuItemUnpublished == indexPath.row) {
                dataSourceClass = [UBUnpablishedQuotesDataSource class];
            } else if (UBSubMenuItemBest == indexPath.row) {
                dataSourceClass = [UBBestQuotesDataSource class];
            } else if (UBSubMenuItemRandom == indexPath.row) {
                dataSourceClass = [UBRandomQuotesDataSource class];
            } else if (UBSubMenuItemFavorite == indexPath.row) {
                dataSourceClass = [UBFavoriteQuotesDataSource class];
            }
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setValue:title forKey:UBContainerTitleKey];
            [userDefaults setValue:NSStringFromClass(dataSourceClass) forKey:UBContainerDataSourceKey];
            [userDefaults setValue:UBContainerTypeQuotes forKey:UBContainerTypeKey];
            [userDefaults synchronize];
            [self.delegate quotesWithDataSourceSelected:dataSourceClass withTitle:title];
        }
    }
    if (UBMenuImagesSection == indexPath.section) {
        if (UBSubMenuItemTitle == indexPath.row) {
            isImagesSectionFolded = !isImagesSectionFolded;
            [self tableView:tableView setFolding:isImagesSectionFolded forSection:indexPath.section];
        } else {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            NSString *title = cell.textLabel.text;
            Class dataSourceClass = nil;
            if (UBSubMenuItemPublished == indexPath.row) {
                dataSourceClass = [UBPublishedPicturesDataSource class];
            } else if (UBSubMenuItemUnpublished == indexPath.row) {
                dataSourceClass = [UBUnpablishedPicturesDataSource class];
            } else if (UBSubMenuItemRandom == indexPath.row) {
                dataSourceClass = [UBRandomPicturesDataSource class];
            } else if (UBSubMenuItemBest == indexPath.row) {
                dataSourceClass = [UBBestPicturesDataSource class];
            } else if (UBSubMenuItemFavorite == indexPath.row) {
                dataSourceClass = [UBFavoritePicturesDataSource class];
            }
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setValue:title forKey:UBContainerTitleKey];
            [userDefaults setValue:NSStringFromClass(dataSourceClass) forKey:UBContainerDataSourceKey];
            [userDefaults setValue:UBContainerTypePictures forKey:UBContainerTypeKey];
            [userDefaults synchronize];
            [self.delegate picturesWithDataSourceSelected:dataSourceClass withTitle:title];
        }
    }

    if (UBMenuInfoSection == indexPath.section) {
        if (indexPath.row == UBMenuItemDonate) {
            [self.delegate donateControllerSelected];
        } else if (indexPath.row == UBMenuItemRateApp) {
            if ([SKStoreProductViewController class]) {
                SKStoreProductViewController *controller = [[SKStoreProductViewController alloc] init];
                controller.delegate = self;
                [controller loadProductWithParameters:@{ SKStoreProductParameterITunesItemIdentifier:@"517226573" }
                                      completionBlock:NULL];
                [self presentViewController:controller animated:YES completion:nil];
                [controller release];
                return;
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/app/517226573?mt=8"]];
            }
        } else if (indexPath.row == UBMenuItemWebsite) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.ukrbash.org/"]];
        } else if (indexPath.row == UBMenuItemContact) {
            if ([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
                mailComposer.mailComposeDelegate = self;
                [mailComposer setToRecipients:[NSArray arrayWithObject:@"info@smile2mobile.net"]];
                [mailComposer setSubject:@"UkrBash iOS feedback"];
                [self presentViewController:mailComposer animated:YES completion:nil];
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
    [self dismissViewControllerAnimated:YES completion:nil];
    if (!error && result == MFMailComposeResultSent) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Дякуєм!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
}

#pragma mark - SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
