//
//  UBCenterViewController.m
//  UkrBash
//
//  Created by Maks Markovets on 27.10.14.
//
//

#import "UBCenterViewController.h"

@interface UBCenterViewController ()

@end

@implementation UBCenterViewController

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"texture.png"]];
    
    float y = 20;
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0., y, 50., self.view.frame.size.height + 20)];
    borderView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    borderView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"border.png"]];
    [self.view addSubview:borderView];
    [borderView release];
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


#pragma mark - Actions

- (void)menuAction:(id)sender
{
    if ([self isModal]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    UIButton *button = sender;
    switch (button.tag) {
        case 0: {
            [self.delegate movePanelToOriginalPosition];
            break;
        }
            
        case 1: {
            [self.delegate movePanelRight];
            break;
        }
            
        default:
            break;
    }
}

@end
