//
//  VKSharingViewController.m
//  UkrBash
//
//  Created by Michail Grebionkin on 06.12.12.
//
//

#import "VKSharingView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Vkontakte.h"
#import "VKError.h"

enum  {
    VKSharingViewNoAnimation = 0,
    VKSharingViewShowAnimation
};

#define kAnimationDuration  0.33

@interface VKSharingAttachmentContentView : UIView
{
    UILabel * _headerLabel;
    UILabel * _descriptionLabel;
    UIImageView * _previewImageView;
}

- (void)setHeaderText:(NSString *)headerText;
- (void)setDescriptionText:(NSString *)descriptionText;
- (void)setPreviewImage:(UIImage *)previewImage;

@end

#pragma mark -

@implementation VKSharingAttachmentContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor = [[UIColor vkSharingViewInnerBlockBorderColor] CGColor];
        self.layer.borderWidth = 1.;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
        
        CGFloat padding = 10.;
        _headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, padding / 2., frame.size.width - 2. * padding, 18.)];
        _headerLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _headerLabel.font = [UIFont boldSystemFontOfSize:13.];
        _headerLabel.textColor = [UIColor vkSharingAttachmentHeaderTextColor];
        _headerLabel.lineBreakMode = UILineBreakModeTailTruncation;
        _headerLabel.adjustsFontSizeToFitWidth = NO;
        [self addSubview:_headerLabel];
        [_headerLabel release];
        
        CGFloat descriptionLabelY = _headerLabel.frame.origin.y + _headerLabel.frame.size.height + padding / 2.;
        CGFloat descriptionLabelHeight = MAX(0., frame.size.height - descriptionLabelY - padding);
        _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, descriptionLabelY, frame.size.width - 2. * padding, descriptionLabelHeight)];
        _descriptionLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _descriptionLabel.lineBreakMode = UILineBreakModeTailTruncation;
        _descriptionLabel.adjustsFontSizeToFitWidth = NO;
        _descriptionLabel.numberOfLines = 4;
        _descriptionLabel.font = [UIFont systemFontOfSize:12.];
        [self addSubview:_descriptionLabel];
        [_descriptionLabel release];
        
        _previewImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _previewImageView.contentMode = UIViewContentModeScaleAspectFill;
        _previewImageView.clipsToBounds = YES;
        [self addSubview:_previewImageView];
        [_previewImageView release];
    }
    return self;
}

- (void)setHeaderText:(NSString *)headerText
{
    _headerLabel.text = headerText;
}

- (void)setDescriptionText:(NSString *)descriptionText
{
    _descriptionLabel.text = descriptionText;
    [_descriptionLabel sizeToFit];
}

- (void)setPreviewImage:(UIImage *)previewImage
{
    _previewImageView.image = previewImage;
}

- (void)layoutSubviews
{
    
    CGFloat padding = 10.;
    _headerLabel.frame = CGRectMake(padding, padding / 2., self.frame.size.width - 2. * padding, 18.);

    CGFloat descriptionLabelY = _headerLabel.frame.origin.y + _headerLabel.frame.size.height + padding / 2.;
    CGFloat descriptionLabelX = padding;
    CGFloat descriptionLabelWidthDelta = 0.;
    CGFloat previewImageSize = self.frame.size.height - descriptionLabelY - padding;
    if (_previewImageView.image != nil) {
        descriptionLabelX = padding * 2. + previewImageSize;
        descriptionLabelWidthDelta = 90. + padding;
        _previewImageView.frame = CGRectMake(padding, descriptionLabelY, previewImageSize, previewImageSize);
    }
    CGFloat descriptionLabelHeight = MAX(0., self.frame.size.height - descriptionLabelY - padding);
    _descriptionLabel.frame = CGRectMake(descriptionLabelX, descriptionLabelY, self.frame.size.width - 2. * padding - descriptionLabelWidthDelta, descriptionLabelHeight);
    [_descriptionLabel sizeToFit];
}

@end

#pragma mark -

@interface VKSharingView ()
{
    UIView * _backgroundView;
    UITextView * _textView;
    VKSharingAttachmentContentView * _attachmentContentView;
    UISwitch * _friendsOnlySwitch;
    UIButton * _submitButton;
    UIButton * _cancelButton;
    VKWallPostAttachment * _attachment;
    Vkontakte * _vkontakte;
    UIImageView * _activityView;
    NSInteger _currentAnimation;
}

@end

#pragma mark -

@implementation VKSharingView

