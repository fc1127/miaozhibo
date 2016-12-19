
//
//  XLWatchLiveViewController.m
//  XLMiaoBo
//
//  Created by XuLi on 16/8/31.
//  Copyright © 2016年 XuLi. All rights reserved.
//

#import "XLWatchLiveViewController.h"
#import "XLWatchLiveCell.h"

static NSString *reuserID = @"cell";
@implementation XLWatchLiveViewController

- (instancetype)init
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.itemSize = CGSizeMake(XLScreenW, XLScreenH);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    layout.collectionView.showsVerticalScrollIndicator = NO;
    layout.collectionView.showsHorizontalScrollIndicator = NO;

    
    return [super initWithCollectionViewLayout:layout];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self.collectionView registerClass:[XLWatchLiveCell class] forCellWithReuseIdentifier:reuserID];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    XLWatchLiveCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuserID forIndexPath:indexPath];
    
    cell.image = self.image;
    cell.allModels = self.allModels;
     cell.hotModel = self.hotModel;
    cell.parentVC = self;
    
    return cell;
}

@end
