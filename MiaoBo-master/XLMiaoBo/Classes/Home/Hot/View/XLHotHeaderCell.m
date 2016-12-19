
//
//  XLHotHeaderCell.m
//  XLMiaoBo
//
//  Created by XuLi on 16/8/31.
//  Copyright © 2016年 XuLi. All rights reserved.
//

#import "XLHotHeaderCell.h"


@implementation XLHotHeaderCell



- (void)setHeaderModels:(NSArray *)headerModels
{
    _headerModels = headerModels;
    
    NSMutableArray *imageUrls = [NSMutableArray array];
    for (XLHotHeaderModel *headerModel in headerModels) {
        
        [imageUrls addObject:headerModel.imageUrl];
    }
    XRCarouselView *view = [XRCarouselView carouselViewWithImageArray:imageUrls describeArray:nil];
    view.time = 2.0;
    view.delegate = self;
    view.frame = self.contentView.bounds;
    [self.contentView addSubview:view];

}


#pragma mark - XRCarouselViewDelegate
- (void)carouselView:(XRCarouselView *)carouselView clickImageAtIndex:(NSInteger)index
{
    if (self.imageClickBlock) {
        self.imageClickBlock(self.headerModels[index]);
    }
}

@end