- (id)init
{
    return [self initWithFrame:CGRectZero];
}

- (id)initWithVkontakte:(Vkontakte *)vkontakte andRootViewController:(UIViewController *)rootViewController
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        _vkontakte = [vkontakte retain];
        _rootViewController = [rootViewController retain];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    UIWindow * window =  [[UIApplication sharedApplication] keyWindow];
    if (!window) {
        window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    }
    UIInterfaceOrientation statusBarOritentation = [[UIApplication sharedApplication] statusBarOrientation];
    CGFloat statusBarHeight = 0;
    CGFloat windowWidth = 0;
    CGFloat windowHeight = 0;
    if (UIInterfaceOrientationIsLandscape(statusBarOritentation)) {
        statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.width;
        windowWidth = window.frame.size.height;
        windowHeight = window.frame.size.width;
    } else {
        statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
        windowWidth = window.frame.size.width;
        windowHeight = window.frame.size.height;
    }
    
    CGFloat viewWidth = 0;
    CGFloat topPaddig = 0;
    if (IS_PAD) {
        viewWidth = windowWidth / 1.5;
        topPaddig = 44;
    } else {
        viewWidth = windowWidth;
    }
    
    CGFloat padding = 10.;
    self = [super initWithFrame:CGRectMake(padding, topPaddig + padding + statusBarHeight, viewWidth - 2. * padding, windowHeight - 2. * padding - statusBarHeight)];
    if (self) {
        
        
        self.layer.borderColor = [[UIColor colorWithWhite:0.75 alpha:0.6] CGColor];
        self.layer.borderWidth = 5.;
        self.layer.cornerRadius = 5.;
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.bounds] CGPath];
        self.layer.shadowRadius = 7.;
        self.layer.shadowOffset = CGSizeMake(0., 0.);
        self.layer.shadowOpacity = 1.;
        self.backgroundColor = [UIColor vkSharingViewBackgroundColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        CGFloat subviewsWidth = self.frame.size.width - 2. * padding;
        
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(padding, padding, subviewsWidth, 70.)];
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.layer.borderWidth = 1.;
        _textView.layer.borderColor = [[UIColor vkSharingViewInnerBlockBorderColor] CGColor];
        _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_textView];
        [_textView release];
        
        UITapGestureRecognizer * cancelInputTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelInputAction:)];
        [self addGestureRecognizer:cancelInputTapGesture];
        [cancelInputTapGesture release];

        _attachmentContentView = [[VKSharingAttachmentContentView alloc] initWithFrame:CGRectMake(padding, CGRectGetMaxY(_textView.frame) + padding, subviewsWidth, 100.)];
        _attachmentContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_attachmentContentView];
        [_attachmentContentView release];
        
        _friendsOnlySwitch = [[UISwitch alloc] init];
        _friendsOnlySwitch.frame = CGRectMake(self.frame.size.width - padding - _friendsOnlySwitch.frame.size.width, CGRectGetMaxY(_attachmentContentView.frame) + padding / 2., _friendsOnlySwitch.frame.size.width, _friendsOnlySwitch.frame.size.height);
        _friendsOnlySwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:_friendsOnlySwitch];
        [_friendsOnlySwitch release];
        
        UILabel * l = [[UILabel alloc] initWithFrame:CGRectMake(padding, _friendsOnlySwitch.frame.origin.y, self.frame.size.width - 2. * padding - _friendsOnlySwitch.frame.size.width, _friendsOnlySwitch.frame.size.height)];
        l.text = VKLocalizedString(@"VKSharingSettingsFriendsOnly", @"");
        l.font = [UIFont systemFontOfSize:14.];
        l.backgroundColor = self.backgroundColor;
        [self addSubview:l];
        [l release];
        
        _submitButton = [[UIButton alloc] initWithFrame:CGRectMake(padding, CGRectGetMaxY(l.frame) + padding, self.frame.size.width / 2.- padding * 2., 40.)];
        _submitButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.];
        [_submitButton setTitle:VKLocalizedString(@"VKSharingSubmitButtonTitle", @"") forState:UIControlStateNormal];
        [_submitButton setBackgroundColor:[UIColor vkButtonBlueBackgroundColor]];
        _submitButton.layer.borderColor = [[UIColor vkButtonBlueBorderColor] CGColor];
        _submitButton.layer.borderWidth = 1.;
        _submitButton.layer.cornerRadius = 2.;
        [_submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_submitButton addTarget:self action:@selector(submitAction:) forControlEvents:UIControlEventTouchUpInside];
        _submitButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:_submitButton];
        [_submitButton release];
        
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_submitButton.frame) + padding, _submitButton.frame.origin.y, _submitButton.frame.size.width, _submitButton.frame.size.height)];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:14.];
        [_cancelButton setTitleColor:[UIColor vkButtonBlueBackgroundColor] forState:UIControlStateNormal];
        [_cancelButton setTitle:VKLocalizedString(@"VKSharingCancelButtonTitle", @"") forState:UIControlStateNormal];
        _cancelButton.backgroundColor = self.backgroundColor;
        [_cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:_cancelButton];
        [_cancelButton release];
        
        _activityView = [[UIImageView alloc] initWithFrame:CGRectMake(0., 0., 32., 8.)];
        [_activityView setAnimationImages:@[
         [UIImage imageNamed:@"Vkontakte iOS.bundle/upload1.png"],
         [UIImage imageNamed:@"Vkontakte iOS.bundle/upload2.png"],
         [UIImage imageNamed:@"Vkontakte iOS.bundle/upload3.png"],
         [UIImage imageNamed:@"Vkontakte iOS.bundle/upload4.png"],
         [UIImage imageNamed:@"Vkontakte iOS.bundle/upload5.png"],
         [UIImage imageNamed:@"Vkontakte iOS.bundle/upload6.png"]
         ]];
        [_activityView setAnimationDuration:0.6];
        [_activityView setAnimationRepeatCount:0];
        [_activityView startAnimating];
        [_activityView setHidden:YES];
        _activityView.center = _submitButton.center;
        [self addSubview:_activityView];
        [_activityView release];
        
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, CGRectGetMaxY(_cancelButton.frame) + padding);
        self.center = CGPointMake(windowWidth / 2, self.center.y);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidChangeOrientationNotificationHandler:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [_attachment release];
    [_vkontakte release];
    [_rootViewController release];
    Block_release(_successHandler);
    Block_release(_failHandler);
    [super dealloc];
}

