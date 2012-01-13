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

enum UBMenuItems {
    UBMenuItemUnpublishedQuotes,
    UBMenuItemBestQuotes,
    UBMenuItemRandomQuotes,
    UBMenuItemImages,
    UBMenuItemRateApp,
    UBMenuItemWebsite,
    UBMenuItemsCount
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
    [menuItems release];
    [_tableView release];
    [super dealloc];
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
    _tableView.contentInset = UIEdgeInsetsMake(50., 0., 0., 0.);
    [self.view addSubview:_tableView];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    menuItems = [[NSArray alloc] initWithObjects:@"Неопубліковане", @"Найкраще", @"Випадкове", @"Картинки", @"Оцінити програму", @"www.ukrbash.org", nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    [_tableView release], _tableView = nil;
    [menuItems release], menuItems = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table View Datasource/Delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return UBMenuItemsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.imageView.image = [UIImage imageNamed:@"menu-pin"];
    }
    
    cell.textLabel.text = [menuItems objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == UBMenuItemUnpublishedQuotes ||
        indexPath.row == UBMenuItemRandomQuotes ||
        indexPath.row == UBMenuItemBestQuotes ||
        indexPath.row == UBMenuItemImages) {
        
        UBQuotesContainerController *quotesContainer = [[UBQuotesContainerController alloc] init];
        [self.ubNavigationController pushViewController:quotesContainer animated:YES];
        [quotesContainer release];
    }
    if (indexPath.row == UBMenuItemWebsite) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.ukrbash.org/"]];
    }
}

@end
