//
//  UBEmptyListView.m
//  UkrBash
//
//  Created by Maks Markovets on 16.05.14.
//
//

#import "UBEmptyListView.h"

@implementation UBEmptyListView

- (id)initWithFrame:(CGRect)frame andEmptyViewType:(UBEmptyListViewType)listType
{
    if (self = [super initWithFrame:frame]) {
        UILabel *generalLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.frame.size.width - 20, 50)];
        generalLabel.font = [UIFont systemFontOfSize:20];
        generalLabel.numberOfLines = 0;
        generalLabel.textAlignment = NSTextAlignmentCenter;
        generalLabel.textColor = [UIColor darkGrayColor];
        generalLabel.shadowColor = [UIColor whiteColor];
        generalLabel.shadowOffset = CGSizeMake(0., 1.);
        generalLabel.text = [NSString stringWithFormat:@"Список улюблених %@ пустий.", listType == UBEmptyListViewFavoriteQuotesType ? @"цитат" : @"картинок"] ;
        [self addSubview:generalLabel];
        [generalLabel release];
        
        UILabel *pressLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, generalLabel.frame.origin.y + generalLabel.frame.size.height + 10, (self.frame.size.width / 2) - 31, 50)];
        pressLabel.font = [UIFont systemFontOfSize:20];
        pressLabel.numberOfLines = 1;
        pressLabel.textAlignment = NSTextAlignmentCenter;
        pressLabel.textColor = [UIColor darkGrayColor];
        pressLabel.shadowColor = [UIColor whiteColor];
        pressLabel.shadowOffset = CGSizeMake(0., 1.);
        pressLabel.text = @"Натискайте";
        [self addSubview:pressLabel];
        [pressLabel release];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"favorite.png"]];
        imageView.frame = CGRectMake(self.frame.size.width / 2 - 16, pressLabel.center.y - 16, 32, 32);
        [self addSubview:imageView];
        [imageView release];
        
        UILabel *toAddLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 130, pressLabel.frame.origin.y, self.frame.size.width / 2 - 31, 50)];
        toAddLabel.font = [UIFont systemFontOfSize:20];
        toAddLabel.numberOfLines = 1;
        toAddLabel.textAlignment = NSTextAlignmentCenter;
        toAddLabel.textColor = [UIColor darkGrayColor];
        toAddLabel.shadowColor = [UIColor whiteColor];
        toAddLabel.shadowOffset = CGSizeMake(0., 1.);
        toAddLabel.text = @"щоб додати.";
        [self addSubview:toAddLabel];
        
        CGRect newFrame = self.frame;
        newFrame.size.height = toAddLabel.frame.origin.y + toAddLabel.frame.size.height + 10;
        self.frame = newFrame;
        [toAddLabel release];
    }
    return self;
}

@end