#pragma mark - Setters

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.bounds] CGPath];
}

- (void)setSuccessHandler:(VKSharingViewSuccessHandler)successHandler
{
    Block_release(_successHandler);
    _successHandler = Block_copy(successHandler);
}

- (void)setFailHandler:(VKSharingViewFailHandler)failHandler
{
    Block_release(_failHandler);
    _failHandler = Block_copy(failHandler);
}

#pragma mark -

- (void)show
{
    UIWindow *window =  [[UIApplication sharedApplication] keyWindow];
    if (!window) {
        window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    }
 
    _backgroundView = [[UIView alloc] initWithFrame:window.frame];
    _backgroundView.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelAction:)];
    [_backgroundView addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    [_rootViewController.view addSubview:_backgroundView];
    [_backgroundView release];

    [_rootViewController.view addSubview:self];

    CALayer *viewLayer = self.layer;
    CAKeyframeAnimation* popInAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
	
    popInAnimation.duration = kAnimationDuration;
    popInAnimation.values = [NSArray arrayWithObjects:
                             [NSNumber numberWithFloat:0.6],
                             [NSNumber numberWithFloat:1.1],
                             [NSNumber numberWithFloat:.9],
                             [NSNumber numberWithFloat:1],
                             nil];
    popInAnimation.keyTimes = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0],
                               [NSNumber numberWithFloat:0.6],
                               [NSNumber numberWithFloat:0.8],
                               [NSNumber numberWithFloat:1.0],
                               nil];
    popInAnimation.delegate = self;
	
    [viewLayer addAnimation:popInAnimation forKey:@"transform.scale"];
    _currentAnimation = VKSharingViewShowAnimation;
}

- (void)hide
{
    [UIView animateWithDuration:0.4
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.alpha = 0;
                     } completion:^(BOOL finished) {
                         [_backgroundView removeFromSuperview];
                         [self removeFromSuperview];
                     }];
}

- (void)setAttachment:(VKWallPostAttachment *)attachment
{
    _attachment = [attachment retain];
}

- (void)setAttachmentDescription:(NSString *)attachmentDescription
{
    [_attachmentContentView setDescriptionText:attachmentDescription];
    [_attachmentContentView setNeedsLayout];
}

-(void)setAttachmentTitle:(NSString *)attachmentTitle
{
    [_attachmentContentView setHeaderText:attachmentTitle];
}

- (void)setAttachmentImagePreview:(UIImage *)previewImage
{
    [_attachmentContentView setPreviewImage:previewImage];
    [_attachmentContentView setNeedsLayout];
}

