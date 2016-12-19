//
//  XLWatchLiveCell.h
//  XLMiaoBo
//
//  Created by XuLi on 16/8/31.
//  Copyright © 2016年 XuLi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLHotModel.h"

@interface XLWatchLiveCell : UICollectionViewCell

@property (nonatomic, strong)XLHotModel *hotModel;

@property (nonatomic, strong) NSArray *allModels;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) UIViewController *parentVC;

@end
