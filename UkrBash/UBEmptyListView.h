//
//  UBEmptyListView.h
//  UkrBash
//
//  Created by Maks Markovets on 16.05.14.
//
//

#import <UIKit/UIKit.h>

typedef enum{
	UBEmptyListViewFavoriteQuotesType = 0,
	UBEmptyListViewFavoritePicturesType,
} UBEmptyListViewType;

@interface UBEmptyListView : UIView

- (id)initWithFrame:(CGRect)frame andEmptyViewType:(UBEmptyListViewType)listType;

@end
