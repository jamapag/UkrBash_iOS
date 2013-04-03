//
//  UBCollectionViewLayout.m
//  UkrBash
//
//  Created by maks on 27.02.13.
//
//

#import "UBCollectionViewLayout.h"

@implementation UBCollectionViewLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *unfilteredPoses = [super layoutAttributesForElementsInRect:rect];
    id filteredPoses[unfilteredPoses.count];
    NSUInteger filteredPosesCount = 0;
    for (UICollectionViewLayoutAttributes *pose in unfilteredPoses) {
        CGRect frame = pose.frame;
        if (frame.origin.x + frame.size.width <= rect.size.width) {
            filteredPoses[filteredPosesCount++] = pose;
        }
    }
    return [NSArray arrayWithObjects:filteredPoses count:filteredPosesCount];
}

@end
