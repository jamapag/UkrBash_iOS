//
//  VKLoginViewController.m
//  UkrBash
//
//  Created by Michail Grebionkin on 18.10.12.
//
//

#import "VKLoginViewController.h"
#import "VKError.h"
#import "VKURLParser.h"
#import <QuartzCore/QuartzCore.h>

#define VK_AUTHORIZE_REDIRECT_URL @"http://oauth.vk.com/blank.html"
#define VK_AUTHORIZE_URL_SCHEMA @"https://oauth.vk.com/authorize?client_id=%@&scope=%@&redirect_uri=%@&display=touch&response_type=token"

@interface WebViewController : UIViewController
{
    UIView * _shadowView;
    UIActivityIndicatorView * _activityIndicator;
}

@property (nonatomic, readonly) UIWebView * webView;

- (void)loadPageWithURLString:(NSString*)URLString;
- (void)showActivityIndicator;
- (void)hideActivityIndicator;

@end

#pragma mark -

@interface VKLoginViewController ()

- (void)cancelAction:(id)sender;

@end

#pragma mark -

@implementation VKLoginViewController

@synthesize appId;
@synthesize permissions;
@synthesize vkLoginDelegate;

- (WebViewController *)webViewController
{
    return (WebViewController *)[self topViewController];
}

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
        appId = [_appId copy];
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
    [vkLoginDelegate release], vkLoginDelegate = nil;
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
    
    [self topViewController].navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)] autorelease];

    NSString * URLString = [NSString stringWithFormat:VK_AUTHORIZE_URL_SCHEMA, self.appId, [self permissionsString], VK_AUTHORIZE_REDIRECT_URL];
    
    [[[self webViewController] webView] setDelegate:self];
    [[self webViewController] loadPageWithURLString:URLString];
}

- (NSString*)permissionsString
{
    return [self.permissions componentsJoinedByString:@","];
}

#pragma mark - Actions

- (void)cancelAction:(id)sender
{
    NSDictionary * userInfo = @{NSLocalizedDescriptionKey : @"Authorization canceled by user."};
    NSError * error = [NSError errorWithDomain:kVKErrorDomain code:VKCanceledErrorCode userInfo:userInfo];
    [self.vkLoginDelegate vkLoginViewController:self didFailWithError:error];
}

#pragma mark - Web View delegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[self webViewController] showActivityIndicator];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[self webViewController] hideActivityIndicator];
    if ([webView.request.URL.lastPathComponent isEqualToString:@"blank.html"]) {
        NSDictionary * responseParams = [VKURLParser dictionaryParamsFromURL:webView.request.URL];
        if ([responseParams objectForKey:@"error"]) {
            [self authorizationFailedWithErrorCode:VKAccessDeniedErrorCode errorMessage:[responseParams objectForKey:@"error_description"] responseParams:responseParams];
        }
        else {
            NSString * accessTokenStr = [responseParams objectForKey:@"access_token"];
            NSString * expiresInStr = [responseParams objectForKey:@"expires_in"];
            NSString * userIdStr = [responseParams objectForKey:@"user_id"];
            if (IS_NULL(accessTokenStr) || IS_NULL(expiresInStr) || IS_NULL(userIdStr)) {
                [self authorizationFailedWithErrorCode:VKUnknownErrorCode errorMessage:@"Invalid response params." responseParams:responseParams];
                return;
            }
            NSInteger userId = [userIdStr integerValue];
            NSInteger expiresIn = [expiresInStr integerValue];
            if (userId == 0) {
                [self authorizationFailedWithErrorCode:VKUnknownErrorCode errorMessage:@"Invalid response params." responseParams:responseParams];
                return;
            }
            
            NSDate * expirationDate = [[NSDate date] dateByAddingTimeInterval:expiresIn];
            NSAssert(expirationDate != nil, @"unexpected expiration date");
            
            [self.vkLoginDelegate vkLoginViewController:self didLoginWithAccessToken:accessTokenStr expirationDate:expirationDate userId:userId];
            
//            NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//            NSLog(@"cookies %@", [storage cookies]);
        }
    }
}

- (void)authorizationFailedWithErrorCode:(NSInteger)errorCode errorMessage:(NSString *)errorMessage responseParams:(NSDictionary *)responseParams
{
    NSDictionary * userInfo = @{
    @"vk_response": responseParams,
    NSLocalizedDescriptionKey: errorMessage
    };
    NSError * error = [NSError errorWithDomain:kVKErrorDomain code:errorCode userInfo:userInfo];
    [self.vkLoginDelegate vkLoginViewController:self didFailWithError:error];
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
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    _shadowView = [[UIView alloc] initWithFrame:CGRectMake(0., 0., 100., 100.)];
    _shadowView.backgroundColor = [UIColor colorWithWhite:0. alpha:.6];
    _shadowView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    _shadowView.center = CGPointMake(self.view.frame.size.width / 2., self.view.frame.size.height / 2.);
    _shadowView.layer.cornerRadius = 5.;
    [self.view addSubview:_shadowView];
    [_shadowView release];
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    _activityIndicator.center = CGPointMake(self.view.frame.size.width / 2., self.view.frame.size.height / 2.);
    [_activityIndicator startAnimating];
    [self.view addSubview:_activityIndicator];
    [_activityIndicator release];
    
    [self hideActivityIndicator];
}

- (void)loadPageWithURLString:(NSString*)URLString
{
    NSURL * url = [NSURL URLWithString:URLString];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)showActivityIndicator
{
    [_shadowView setHidden:NO];
    [_activityIndicator startAnimating];
}

- (void)hideActivityIndicator
{
    [_activityIndicator stopAnimating];
    [_shadowView setHidden:YES];
}

@end