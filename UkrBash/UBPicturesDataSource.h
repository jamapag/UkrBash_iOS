//
//  UBPicturesDataSource.h
//  UkrBash
//
//  Created by Михаил Гребенкин on 03.02.12.
//  Copyright (c) 2012 smile2mobile. All rights reserved.
//

#import "UBTableViewDataSource.h"
#import "UBPictureInfoView.h"

@interface UBPicturesDataSource : UBTableViewDataSource

- (void)configurePictureInfoView:(UBPictureInfoView*)infoView forRowAtIndexPath:(NSIndexPath*)indexPath;

@end
