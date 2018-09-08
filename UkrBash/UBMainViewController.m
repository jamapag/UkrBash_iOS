//
//  UBMainViewController.m
//  UkrBash
//
//  Created by Maks Markovets on 27.10.14.
//
//

#import "UBMainViewController.h"
#import "UBQuotesContainerController.h"
#import "UBPublishedQuotesDataSource.h"
#import "UBMenuViewController.h"
#import "UBPicturesCollectionViewController.h"
#import "UBDonateViewController.h"
#import "UBFavoritePicturesDataSource.h"
#import "UBFavoriteQuotesDataSource.h"
#import "UBPicturesController.h"
#import "UBQuotesController.h"

#define CENTER_TAG 1
#define LEFT_PANEL_TAG 2

#define CORNER_RADIUS 4

#define SLIDE_TIMING .25
#define PANEL_WIDTH 50 

#define LEFT_PANEL_WIDTH IS_PAD ? 300 : 270

@interface UBMainViewController ()

@end

@implementation UBMainViewController

- (id)initWithContainerController:(UBCenterViewController *)containerController
{
    if (self = [super init]) {
        self.centerViewController = containerController;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupView];
}

#pragma mark - Setup View

- (void)setupView
{
    self.centerViewController.view.tag = CENTER_TAG;
    self.centerViewController.delegate = self;
    [self.view addSubview:self.centerViewController.view];
    [self addChildViewController:_centerViewController];
    [_centerViewController didMoveToParentViewController:self];
    
    [self setupGestures];
}

- (void)showCenterViewWithShadow:(BOOL)value withOffset:(double)offset
{
    if (value) {
        [_centerViewController.view.layer setCornerRadius:CORNER_RADIUS];
        [_centerViewController.view.layer setShadowColor:[UIColor blackColor].CGColor];
        [_centerViewController.view.layer setShadowOpacity:0.8];
        [_centerViewController.view.layer setShadowOffset:CGSizeMake(offset, offset)];
        
    } else {
        [_centerViewController.view.layer setCornerRadius:0.0f];
        [_centerViewController.view.layer setShadowOffset:CGSizeMake(offset, offset)];
    }
}

- (void)resetMainView
{
    // remove left and right views, and reset variables, if needed
    if (_leftPanelViewController != nil) {
        [self.leftPanelViewController.view removeFromSuperview];
        self.leftPanelViewController = nil;
        _centerViewController.menuButton.tag = 1;
        self.showingLeftPanel = NO;
    }
    // remove view shadows
    [self showCenterViewWithShadow:NO withOffset:0];
}

- (UIView *)getLeftView
{
    // init view if it doesn't already exist
    if (_leftPanelViewController == nil)
    {
        // this is where you define the view for the left panel
        self.leftPanelViewController = [[[UBMenuViewController alloc] init] autorelease];
        self.leftPanelViewController.view.tag = LEFT_PANEL_TAG;
        self.leftPanelViewController.delegate = self;
        
        [self.view addSubview:self.leftPanelViewController.view];
        
        [self addChildViewController:_leftPanelViewController];
        [_leftPanelViewController didMoveToParentViewController:self];
        
        _leftPanelViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _leftPanelViewController.view.frame = CGRectMake(0, 0, (LEFT_PANEL_WIDTH) + 20, self.view.frame.size.height);
    }
    
    self.showingLeftPanel = YES;
    
    // setup view shadows
    [self showCenterViewWithShadow:YES withOffset:-2];
    
    UIView *view = self.leftPanelViewController.view;
    return view;
}

#pragma mark - Swipe Gesture Setup/Actions

-(void)setupGestures
{
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePanel:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelegate:self];
    
    [_centerViewController.view addGestureRecognizer:panRecognizer];
}