#pragma mark - Notification handlers

- (void)deviceDidChangeOrientationNotificationHandler:(NSNotification *)notification
{
    UIApplication *application = [UIApplication sharedApplication];
    CGFloat statusBarHeight = 0;
    UIWindow *window =  [application keyWindow];
    if (!window) {
        window = [[application windows] objectAtIndex:0];
    }
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (!([application supportedInterfaceOrientationsForWindow:window] & (1 << orientation))) {
        return;
    }
    
    if (orientation == UIDeviceOrientationFaceUp ||
        orientation == UIDeviceOrientationFaceDown) {
        orientation = application.statusBarOrientation;
    }
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        statusBarHeight = [application statusBarFrame].size.width;
    } else {
        statusBarHeight = [application statusBarFrame].size.height;
    }
    
    CGPathRef newShadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    NSArray *animationsByName = [self.layer animationKeys];
    if ([animationsByName count]&&[[animationsByName objectAtIndex:0] isKindOfClass:[NSString class]]) {
        NSString *animationKey = [animationsByName objectAtIndex:0];
        CAAnimation *existingUIKitAnimation = [self.layer animationForKey:animationKey];
        CABasicAnimation *newShadowPathAnimation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
        newShadowPathAnimation.duration = existingUIKitAnimation.duration;
        newShadowPathAnimation.toValue = [NSValue valueWithPointer:newShadowPath];
        newShadowPathAnimation.timingFunction = existingUIKitAnimation.timingFunction;
        [self.layer addAnimation:newShadowPathAnimation forKey:@"shadowPath"];
    }
    
    self.layer.shadowPath = newShadowPath;

    CGFloat windowWidth = self.rootViewController.view.frame.size.width;
    CGFloat topPadding = 0;
    if (IS_PAD) {
        topPadding = 44.;
    }
    [UIView animateWithDuration:0.25 animations:^{
        CGFloat padding = statusBarHeight + 10.;
        self.center = CGPointMake(windowWidth / 2., self.frame.size.height / 2. + padding + topPadding);
    }];
}

#pragma mark - Animation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (_currentAnimation == VKSharingViewShowAnimation) {
        [_textView becomeFirstResponder];
    }
    _currentAnimation = VKSharingViewNoAnimation;
}

#pragma mark - Actions

- (void)cancelInputAction:(id)sender
{
    if ([_textView isFirstResponder]) {
        [_textView resignFirstResponder];
    }
}

- (void)cancelAction:(id)sender
{
    if (self.failHandler) {
        NSDictionary * userInfo = @{
            NSLocalizedDescriptionKey: @"Canceled by user."
        };
        NSError * error = [NSError errorWithDomain:kVKErrorDomain code:VKCanceledErrorCode userInfo:userInfo];
        self.failHandler(error);
    }
}

- (void)submitAction:(id)sender
{
    NSAssert(_vkontakte != nil, @"Can't call a post method.");
    NSAssert(![_textView.text isEqualToString:@""] || _attachment != nil, @"nothing to post. message or attachment required.");
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [NSString stringWithFormat:@"%d", _vkontakte.userId], @"owner_id",
                                    (_friendsOnlySwitch.on) ? @(1) : @(0), @"friends_only",
                                    nil];
    if (![_textView.text isEqualToString:@""]) {
        [params setObject:_textView.text forKey:@"message"];
    }
    if (_attachment) {
        NSString * a = [NSString stringWithFormat:@"%@", [_attachment stringValue]];
        [params setObject:a forKey:@"attachments"];
    }
    
    [_textView setEditable:NO];
    [_friendsOnlySwitch setEnabled:NO];
    [_submitButton setHidden:YES];
    [_cancelButton setHidden:YES];
    [_activityView setHidden:NO];
    
    [_vkontakte callMethod:@"wall.post" withParams:params handler:^(NSString * method, NSDictionary * result, NSError * error) {
        if (error) {
            NSLog(@"VKError: \n\tmethod: %@\n\tresult: %@\n\terror: %@", method, result, error);
            [_textView setEditable:YES];
            [_friendsOnlySwitch setEnabled:YES];
            [_submitButton setHidden:NO];
            [_cancelButton setHidden:NO];
            [_activityView setHidden:YES];
            
            if (self.failHandler) {
                self.failHandler(error);
            }
        }
        else {
            if (self.successHandler) {
                self.successHandler();
            }
        }
    }];
}

@end
