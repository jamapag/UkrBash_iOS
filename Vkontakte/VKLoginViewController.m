//
//  VKLoginViewController.m
//  UkrBash
//
//  Created by Michail Grebionkin on 18.10.12.
//
//

#import "VKLoginViewController.h"

#define VK_AUTHORIZE_REDIRECT_URL @"http://oauth.vk.com/blank.html"
#define VK_AUTHORIZE_URL_SCHEMA @"https://oauth.vk.com/authorize?client_id=%@&scope=%@&redirect_uri=%@&display=touch&response_type=token"

@interface WebViewController : UIViewController

@property (nonatomic, readonly) UIWebView * webView;

- (void)loadPageWithURLString:(NSString*)URLString;

@end

@interface VKLoginViewController ()

@end

@implementation VKLoginViewController

@synthesize appId;
@synthesize permissions;

- (id)initWithAppId:(NSString *)_appId
{
    WebViewController * webViewController = [[WebViewController alloc] init];
    self = [super initWithRootViewController:webViewController];
    [webViewController release];
    if (self) {
        appId = [_appId copy];
        permissions = [NSArray arrayWithObjects:@"offline", nil];
    }
    return self;
}

- (id)initWithAppId:(NSString *)_appId andPermissions:(NSArray *)_permissions
{
    WebViewController * webViewController = [[WebViewController alloc] init];
    self = [super initWithRootViewController:webViewController];
    [webViewController release];
    if (self) {
        permissions = [_permissions retain];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [appId release];
    [permissions release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSAssert(self.appId != nil, @"Can't load VK login page without app ID.");
    NSAssert(self.permissions != nil, @"Can't load VK login page without app permissions.");
    NSAssert([[self topViewController] isKindOfClass:[WebViewController class]], @"Can't find web view.");
    
    NSString * URLString = [NSString stringWithFormat:VK_AUTHORIZE_URL_SCHEMA, self.appId, [self permissionsString], VK_AUTHORIZE_REDIRECT_URL];
    
    WebViewController * webViewController = (WebViewController*)[self topViewController];
    [webViewController loadPageWithURLString:URLString];
}

- (NSString*)permissionsString
{
    return [self.permissions componentsJoinedByString:@","];
}

@end

#pragma mark -

@implementation WebViewController

- (UIWebView *)webView
{
    return (UIWebView*)self.view;
}

- (void)loadView
{
    self.view = [[[UIWebView alloc] init] autorelease];
}

- (void)loadPageWithURLString:(NSString*)URLString
{
    NSURL * url = [NSURL URLWithString:URLString];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

@end