-(void)movePanel:(id)sender
{
    [[[(UITapGestureRecognizer*)sender view] layer] removeAllAnimations];
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
    CGPoint velocity = [(UIPanGestureRecognizer*)sender velocityInView:[sender view]];
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        UIView *childView = [self getLeftView];
        // make sure the view we're working with is front and center
        [self.view sendSubviewToBack:childView];
        [[sender view] bringSubviewToFront:[(UIPanGestureRecognizer*)sender view]];
    }
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        
        if(velocity.x > 0) {
//             NSLog(@"gesture went right");
        } else {
//             NSLog(@"gesture went left");
        }
        
        if (!_showPanel) {
            [self movePanelToOriginalPosition];
        } else {
            if (_showingLeftPanel) {
                [self movePanelRight];
            }
        }
    }
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateChanged) {
        if(velocity.x > 0) {
            // NSLog(@"gesture went right");
        } else {
            // NSLog(@"gesture went left");
        }
        
        // are we more than halfway, if so, show the panel when done dragging by setting this value to YES (1)
        _showPanel = fabs([sender view].center.x - _centerViewController.view.frame.size.width / 2) > (LEFT_PANEL_WIDTH) / 2;
        
        // allow dragging only in x coordinates by only updating the x coordinate with translation position
        CGPoint center = CGPointMake([sender view].center.x + translatedPoint.x, [sender view].center.y);
        [(UIPanGestureRecognizer*)sender setTranslation:CGPointMake(0,0) inView:self.view];
        if (center.x < [sender view].frame.size.width / 2 || (center.x - [sender view].frame.size.width / 2) > (LEFT_PANEL_WIDTH)) {
            _preVelocity = velocity;
            return;
        }
        
        [sender view].center = center;
        
        // if you needed to check for a change in direction, you could use this code to do so
        if(velocity.x*_preVelocity.x + velocity.y*_preVelocity.y > 0) {
            // NSLog(@"same direction");
        } else {
            // NSLog(@"opposite direction");
        }
        
        _preVelocity = velocity;
    }
}

#pragma mark - Delegate Actions

- (void)movePanelRight
{
    UIView *childView = [self getLeftView];
    [self.view sendSubviewToBack:childView];
    
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        _centerViewController.view.frame = CGRectMake((LEFT_PANEL_WIDTH), 0, self.view.frame.size.width, self.view.frame.size.height);
    }
                     completion:^(BOOL finished) {
                         if (finished) {
                             _centerViewController.menuButton.tag = 0;
                         }
                     }];
}

- (void)movePanelToOriginalPosition
{
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        _centerViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self resetMainView];
                         }
                     }];
}

#pragma mark - UBLeftPanelViewControllerDelegateMethods.

- (void)updateCenterViewController:(UBCenterViewController *)newCenterController
{
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        _centerViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self resetMainView];
                             
                             [self.centerViewController.view removeFromSuperview];
                             self.centerViewController = nil;
                             self.centerViewController = newCenterController;
                             self.centerViewController.view.tag = CENTER_TAG;
                             self.centerViewController.delegate = self;
                             [self.view addSubview:self.centerViewController.view];
                             [self addChildViewController:_centerViewController];
                             [_centerViewController didMoveToParentViewController:self];
                             [self setupGestures];
                         }
                     }];
}

- (void)picturesWithDataSourceSelected:(Class)dataSource withTitle:(NSString *)title
{
    UBCenterViewController *newCenterController;
    
    if ([dataSource isSubclassOfClass:[UBFavoritePicturesDataSource class]]) {
        newCenterController = [[[UBPicturesController alloc] initWithDataSourceClass:dataSource] autorelease];
    } else {
        newCenterController = [[[UBPicturesCollectionViewController alloc] initWithDataSourceClass:dataSource] autorelease];
    }
    
    newCenterController.title = title;
    [self updateCenterViewController:newCenterController];
}

- (void)quotesWithDataSourceSelected:(Class)dataSource withTitle:(NSString *)title
{
    UBCenterViewController *newCenterController;
    if ([dataSource isSubclassOfClass:[UBFavoriteQuotesDataSource class]]) {
        newCenterController = [[[UBQuotesController alloc] initWithDataSourceClass:dataSource] autorelease];
    } else {
        newCenterController = [[[UBQuotesContainerController alloc] initWithDataSourceClass:dataSource] autorelease];
    }
    newCenterController.title = title;
    [self updateCenterViewController:newCenterController];
}

- (void)donateControllerSelected
{
    UBDonateViewController *donateViewController = [[[UBDonateViewController alloc] init] autorelease];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        donateViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        donateViewController.modal = YES;
        [self presentViewController:donateViewController animated:YES completion:nil];
    } else {
        [self updateCenterViewController:donateViewController];
    }
}

@end
